import {
  Injectable,
  ConflictException,
  UnauthorizedException,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { User } from '@prisma/client';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async register(registerDto: RegisterDto) {
    const {
      email,
      password,
      name,
      phone,
      roleCode: rawRoleCode,
      caregiverInviteCode,
    } = registerDto;

    const normalizedRoleCode = (rawRoleCode || 'patient').trim().toLowerCase();
    const inviteCode = caregiverInviteCode?.trim();
    const dbRoleCode = this.toDbRoleCode(normalizedRoleCode);

    const role = await this.prisma.role.findUnique({
      where: { roleCode: dbRoleCode },
    });

    if (!role) {
      throw new BadRequestException('Invalid role selected.');
    }

    if (normalizedRoleCode === 'caregiver' && !inviteCode) {
      throw new BadRequestException(
        'Invitation code is required for caregiver registration.',
      );
    }

    // Check if user exists
    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    const registrationResult = await this.prisma.$transaction(async (tx) => {
      // When registering as caregiver, load and validate invitation inside transaction
      let invitation: {
        invitationId: bigint;
        elderUserId: bigint;
        inviterUserId: bigint;
        relationshipCode: string;
        status: string;
        expiresAt: Date;
      } | null = null;

      if (normalizedRoleCode === 'caregiver') {
        invitation = await tx.userInvitation.findUnique({
          where: { inviteCode: inviteCode! },
          select: {
            invitationId: true,
            elderUserId: true,
            inviterUserId: true,
            relationshipCode: true,
            status: true,
            expiresAt: true,
          },
        });

        if (!invitation) {
          throw new BadRequestException('Invalid caregiver invitation code.');
        }

        if (invitation.status !== 'pending') {
          throw new BadRequestException('Invitation has already been processed.');
        }

        if (invitation.expiresAt < new Date()) {
          throw new BadRequestException('Invitation has expired.');
        }
      }

      // Create user
      const user = await tx.user.create({
        data: {
          email,
          phone: phone || null,
          passwordHash: hashedPassword,
          full_name: name || '',
        },
      });

      // Provision default FREE subscription
      await tx.subscription.create({
        data: {
          userId: user.userId,
          planId: null,
          status: 'active',
        },
      });

      // Attach selected role
      await tx.userRole.create({
        data: {
          userId: user.userId,
          roleId: role.roleId,
        },
      });

      if (normalizedRoleCode === 'caregiver' && invitation) {
        const now = new Date();

        await tx.userInvitation.update({
          where: { invitationId: invitation.invitationId },
          data: {
            status: 'accepted',
            acceptedUserId: user.userId,
            acceptedAt: now,
          },
        });

        await tx.elderAssignment.create({
          data: {
            elderUserId: invitation.elderUserId,
            caregiverUserId: user.userId,
            relationshipCode: invitation.relationshipCode,
            isPrimary: false,
          },
        });
      }

      return user;
    });

    // TODO: Send verification email
    // await this.sendVerificationEmail(registrationResult.email, verificationToken);

    return {
      message: 'Registration successful. Please verify your email.',
      userId: registrationResult.userId.toString(),
      role: this.toClientRoleCode(role.roleCode),
    };
  }

  async login(loginDto: LoginDto) {
    const user = await this.validateUser(loginDto.email, loginDto.password);

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const activeRole = await this.resolveActiveRole(user.userId);
    const tokens = await this.generateTokens(user, activeRole);

    return {
      ...tokens,
      user: {
        id: user.userId.toString(),
        email: user.email,
        name: user.full_name,
        role: activeRole,
      },
    };
  }

  async validateUser(email: string, password: string): Promise<User | null> {
    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user || !user.passwordHash) {
      return null;
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

    if (!isPasswordValid) {
      return null;
    }

    return user;
  }

  async validateGoogleUser(profile: {
    googleId: string;
    email: string;
    name: string;
  }): Promise<User> {
    // Note: googleId field doesn't exist in current schema, using email for lookup
    let user = await this.prisma.user.findUnique({
      where: { email: profile.email },
    });

    if (!user) {
      // Create new user for Google OAuth
      user = await this.prisma.user.create({
        data: {
          email: profile.email,
          full_name: profile.name,
          authProvider: 'google',
        },
      });

      // Create default FREE subscription
      await this.prisma.subscription.create({
        data: {
          userId: user.userId,
          planId: null,
          status: 'active',
        },
      });
    }

    // Ensure user has patient role
    const patientRole = await this.prisma.role.findUnique({
      where: { roleCode: this.toDbRoleCode('patient') },
    });

    if (patientRole) {
      const hasRole = await this.prisma.userRole.findFirst({
        where: { userId: user.userId, roleId: patientRole.roleId },
      });

      if (!hasRole) {
        await this.prisma.userRole.create({
          data: {
            userId: user.userId,
            roleId: patientRole.roleId,
          },
        });
      }
    }

    return user;
  }

  async verifyEmail(token: string) {
    // Note: verificationToken field doesn't exist in current schema
    // This functionality needs to be implemented with a separate table or added to schema
    throw new NotFoundException('Email verification not implemented in current schema');
  }

  async refreshToken(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      });

      const user = await this.prisma.user.findUnique({
        where: { userId: BigInt(payload.sub) },
      });

      if (!user) {
        throw new UnauthorizedException('User not found');
      }

      const activeRole = await this.resolveActiveRole(user.userId);
      return this.generateTokens(user, activeRole);
    } catch (error) {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  private async generateTokens(user: User, role?: string) {
    const roleCode = role || (await this.resolveActiveRole(user.userId));
    const payload = {
      sub: user.userId.toString(),
      email: user.email || '',
      role: roleCode,
    };

    const jwtSecret =
      this.configService.get<string>('JWT_SECRET') || 'default-secret';
    const jwtExpiration =
      this.configService.get<string>('JWT_EXPIRATION') || '7d';
    const jwtRefreshSecret =
      this.configService.get<string>('JWT_REFRESH_SECRET') ||
      'default-refresh-secret';
    const jwtRefreshExpiration =
      this.configService.get<string>('JWT_REFRESH_EXPIRATION') || '30d';

    const accessToken = this.jwtService.sign(payload, {
      secret: jwtSecret,
      expiresIn: jwtExpiration as any,
    });

    const refreshToken = this.jwtService.sign(payload, {
      secret: jwtRefreshSecret,
      expiresIn: jwtRefreshExpiration as any,
    });

    return {
      accessToken,
      refreshToken,
    };
  }
  private async resolveActiveRole(userId: bigint): Promise<string> {
    const role = await this.prisma.userRole.findFirst({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      include: {
        role: true,
      },
    });

    const roleCode = role?.role.roleCode;
    return this.toClientRoleCode(roleCode);
  }

  private toDbRoleCode(roleCode: string | undefined): string {
    const normalized = (roleCode || '').trim().toLowerCase();
    return normalized || 'patient';
  }

  private toClientRoleCode(roleCode: string | undefined): string {
    if (!roleCode) {
      return 'patient';
    }
    return roleCode.toLowerCase();
  }
}

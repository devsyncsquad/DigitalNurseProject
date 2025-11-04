import {
  Injectable,
  ConflictException,
  UnauthorizedException,
  NotFoundException,
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
    const { email, password, name } = registerDto;

    // Check if user exists
    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = await this.prisma.user.create({
      data: {
        email,
        passwordHash: hashedPassword,
        full_name: name || '',
      },
    });

    // Create default FREE subscription (planId is null for FREE plan)
    await this.prisma.subscription.create({
      data: {
        userId: user.userId,
        planId: null,
        status: 'active',
      },
    });

    // TODO: Send verification email
    // await this.sendVerificationEmail(user.email, verificationToken);

    return {
      message: 'Registration successful. Please verify your email.',
      userId: user.userId.toString(),
    };
  }

  async login(loginDto: LoginDto) {
    const user = await this.validateUser(loginDto.email, loginDto.password);

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const tokens = await this.generateTokens(user);

    return {
      ...tokens,
      user: {
        id: user.userId.toString(),
        email: user.email,
        name: user.full_name,
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

      return this.generateTokens(user);
    } catch (error) {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  private async generateTokens(user: User) {
    const payload = { sub: user.userId.toString(), email: user.email || '' };

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
}

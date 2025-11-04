import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { CompleteProfileDto } from './dto/complete-profile.dto';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async getProfile(userId: number) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        emailVerified: true,
        profileCompleted: true,
        phoneNumber: true,
        dateOfBirth: true,
        address: true,
        city: true,
        country: true,
        createdAt: true,
        updatedAt: true,
        subscriptions: {
          where: { status: 'ACTIVE' },
          orderBy: { createdAt: 'desc' },
          take: 1,
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user;
  }

  async updateProfile(userId: number, updateProfileDto: UpdateProfileDto) {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: updateProfileDto,
      select: {
        id: true,
        email: true,
        name: true,
        phoneNumber: true,
        dateOfBirth: true,
        address: true,
        city: true,
        country: true,
        profileCompleted: true,
      },
    });

    return user;
  }

  async completeProfile(
    userId: number,
    completeProfileDto: CompleteProfileDto,
  ) {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: {
        ...completeProfileDto,
        profileCompleted: true,
      },
      select: {
        id: true,
        email: true,
        name: true,
        phoneNumber: true,
        dateOfBirth: true,
        address: true,
        city: true,
        country: true,
        profileCompleted: true,
      },
    });

    return {
      message: 'Profile completed successfully',
      user,
    };
  }
}

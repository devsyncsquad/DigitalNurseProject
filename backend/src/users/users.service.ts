import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { CompleteProfileDto } from './dto/complete-profile.dto';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async getProfile(userId: bigint) {
    const user = await this.prisma.user.findUnique({
      where: { userId },
      include: {
        subscriptions: {
          where: { status: 'active' },
          orderBy: { createdAt: 'desc' },
          take: 1,
        },
        userRoles: {
          orderBy: { createdAt: 'desc' },
          take: 1,
          include: {
            role: true,
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Calculate age from dob
    const age = user.dob
      ? Math.floor((new Date().getTime() - new Date(user.dob).getTime()) / (365.25 * 24 * 60 * 60 * 1000))
      : null;

    // Get subscription tier
    const subscriptionTier = user.subscriptions[0]?.planId
      ? await this.prisma.subscriptionPlan.findUnique({
          where: { planId: user.subscriptions[0].planId },
        })
      : null;

    const activeRoleCode = user.userRoles[0]?.role?.roleCode;
    const normalizedRole = activeRoleCode
      ? activeRoleCode.toLowerCase()
      : 'patient';

    return {
      id: user.userId.toString(),
      email: user.email || '',
      name: user.full_name,
      role: normalizedRole,
      subscriptionTier: subscriptionTier?.planCode || 'free',
      age: age?.toString() || null,
      medicalConditions: user.medicalConditions || null,
      emergencyContact: user.emergencyContact || null,
      phone: user.phone || null,
    };
  }

  async updateProfile(userId: bigint, updateProfileDto: UpdateProfileDto) {
    const updateData: any = {};
    if (updateProfileDto.name) updateData.full_name = updateProfileDto.name;
    if (updateProfileDto.phoneNumber) updateData.phone = updateProfileDto.phoneNumber;
    if (updateProfileDto.dateOfBirth) updateData.dob = new Date(updateProfileDto.dateOfBirth);
    if (updateProfileDto.address) updateData.address = updateProfileDto.address;
    // Note: Database schema doesn't have separate city/country fields, combining into address
    if (updateProfileDto.city || updateProfileDto.country) {
      const parts = [updateProfileDto.address || updateData.address, updateProfileDto.city, updateProfileDto.country].filter(Boolean);
      updateData.address = parts.join(', ');
    }
    if (updateProfileDto.medicalConditions !== undefined)
      updateData.medicalConditions = updateProfileDto.medicalConditions;
    if (updateProfileDto.emergencyContact !== undefined)
      updateData.emergencyContact = updateProfileDto.emergencyContact;

    const user = await this.prisma.user.update({
      where: { userId },
      data: updateData,
    });

    return this.getProfile(userId);
  }

  async completeProfile(userId: bigint, completeProfileDto: CompleteProfileDto) {
    const updateData: any = {
      full_name: completeProfileDto.name,
      phone: completeProfileDto.phoneNumber,
      dob: completeProfileDto.dateOfBirth ? new Date(completeProfileDto.dateOfBirth) : null,
      address: completeProfileDto.address || null,
    };

    const user = await this.prisma.user.update({
      where: { userId },
      data: updateData,
    });

    return {
      message: 'Profile completed successfully',
      user: await this.getProfile(userId),
    };
  }
}

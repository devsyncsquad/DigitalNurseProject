import { prisma } from '../../config/database';
import { UpdateProfileInput, CompleteProfileInput } from './users.schemas';
import { AppError } from '../../middleware/errorHandler.middleware';

export class UsersService {
  /**
   * Get user profile by ID
   */
  async getUserProfile(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        subscriptions: {
          where: { status: 'ACTIVE' },
          orderBy: { createdAt: 'desc' },
          take: 1,
        },
      },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    // Remove sensitive data
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { password, verificationToken, ...sanitizedUser } = user;

    return sanitizedUser;
  }

  /**
   * Update user profile
   */
  async updateProfile(userId: string, data: UpdateProfileInput) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    // Convert dateOfBirth string to Date if provided
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const updateData: any = { ...data };
    
    if (data.dateOfBirth) {
      updateData.dateOfBirth = new Date(data.dateOfBirth);
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: updateData,
    });

    // Remove sensitive data
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { password, verificationToken, ...sanitizedUser } = updatedUser;

    return sanitizedUser;
  }

  /**
   * Complete user profile (onboarding)
   */
  async completeProfile(userId: string, data: CompleteProfileInput) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    if (user.profileCompleted) {
      throw new AppError('Profile already completed', 400);
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        name: data.name,
        phone: data.phone,
        dateOfBirth: new Date(data.dateOfBirth),
        gender: data.gender,
        profileCompleted: true,
      },
    });

    // Remove sensitive data
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { password, verificationToken, ...sanitizedUser } = updatedUser;

    return sanitizedUser;
  }

  /**
   * Check if profile is complete
   */
  async isProfileComplete(userId: string): Promise<boolean> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { profileCompleted: true },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    return user.profileCompleted;
  }
}

export const usersService = new UsersService();


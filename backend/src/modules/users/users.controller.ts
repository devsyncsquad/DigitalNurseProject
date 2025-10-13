import { Request, Response } from 'express';
import { usersService } from './users.service';
import { sendSuccess } from '../../utils/response.utils';
import { asyncHandler } from '../../middleware/errorHandler.middleware';
import { UpdateProfileInput, CompleteProfileInput } from './users.schemas';

export class UsersController {
  /**
   * Get current user profile
   */
  getProfile = asyncHandler(async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const profile = await usersService.getUserProfile(userId);

    return sendSuccess(res, profile);
  });

  /**
   * Update user profile
   */
  updateProfile = asyncHandler(async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const data: UpdateProfileInput = req.body;

    const updatedProfile = await usersService.updateProfile(userId, data);

    return sendSuccess(res, updatedProfile, 'Profile updated successfully');
  });

  /**
   * Complete user profile (onboarding)
   */
  completeProfile = asyncHandler(async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const data: CompleteProfileInput = req.body;

    const completedProfile = await usersService.completeProfile(userId, data);

    return sendSuccess(res, completedProfile, 'Profile completed successfully');
  });

  /**
   * Check if profile is complete
   */
  checkProfileStatus = asyncHandler(async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const isComplete = await usersService.isProfileComplete(userId);

    return sendSuccess(res, { profileCompleted: isComplete });
  });
}

export const usersController = new UsersController();


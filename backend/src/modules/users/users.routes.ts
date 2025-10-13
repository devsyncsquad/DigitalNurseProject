import { Router } from 'express';
import { usersController } from './users.controller';
import { authenticate } from '../../middleware/auth.middleware';
import { validate } from '../../middleware/validate.middleware';
import { updateProfileSchema, completeProfileSchema } from './users.schemas';

const router = Router();

// All user routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/users/profile
 * @desc    Get current user profile
 * @access  Private
 */
router.get('/profile', usersController.getProfile);

/**
 * @route   PATCH /api/users/profile
 * @desc    Update user profile
 * @access  Private
 */
router.patch('/profile', validate(updateProfileSchema), usersController.updateProfile);

/**
 * @route   POST /api/users/complete-profile
 * @desc    Complete user profile (onboarding)
 * @access  Private
 */
router.post(
  '/complete-profile',
  validate(completeProfileSchema),
  usersController.completeProfile
);

/**
 * @route   GET /api/users/profile-status
 * @desc    Check if user profile is complete
 * @access  Private
 */
router.get('/profile-status', usersController.checkProfileStatus);

export default router;


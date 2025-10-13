import { z } from 'zod';
import { Gender } from '@prisma/client';

/**
 * Update profile schema
 */
export const updateProfileSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters').optional(),
  phone: z.string().min(10, 'Phone number must be at least 10 characters').optional(),
  dateOfBirth: z.string().datetime().optional(),
  gender: z.nativeEnum(Gender).optional(),
  profilePicture: z.string().url('Profile picture must be a valid URL').optional(),
});

export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;

/**
 * Complete profile schema (onboarding)
 */
export const completeProfileSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  phone: z.string().min(10, 'Phone number must be at least 10 characters'),
  dateOfBirth: z.string().datetime(),
  gender: z.nativeEnum(Gender),
});

export type CompleteProfileInput = z.infer<typeof completeProfileSchema>;


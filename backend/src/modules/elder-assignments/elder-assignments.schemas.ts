import { z } from 'zod';

// Create Elder Assignment Schema
export const createElderAssignmentSchema = z.object({
  elderUserId: z.string().or(z.number()),
  caregiverUserId: z.string().or(z.number()),
  relationshipDomain: z.string().default('relationships'),
  relationshipCode: z.string().min(1, 'Relationship code is required'),
  isPrimary: z.boolean().default(false),
  notifyPrefs: z.any().optional(),
});

// Update Elder Assignment Schema
export const updateElderAssignmentSchema = z.object({
  relationshipDomain: z.string().optional(),
  relationshipCode: z.string().optional(),
  isPrimary: z.boolean().optional(),
  notifyPrefs: z.any().optional(),
});

// Export types
export type CreateElderAssignmentInput = z.infer<typeof createElderAssignmentSchema>;
export type UpdateElderAssignmentInput = z.infer<typeof updateElderAssignmentSchema>;

import { z } from 'zod';

// Create Lookup Schema
export const createLookupSchema = z.object({
  lookupDomain: z.string().min(1, 'Lookup domain is required'),
  lookupCode: z.string().min(1, 'Lookup code is required'),
  lookupLabel: z.string().min(1, 'Lookup label is required'),
  sortOrder: z.number().int().default(0),
  isActive: z.boolean().default(true),
});

// Update Lookup Schema
export const updateLookupSchema = z.object({
  lookupLabel: z.string().optional(),
  sortOrder: z.number().int().optional(),
  isActive: z.boolean().optional(),
});

// Export types
export type CreateLookupInput = z.infer<typeof createLookupSchema>;
export type UpdateLookupInput = z.infer<typeof updateLookupSchema>;

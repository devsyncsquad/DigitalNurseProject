import { z } from 'zod';

// Create Vital Measurement Schema
export const createVitalMeasurementSchema = z.object({
  elderUserId: z.string().or(z.number()),
  kindCode: z.string().min(1, 'Vital kind code is required'),
  unitCode: z.string().optional(),
  value1: z.number().optional(),
  value2: z.number().optional(),
  valueText: z.string().optional(),
  recordedAt: z
    .string()
    .or(z.date())
    .default(() => new Date().toISOString()),
  source: z.string().default('manual'),
  deviceInfo: z.any().optional(),
  notes: z.string().optional(),
});

// Update Vital Measurement Schema
export const updateVitalMeasurementSchema = z.object({
  kindCode: z.string().optional(),
  unitCode: z.string().optional(),
  value1: z.number().optional(),
  value2: z.number().optional(),
  valueText: z.string().optional(),
  recordedAt: z.string().or(z.date()).optional(),
  source: z.string().optional(),
  deviceInfo: z.any().optional(),
  notes: z.string().optional(),
});

// Query Schema for filtering
export const vitalQuerySchema = z.object({
  elderUserId: z.string().optional(),
  kindCode: z.string().optional(),
  startDate: z.string().optional(),
  endDate: z.string().optional(),
  limit: z.string().optional(),
});

// Export types
export type CreateVitalMeasurementInput = z.infer<typeof createVitalMeasurementSchema>;
export type UpdateVitalMeasurementInput = z.infer<typeof updateVitalMeasurementSchema>;
export type VitalQueryInput = z.infer<typeof vitalQuerySchema>;

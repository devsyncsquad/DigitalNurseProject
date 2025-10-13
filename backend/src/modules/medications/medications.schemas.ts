import { z } from 'zod';

// Create Medication Schema
export const createMedicationSchema = z.object({
  elderUserId: z.string().or(z.number()),
  medicationName: z.string().min(1, 'Medication name is required'),
  doseValue: z.number().positive().optional(),
  doseUnitCode: z.string().optional(),
  formCode: z.string().optional(),
  instructions: z.string().optional(),
  notes: z.string().optional(),
});

// Update Medication Schema
export const updateMedicationSchema = z.object({
  medicationName: z.string().min(1).optional(),
  doseValue: z.number().positive().optional(),
  doseUnitCode: z.string().optional(),
  formCode: z.string().optional(),
  instructions: z.string().optional(),
  notes: z.string().optional(),
});

// Create Med Schedule Schema
export const createMedScheduleSchema = z.object({
  medicationId: z.string().or(z.number()),
  timezone: z.string().default('Asia/Karachi'),
  startDate: z.string().or(z.date()),
  endDate: z.string().or(z.date()).optional(),
  daysMask: z.number().int().min(0).max(127).default(127),
  timesLocal: z.array(z.string()).or(z.any()),
  isPrn: z.boolean().default(false),
  snoozeMinutesDefault: z.number().int().positive().optional(),
});

// Update Med Schedule Schema
export const updateMedScheduleSchema = z.object({
  timezone: z.string().optional(),
  startDate: z.string().or(z.date()).optional(),
  endDate: z.string().or(z.date()).optional().nullable(),
  daysMask: z.number().int().min(0).max(127).optional(),
  timesLocal: z.array(z.string()).or(z.any()).optional(),
  isPrn: z.boolean().optional(),
  snoozeMinutesDefault: z.number().int().positive().optional().nullable(),
});

// Create Med Intake Schema
export const createMedIntakeSchema = z.object({
  medicationId: z.string().or(z.number()),
  elderUserId: z.string().or(z.number()),
  scheduledTime: z.string().or(z.date()).optional(),
  actualTime: z.string().or(z.date()).optional(),
  status: z.enum(['pending', 'taken', 'missed', 'skipped']).default('pending'),
  doseValue: z.number().positive().optional(),
  doseUnitCode: z.string().optional(),
  notes: z.string().optional(),
});

// Update Med Intake Schema
export const updateMedIntakeSchema = z.object({
  actualTime: z.string().or(z.date()).optional(),
  status: z.enum(['pending', 'taken', 'missed', 'skipped']).optional(),
  doseValue: z.number().positive().optional(),
  doseUnitCode: z.string().optional(),
  notes: z.string().optional(),
});

// Export types
export type CreateMedicationInput = z.infer<typeof createMedicationSchema>;
export type UpdateMedicationInput = z.infer<typeof updateMedicationSchema>;
export type CreateMedScheduleInput = z.infer<typeof createMedScheduleSchema>;
export type UpdateMedScheduleInput = z.infer<typeof updateMedScheduleSchema>;
export type CreateMedIntakeInput = z.infer<typeof createMedIntakeSchema>;
export type UpdateMedIntakeInput = z.infer<typeof updateMedIntakeSchema>;

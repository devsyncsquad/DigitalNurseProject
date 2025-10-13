import { z } from 'zod';

// Create Notification Schema
export const createNotificationSchema = z.object({
  userId: z.string().or(z.number()),
  title: z.string().min(1, 'Title is required'),
  message: z.string().min(1, 'Message is required'),
  notificationType: z.string().min(1, 'Notification type is required'),
  scheduledTime: z.string().or(z.date()).optional(),
});

// Update Notification Schema
export const updateNotificationSchema = z.object({
  title: z.string().optional(),
  message: z.string().optional(),
  notificationType: z.string().optional(),
  scheduledTime: z.string().or(z.date()).optional().nullable(),
  isRead: z.boolean().optional(),
  isSent: z.boolean().optional(),
  status: z.string().optional(),
});

// Mark as Read Schema
export const markAsReadSchema = z.object({
  notificationIds: z.array(z.string().or(z.number())),
});

// Export types
export type CreateNotificationInput = z.infer<typeof createNotificationSchema>;
export type UpdateNotificationInput = z.infer<typeof updateNotificationSchema>;
export type MarkAsReadInput = z.infer<typeof markAsReadSchema>;

import { z } from 'zod';
import { PlanType } from '@prisma/client';

/**
 * Create subscription schema
 */
export const createSubscriptionSchema = z.object({
  planType: z.nativeEnum(PlanType),
  paymentMethodId: z.string().optional(), // Stripe payment method ID
});

export type CreateSubscriptionInput = z.infer<typeof createSubscriptionSchema>;

/**
 * Upgrade subscription schema
 */
export const upgradeSubscriptionSchema = z.object({
  newPlanType: z.nativeEnum(PlanType),
});

export type UpgradeSubscriptionInput = z.infer<typeof upgradeSubscriptionSchema>;

/**
 * Cancel subscription schema
 */
export const cancelSubscriptionSchema = z.object({
  cancelAtPeriodEnd: z.boolean().default(true),
});

export type CancelSubscriptionInput = z.infer<typeof cancelSubscriptionSchema>;


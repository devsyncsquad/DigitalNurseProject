import { Request, Response } from 'express';
import Stripe from 'stripe';
import { subscriptionsService } from './subscriptions.service';
import { sendSuccess, sendCreated } from '../../utils/response.utils';
import { asyncHandler } from '../../middleware/errorHandler.middleware';
import {
  CreateSubscriptionInput,
  UpgradeSubscriptionInput,
  CancelSubscriptionInput,
} from './subscriptions.schemas';
import { env } from '../../config/env';

const stripe = new Stripe(env.STRIPE_SECRET_KEY, {
  apiVersion: '2024-06-20',
});

export class SubscriptionsController {
  /**
   * Get all available plans
   */
  getPlans = asyncHandler(async (_req: Request, res: Response) => {
    const plans = await subscriptionsService.getAvailablePlans();
    return sendSuccess(res, plans);
  });

  /**
   * Get current user subscription
   */
  getCurrentSubscription = asyncHandler(async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const subscription = await subscriptionsService.getCurrentSubscription(userId);
    return sendSuccess(res, subscription);
  });

  /**
   * Create a new subscription
   */
  createSubscription = asyncHandler(async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const data: CreateSubscriptionInput = req.body;

    const subscription = await subscriptionsService.createSubscription(userId, data);

    return sendCreated(res, subscription, 'Subscription created successfully');
  });

  /**
   * Upgrade subscription
   */
  upgradeSubscription = asyncHandler(async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const data: UpgradeSubscriptionInput = req.body;

    const subscription = await subscriptionsService.upgradeSubscription(userId, data);

    return sendSuccess(res, subscription, 'Subscription upgraded successfully');
  });

  /**
   * Cancel subscription
   */
  cancelSubscription = asyncHandler(async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const data: CancelSubscriptionInput = req.body;

    const result = await subscriptionsService.cancelSubscription(
      userId,
      data.cancelAtPeriodEnd
    );

    return sendSuccess(res, result);
  });

  /**
   * Handle Stripe webhook
   */
  handleWebhook = asyncHandler(async (req: Request, res: Response) => {
    const sig = req.headers['stripe-signature'] as string;

    if (!sig) {
      return res.status(400).json({ error: 'No stripe signature found' });
    }

    let event: Stripe.Event;

    try {
      event = stripe.webhooks.constructEvent(req.body, sig, env.STRIPE_WEBHOOK_SECRET);
    } catch (err) {
      const error = err as Error;
      return res.status(400).json({ error: `Webhook Error: ${error.message}` });
    }

    await subscriptionsService.handleWebhook(event);

    return res.json({ received: true });
  });
}

export const subscriptionsController = new SubscriptionsController();


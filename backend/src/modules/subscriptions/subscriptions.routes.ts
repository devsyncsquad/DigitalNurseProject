import { Router } from 'express';
import express from 'express';
import { subscriptionsController } from './subscriptions.controller';
import { authenticate } from '../../middleware/auth.middleware';
import { validate } from '../../middleware/validate.middleware';
import {
  createSubscriptionSchema,
  upgradeSubscriptionSchema,
  cancelSubscriptionSchema,
} from './subscriptions.schemas';

const router = Router();

/**
 * @route   GET /api/subscriptions/plans
 * @desc    Get all available subscription plans
 * @access  Public
 */
router.get('/plans', subscriptionsController.getPlans);

/**
 * @route   GET /api/subscriptions/current
 * @desc    Get current user subscription
 * @access  Private
 */
router.get('/current', authenticate, subscriptionsController.getCurrentSubscription);

/**
 * @route   POST /api/subscriptions/create
 * @desc    Create a new subscription
 * @access  Private
 */
router.post(
  '/create',
  authenticate,
  validate(createSubscriptionSchema),
  subscriptionsController.createSubscription
);

/**
 * @route   POST /api/subscriptions/upgrade
 * @desc    Upgrade current subscription
 * @access  Private
 */
router.post(
  '/upgrade',
  authenticate,
  validate(upgradeSubscriptionSchema),
  subscriptionsController.upgradeSubscription
);

/**
 * @route   DELETE /api/subscriptions/cancel
 * @desc    Cancel current subscription
 * @access  Private
 */
router.delete(
  '/cancel',
  authenticate,
  validate(cancelSubscriptionSchema),
  subscriptionsController.cancelSubscription
);

/**
 * @route   POST /webhooks/stripe
 * @desc    Handle Stripe webhook events
 * @access  Public (Stripe)
 * @note    This route must use raw body parser
 */
router.post(
  '/webhooks/stripe',
  express.raw({ type: 'application/json' }),
  subscriptionsController.handleWebhook
);

export default router;


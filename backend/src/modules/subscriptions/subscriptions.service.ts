import Stripe from 'stripe';
import { prisma } from '../../config/database';
import { env } from '../../config/env';
import { AppError } from '../../middleware/errorHandler.middleware';
import { PlanType, SubscriptionStatus } from '@prisma/client';
import { CreateSubscriptionInput, UpgradeSubscriptionInput } from './subscriptions.schemas';

const stripe = new Stripe(env.STRIPE_SECRET_KEY, {
  apiVersion: '2024-06-20',
});

// Plan definitions
export const PLANS = {
  FREE: {
    name: 'Free',
    price: 0,
    features: [
      'Basic health tracking',
      'Limited symptom checker',
      'Community access',
      'Basic health tips',
    ],
    stripePriceId: null,
  },
  BASIC: {
    name: 'Basic',
    price: 9.99,
    features: [
      'All Free features',
      'Advanced symptom checker',
      'Medication reminders',
      'Health reports',
      'Priority support',
    ],
    stripePriceId: env.NODE_ENV === 'production' ? 'price_basic_prod' : 'price_basic_test',
  },
  PREMIUM: {
    name: 'Premium',
    price: 19.99,
    features: [
      'All Basic features',
      'AI-powered health insights',
      'Telemedicine consultations',
      'Family health tracking',
      'Personalized health plans',
      '24/7 Priority support',
    ],
    stripePriceId: env.NODE_ENV === 'production' ? 'price_premium_prod' : 'price_premium_test',
  },
};

export class SubscriptionsService {
  /**
   * Get all available plans
   */
  async getAvailablePlans() {
    return Object.entries(PLANS).map(([key, value]) => ({
      planType: key as PlanType,
      ...value,
    }));
  }

  /**
   * Get current user subscription
   */
  async getCurrentSubscription(userId: string) {
    const subscription = await prisma.subscription.findFirst({
      where: {
        userId,
        status: 'ACTIVE',
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!subscription) {
      throw new AppError('No active subscription found', 404);
    }

    return {
      ...subscription,
      plan: PLANS[subscription.planType],
    };
  }

  /**
   * Create a new subscription
   */
  async createSubscription(userId: string, data: CreateSubscriptionInput) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    // Check if user already has an active subscription
    const existingSubscription = await prisma.subscription.findFirst({
      where: {
        userId,
        status: 'ACTIVE',
      },
    });

    if (existingSubscription && existingSubscription.planType !== 'FREE') {
      throw new AppError('You already have an active subscription', 400);
    }

    // Free plan doesn't require Stripe
    if (data.planType === 'FREE') {
      const subscription = await prisma.subscription.create({
        data: {
          userId,
          planType: 'FREE',
          status: 'ACTIVE',
        },
      });

      return {
        ...subscription,
        plan: PLANS.FREE,
      };
    }

    // For paid plans, create Stripe customer if doesn't exist
    let stripeCustomerId = existingSubscription?.stripeCustomerId;

    if (!stripeCustomerId) {
      const customer = await stripe.customers.create({
        email: user.email,
        name: user.name,
        metadata: {
          userId: user.id,
        },
      });
      stripeCustomerId = customer.id;
    }

    // Create Stripe subscription
    const plan = PLANS[data.planType];
    if (!plan.stripePriceId) {
      throw new AppError('Invalid plan selected', 400);
    }

    const stripeSubscription = await stripe.subscriptions.create({
      customer: stripeCustomerId,
      items: [{ price: plan.stripePriceId }],
      payment_behavior: 'default_incomplete',
      payment_settings: { save_default_payment_method: 'on_subscription' },
      expand: ['latest_invoice.payment_intent'],
    });

    // Cancel existing subscription if any
    if (existingSubscription) {
      await prisma.subscription.update({
        where: { id: existingSubscription.id },
        data: { status: 'CANCELLED' },
      });
    }

    // Create subscription in database
    const subscription = await prisma.subscription.create({
      data: {
        userId,
        planType: data.planType,
        status: 'ACTIVE',
        stripeCustomerId,
        stripeSubscriptionId: stripeSubscription.id,
        currentPeriodStart: new Date(stripeSubscription.current_period_start * 1000),
        currentPeriodEnd: new Date(stripeSubscription.current_period_end * 1000),
      },
    });

    return {
      ...subscription,
      plan,
      clientSecret: (stripeSubscription.latest_invoice as Stripe.Invoice)?.payment_intent
        ? ((stripeSubscription.latest_invoice as Stripe.Invoice).payment_intent as Stripe.PaymentIntent).client_secret
        : null,
    };
  }

  /**
   * Upgrade subscription to a higher plan
   */
  async upgradeSubscription(userId: string, data: UpgradeSubscriptionInput) {
    const currentSubscription = await prisma.subscription.findFirst({
      where: {
        userId,
        status: 'ACTIVE',
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!currentSubscription) {
      throw new AppError('No active subscription found', 404);
    }

    // Can't downgrade with this endpoint
    const planHierarchy = { FREE: 0, BASIC: 1, PREMIUM: 2 };
    if (planHierarchy[data.newPlanType] <= planHierarchy[currentSubscription.planType]) {
      throw new AppError('You can only upgrade to a higher plan', 400);
    }

    // If upgrading from free, create new subscription
    if (currentSubscription.planType === 'FREE') {
      return this.createSubscription(userId, { planType: data.newPlanType });
    }

    // Update Stripe subscription
    if (!currentSubscription.stripeSubscriptionId) {
      throw new AppError('Stripe subscription not found', 400);
    }

    const stripeSubscription = await stripe.subscriptions.retrieve(
      currentSubscription.stripeSubscriptionId
    );

    const newPlan = PLANS[data.newPlanType];
    if (!newPlan.stripePriceId) {
      throw new AppError('Invalid plan selected', 400);
    }

    const updatedStripeSubscription = await stripe.subscriptions.update(
      currentSubscription.stripeSubscriptionId,
      {
        items: [
          {
            id: stripeSubscription.items.data[0].id,
            price: newPlan.stripePriceId,
          },
        ],
        proration_behavior: 'create_prorations',
      }
    );

    // Update subscription in database
    const updatedSubscription = await prisma.subscription.update({
      where: { id: currentSubscription.id },
      data: {
        planType: data.newPlanType,
        currentPeriodStart: new Date(updatedStripeSubscription.current_period_start * 1000),
        currentPeriodEnd: new Date(updatedStripeSubscription.current_period_end * 1000),
      },
    });

    return {
      ...updatedSubscription,
      plan: newPlan,
    };
  }

  /**
   * Cancel subscription
   */
  async cancelSubscription(userId: string, cancelAtPeriodEnd: boolean = true) {
    const subscription = await prisma.subscription.findFirst({
      where: {
        userId,
        status: 'ACTIVE',
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!subscription) {
      throw new AppError('No active subscription found', 404);
    }

    if (subscription.planType === 'FREE') {
      throw new AppError('Cannot cancel free subscription', 400);
    }

    if (!subscription.stripeSubscriptionId) {
      throw new AppError('Stripe subscription not found', 400);
    }

    // Cancel Stripe subscription
    if (cancelAtPeriodEnd) {
      await stripe.subscriptions.update(subscription.stripeSubscriptionId, {
        cancel_at_period_end: true,
      });

      await prisma.subscription.update({
        where: { id: subscription.id },
        data: {
          cancelAtPeriodEnd: true,
        },
      });
    } else {
      await stripe.subscriptions.cancel(subscription.stripeSubscriptionId);

      await prisma.subscription.update({
        where: { id: subscription.id },
        data: {
          status: 'CANCELLED',
        },
      });

      // Create a new free subscription
      await prisma.subscription.create({
        data: {
          userId,
          planType: 'FREE',
          status: 'ACTIVE',
        },
      });
    }

    return {
      message: cancelAtPeriodEnd
        ? 'Subscription will be cancelled at the end of the billing period'
        : 'Subscription cancelled immediately',
    };
  }

  /**
   * Handle Stripe webhook events
   */
  async handleWebhook(event: Stripe.Event) {
    switch (event.type) {
      case 'customer.subscription.updated':
        await this.handleSubscriptionUpdated(event.data.object as Stripe.Subscription);
        break;

      case 'customer.subscription.deleted':
        await this.handleSubscriptionDeleted(event.data.object as Stripe.Subscription);
        break;

      case 'invoice.payment_succeeded':
        await this.handlePaymentSucceeded(event.data.object as Stripe.Invoice);
        break;

      case 'invoice.payment_failed':
        await this.handlePaymentFailed(event.data.object as Stripe.Invoice);
        break;

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }
  }

  private async handleSubscriptionUpdated(stripeSubscription: Stripe.Subscription) {
    const subscription = await prisma.subscription.findUnique({
      where: { stripeSubscriptionId: stripeSubscription.id },
    });

    if (!subscription) return;

    await prisma.subscription.update({
      where: { id: subscription.id },
      data: {
        status: stripeSubscription.status.toUpperCase() as SubscriptionStatus,
        currentPeriodStart: new Date(stripeSubscription.current_period_start * 1000),
        currentPeriodEnd: new Date(stripeSubscription.current_period_end * 1000),
        cancelAtPeriodEnd: stripeSubscription.cancel_at_period_end,
      },
    });
  }

  private async handleSubscriptionDeleted(stripeSubscription: Stripe.Subscription) {
    const subscription = await prisma.subscription.findUnique({
      where: { stripeSubscriptionId: stripeSubscription.id },
    });

    if (!subscription) return;

    await prisma.subscription.update({
      where: { id: subscription.id },
      data: { status: 'CANCELLED' },
    });

    // Create a free subscription
    await prisma.subscription.create({
      data: {
        userId: subscription.userId,
        planType: 'FREE',
        status: 'ACTIVE',
      },
    });
  }

  private async handlePaymentSucceeded(invoice: Stripe.Invoice) {
    if (!invoice.subscription) return;

    const subscription = await prisma.subscription.findUnique({
      where: { stripeSubscriptionId: invoice.subscription as string },
    });

    if (!subscription) return;

    await prisma.payment.create({
      data: {
        userId: subscription.userId,
        subscriptionId: subscription.id,
        amount: invoice.amount_paid / 100, // Convert cents to dollars
        currency: invoice.currency.toUpperCase(),
        provider: 'STRIPE',
        status: 'COMPLETED',
        stripePaymentIntentId: invoice.payment_intent as string,
      },
    });
  }

  private async handlePaymentFailed(invoice: Stripe.Invoice) {
    if (!invoice.subscription) return;

    const subscription = await prisma.subscription.findUnique({
      where: { stripeSubscriptionId: invoice.subscription as string },
    });

    if (!subscription) return;

    await prisma.subscription.update({
      where: { id: subscription.id },
      data: { status: 'PAST_DUE' },
    });
  }
}

export const subscriptionsService = new SubscriptionsService();


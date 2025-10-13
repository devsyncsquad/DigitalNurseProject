import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import Stripe from 'stripe';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';
import { UpgradeSubscriptionDto } from './dto/upgrade-subscription.dto';
import { SUBSCRIPTION_PLANS } from './constants/plans.constant';

@Injectable()
export class SubscriptionsService {
  private stripe: Stripe;

  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
  ) {
    const stripeKey = this.configService.get<string>('STRIPE_SECRET_KEY');
    if (stripeKey && stripeKey !== 'your-stripe-secret-key') {
      this.stripe = new Stripe(stripeKey, {
        apiVersion: '2025-09-30.clover',
      });
    } else {
      // Initialize with dummy key for development/testing
      this.stripe = new Stripe('sk_test_dummy_key_for_development', {
        apiVersion: '2025-09-30.clover',
      });
    }
  }

  async getPlans() {
    return Object.entries(SUBSCRIPTION_PLANS).map(([key, value]) => ({
      planType: key,
      ...value,
    }));
  }

  async getCurrentSubscription(userId: string) {
    const subscription = await this.prisma.subscription.findFirst({
      where: {
        userId,
        status: 'ACTIVE',
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    if (!subscription) {
      throw new NotFoundException('No active subscription found');
    }

    const planDetails = SUBSCRIPTION_PLANS[subscription.planType];

    return {
      ...subscription,
      planDetails,
    };
  }

  async createSubscription(
    userId: string,
    createSubscriptionDto: CreateSubscriptionDto,
  ) {
    const { planType } = createSubscriptionDto;

    if (planType === 'FREE') {
      throw new BadRequestException(
        'Cannot create a FREE subscription through this endpoint',
      );
    }

    // Get user
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Check for existing active subscription
    const existingSubscription = await this.prisma.subscription.findFirst({
      where: {
        userId,
        status: 'ACTIVE',
      },
    });

    if (existingSubscription && existingSubscription.planType !== 'FREE') {
      throw new BadRequestException(
        'User already has an active paid subscription',
      );
    }

    // Create or retrieve Stripe customer
    let stripeCustomerId = existingSubscription?.stripeCustomerId;

    if (!stripeCustomerId) {
      const customer = await this.stripe.customers.create({
        email: user.email,
        name: user.name || undefined,
        metadata: {
          userId: user.id,
        },
      });
      stripeCustomerId = customer.id;
    }

    // Create Stripe checkout session
    const planDetails = SUBSCRIPTION_PLANS[planType];

    const session = await this.stripe.checkout.sessions.create({
      customer: stripeCustomerId,
      payment_method_types: ['card'],
      line_items: [
        {
          price: planDetails.stripePriceId,
          quantity: 1,
        },
      ],
      mode: 'subscription',
      success_url: `${this.configService.get<string>('FRONTEND_URL')}/subscription/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${this.configService.get<string>('FRONTEND_URL')}/subscription/cancel`,
      metadata: {
        userId,
        planType,
      },
    });

    // Update or create subscription in pending state
    if (existingSubscription) {
      await this.prisma.subscription.update({
        where: { id: existingSubscription.id },
        data: {
          status: 'PENDING',
          planType,
          stripeCustomerId,
        },
      });
    } else {
      await this.prisma.subscription.create({
        data: {
          userId,
          planType,
          status: 'PENDING',
          stripeCustomerId,
        },
      });
    }

    return {
      sessionId: session.id,
      sessionUrl: session.url,
    };
  }

  async upgradeSubscription(
    userId: string,
    upgradeSubscriptionDto: UpgradeSubscriptionDto,
  ) {
    const { newPlanType } = upgradeSubscriptionDto;

    const currentSubscription = await this.prisma.subscription.findFirst({
      where: {
        userId,
        status: 'ACTIVE',
      },
    });

    if (!currentSubscription) {
      throw new NotFoundException('No active subscription found');
    }

    if (currentSubscription.planType === newPlanType) {
      throw new BadRequestException('User is already on this plan');
    }

    // Check if upgrade is valid (prevent downgrade through this endpoint)
    const planHierarchy = { FREE: 0, BASIC: 1, PREMIUM: 2 };
    if (
      planHierarchy[newPlanType] <= planHierarchy[currentSubscription.planType]
    ) {
      throw new BadRequestException(
        'Use downgrade or cancel endpoint for this operation',
      );
    }

    if (!currentSubscription.stripeSubscriptionId) {
      // User is on FREE plan, redirect to create subscription
      return this.createSubscription(userId, { planType: newPlanType });
    }

    // Update Stripe subscription
    const newPlanDetails = SUBSCRIPTION_PLANS[newPlanType];

    const retrievedSubscription = await this.stripe.subscriptions.retrieve(
      currentSubscription.stripeSubscriptionId,
    );

    const updatedStripeSubscription = await this.stripe.subscriptions.update(
      currentSubscription.stripeSubscriptionId,
      {
        items: [
          {
            id: retrievedSubscription.items.data[0].id,
            price: newPlanDetails.stripePriceId || undefined,
          },
        ],
        proration_behavior: 'create_prorations',
      },
    );

    // Update subscription in database
    const stripeSubData = updatedStripeSubscription as any;
    const updatedSubscription = await this.prisma.subscription.update({
      where: { id: currentSubscription.id },
      data: {
        planType: newPlanType,
        stripePriceId: newPlanDetails.stripePriceId,
        currentPeriodStart: stripeSubData.current_period_start
          ? new Date(stripeSubData.current_period_start * 1000)
          : undefined,
        currentPeriodEnd: stripeSubData.current_period_end
          ? new Date(stripeSubData.current_period_end * 1000)
          : undefined,
      },
    });

    return {
      message: 'Subscription upgraded successfully',
      subscription: updatedSubscription,
    };
  }

  async continueWithExistingPlan(userId: string) {
    const subscription = await this.getCurrentSubscription(userId);

    return {
      message: 'Continuing with existing plan',
      subscription,
    };
  }

  async cancelSubscription(userId: string) {
    const subscription = await this.prisma.subscription.findFirst({
      where: {
        userId,
        status: 'ACTIVE',
      },
    });

    if (!subscription) {
      throw new NotFoundException('No active subscription found');
    }

    if (subscription.planType === 'FREE') {
      throw new BadRequestException('Cannot cancel FREE subscription');
    }

    if (!subscription.stripeSubscriptionId) {
      throw new BadRequestException('No Stripe subscription found');
    }

    // Cancel Stripe subscription at period end
    await this.stripe.subscriptions.update(subscription.stripeSubscriptionId, {
      cancel_at_period_end: true,
    });

    // Update subscription
    const updatedSubscription = await this.prisma.subscription.update({
      where: { id: subscription.id },
      data: {
        cancelAtPeriodEnd: true,
        canceledAt: new Date(),
      },
    });

    return {
      message:
        'Subscription will be cancelled at the end of the billing period',
      subscription: updatedSubscription,
    };
  }

  async handleStripeWebhook(event: Stripe.Event) {
    switch (event.type) {
      case 'checkout.session.completed':
        await this.handleCheckoutSessionCompleted(
          event.data.object as Stripe.Checkout.Session,
        );
        break;

      case 'customer.subscription.updated':
        await this.handleSubscriptionUpdated(
          event.data.object as Stripe.Subscription,
        );
        break;

      case 'customer.subscription.deleted':
        await this.handleSubscriptionDeleted(
          event.data.object as Stripe.Subscription,
        );
        break;

      case 'invoice.payment_succeeded':
        await this.handleInvoicePaymentSucceeded(
          event.data.object as Stripe.Invoice,
        );
        break;

      case 'invoice.payment_failed':
        await this.handleInvoicePaymentFailed(
          event.data.object as Stripe.Invoice,
        );
        break;

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }
  }

  private async handleCheckoutSessionCompleted(
    session: Stripe.Checkout.Session,
  ) {
    const userId = session.metadata?.userId;
    const planType = session.metadata?.planType;

    if (!userId || !planType) {
      console.error('Missing metadata in checkout session');
      return;
    }

    const stripeSubscription = await this.stripe.subscriptions.retrieve(
      session.subscription as string,
    );

    // Update subscription to ACTIVE
    await this.prisma.subscription.updateMany({
      where: {
        userId,
        status: 'PENDING',
      },
      data: {
        status: 'ACTIVE',
        stripeSubscriptionId: stripeSubscription.id,
        stripePriceId: stripeSubscription.items.data[0].price.id,
        currentPeriodStart: (stripeSubscription as any).current_period_start
          ? new Date((stripeSubscription as any).current_period_start * 1000)
          : undefined,
        currentPeriodEnd: (stripeSubscription as any).current_period_end
          ? new Date((stripeSubscription as any).current_period_end * 1000)
          : undefined,
      },
    });

    // Create payment record
    await this.prisma.payment.create({
      data: {
        userId,
        amount: (session.amount_total || 0) / 100,
        currency: session.currency?.toUpperCase() || 'USD',
        provider: 'STRIPE',
        status: 'COMPLETED',
        stripePaymentIntentId: session.payment_intent as string,
      },
    });
  }

  private async handleSubscriptionUpdated(subscription: Stripe.Subscription) {
    const subData = subscription as any;
    await this.prisma.subscription.updateMany({
      where: {
        stripeSubscriptionId: subscription.id,
      },
      data: {
        status: subscription.status === 'active' ? 'ACTIVE' : 'CANCELLED',
        currentPeriodStart: subData.current_period_start
          ? new Date(subData.current_period_start * 1000)
          : undefined,
        currentPeriodEnd: subData.current_period_end
          ? new Date(subData.current_period_end * 1000)
          : undefined,
        cancelAtPeriodEnd: subData.cancel_at_period_end || false,
      },
    });
  }

  private async handleSubscriptionDeleted(subscription: Stripe.Subscription) {
    const existingSubscription = await this.prisma.subscription.findFirst({
      where: {
        stripeSubscriptionId: subscription.id,
      },
    });

    if (existingSubscription) {
      // Mark subscription as expired
      await this.prisma.subscription.update({
        where: { id: existingSubscription.id },
        data: {
          status: 'EXPIRED',
        },
      });

      // Create new FREE subscription
      await this.prisma.subscription.create({
        data: {
          userId: existingSubscription.userId,
          planType: 'FREE',
          status: 'ACTIVE',
        },
      });
    }
  }

  private async handleInvoicePaymentSucceeded(invoice: Stripe.Invoice) {
    const invoiceData = invoice as any;
    if (!invoiceData.subscription) return;

    const subscription = await this.prisma.subscription.findFirst({
      where: {
        stripeSubscriptionId: invoiceData.subscription as string,
      },
    });

    if (subscription) {
      await this.prisma.payment.create({
        data: {
          userId: subscription.userId,
          subscriptionId: subscription.id,
          amount: (invoice.amount_paid || 0) / 100,
          currency: invoice.currency?.toUpperCase() || 'USD',
          provider: 'STRIPE',
          status: 'COMPLETED',
          stripePaymentIntentId: (invoiceData.payment_intent as string) || null,
        },
      });
    }
  }

  private async handleInvoicePaymentFailed(invoice: Stripe.Invoice) {
    const invoiceData = invoice as any;
    if (!invoiceData.subscription) return;

    const subscription = await this.prisma.subscription.findFirst({
      where: {
        stripeSubscriptionId: invoiceData.subscription as string,
      },
    });

    if (subscription) {
      await this.prisma.payment.create({
        data: {
          userId: subscription.userId,
          subscriptionId: subscription.id,
          amount: (invoice.amount_due || 0) / 100,
          currency: invoice.currency?.toUpperCase() || 'USD',
          provider: 'STRIPE',
          status: 'FAILED',
          failureReason: 'Payment failed',
        },
      });
    }
  }
}

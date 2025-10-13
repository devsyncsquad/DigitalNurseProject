export const SUBSCRIPTION_PLANS = {
  FREE: {
    name: 'Free Plan',
    price: 0,
    currency: 'USD',
    features: ['Basic access to platform', 'Limited features', '1 user'],
    stripePriceId: null,
  },
  BASIC: {
    name: 'Basic Plan',
    price: 9.99,
    currency: 'USD',
    features: [
      'All Free features',
      'Extended features access',
      'Up to 5 users',
      'Email support',
    ],
    stripePriceId: process.env.STRIPE_BASIC_PRICE_ID || 'price_basic',
  },
  PREMIUM: {
    name: 'Premium Plan',
    price: 29.99,
    currency: 'USD',
    features: [
      'All Basic features',
      'Full platform access',
      'Unlimited users',
      'Priority support',
      'Advanced analytics',
      'Custom integrations',
    ],
    stripePriceId: process.env.STRIPE_PREMIUM_PRICE_ID || 'price_premium',
  },
};

import { Strategy as GoogleStrategy, Profile, VerifyCallback } from 'passport-google-oauth20';
import { env } from '../../../config/env';
import { prisma } from '../../../config/database';

export const googleStrategy = new GoogleStrategy(
  {
    clientID: env.GOOGLE_CLIENT_ID,
    clientSecret: env.GOOGLE_CLIENT_SECRET,
    callbackURL: env.GOOGLE_CALLBACK_URL,
    scope: ['profile', 'email'],
  },
  async (_accessToken: string, _refreshToken: string, profile: Profile, done: VerifyCallback) => {
    try {
      const email = profile.emails?.[0]?.value;

      if (!email) {
        return done(new Error('No email found in Google profile'), undefined);
      }

      // Check if user already exists
      let user = await prisma.user.findUnique({
        where: { email },
      });

      if (user) {
        // Update Google ID if not set
        if (!user.googleId) {
          user = await prisma.user.update({
            where: { id: user.id },
            data: { googleId: profile.id },
          });
        }
      } else {
        // Create new user
        user = await prisma.user.create({
          data: {
            email,
            name: profile.displayName || 'Google User',
            googleId: profile.id,
            emailVerified: true, // Google emails are verified
            profilePicture: profile.photos?.[0]?.value,
          },
        });

        // Create a free subscription for new user
        await prisma.subscription.create({
          data: {
            userId: user.id,
            planType: 'FREE',
            status: 'ACTIVE',
          },
        });
      }

      return done(null, user);
    } catch (error) {
      return done(error as Error, undefined);
    }
  }
);


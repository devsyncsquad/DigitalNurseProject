import passport from 'passport';
import { jwtStrategy } from '../modules/auth/strategies/jwt.strategy';
import { googleStrategy } from '../modules/auth/strategies/google.strategy';
import { localStrategy } from '../modules/auth/strategies/local.strategy';

/**
 * Configure all Passport strategies
 */
export const configurePassport = () => {
  // JWT Strategy for API authentication
  passport.use('jwt', jwtStrategy);

  // Google OAuth Strategy
  passport.use('google', googleStrategy);

  // Local Strategy for email/password authentication
  passport.use('local', localStrategy);
};

export default passport;


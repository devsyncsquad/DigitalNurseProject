import { Strategy as LocalStrategy } from 'passport-local';
import bcrypt from 'bcrypt';
import { prisma } from '../../../config/database';

export const localStrategy = new LocalStrategy(
  {
    usernameField: 'email',
    passwordField: 'password',
  },
  async (email, password, done) => {
    try {
      // Find user by email
      const user = await prisma.user.findUnique({
        where: { email },
      });

      if (!user) {
        return done(null, false, { message: 'Invalid email or password' });
      }

      // Check if user has a password (not OAuth only)
      if (!user.password) {
        return done(null, false, {
          message: 'Please login with Google',
        });
      }

      // Verify password
      const isValidPassword = await bcrypt.compare(password, user.password);

      if (!isValidPassword) {
        return done(null, false, { message: 'Invalid email or password' });
      }

      // Check if email is verified
      if (!user.emailVerified) {
        return done(null, false, { message: 'Please verify your email first' });
      }

      return done(null, user);
    } catch (error) {
      return done(error);
    }
  }
);


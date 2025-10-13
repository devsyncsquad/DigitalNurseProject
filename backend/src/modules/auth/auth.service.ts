import bcrypt from 'bcrypt';
import crypto from 'crypto';
import { prisma } from '../../config/database';
import { generateTokenPair, verifyRefreshToken } from '../../utils/jwt.utils';
import { RegisterInput, LoginInput } from './auth.schemas';
import { User } from '@prisma/client';
import { AppError } from '../../middleware/errorHandler.middleware';

export class AuthService {
  /**
   * Register a new user
   */
  async register(data: RegisterInput) {
    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (existingUser) {
      throw new AppError('User with this email already exists', 400);
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(data.password, 10);

    // Generate email verification token
    const verificationToken = crypto.randomBytes(32).toString('hex');

    // Create user
    const user = await prisma.user.create({
      data: {
        email: data.email,
        password: hashedPassword,
        name: data.name,
        verificationToken,
        emailVerified: false,
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

    // TODO: Send verification email
    // await sendVerificationEmail(user.email, verificationToken);

    return {
      user: this.sanitizeUser(user),
      verificationToken, // Remove this in production, only for development
    };
  }

  /**
   * Login user
   */
  async login(data: LoginInput) {
    // Find user
    const user = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (!user) {
      throw new AppError('Invalid email or password', 401);
    }

    // Check if user has a password (not OAuth only)
    if (!user.password) {
      throw new AppError('Please login with Google', 400);
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(data.password, user.password);

    if (!isValidPassword) {
      throw new AppError('Invalid email or password', 401);
    }

    // Check if email is verified
    if (!user.emailVerified) {
      throw new AppError('Please verify your email first', 403);
    }

    // Generate tokens
    const tokens = generateTokenPair({
      userId: user.id,
      email: user.email,
    });

    return {
      user: this.sanitizeUser(user),
      ...tokens,
    };
  }

  /**
   * Verify email with token
   */
  async verifyEmail(token: string) {
    const user = await prisma.user.findUnique({
      where: { verificationToken: token },
    });

    if (!user) {
      throw new AppError('Invalid or expired verification token', 400);
    }

    if (user.emailVerified) {
      throw new AppError('Email already verified', 400);
    }

    // Update user
    const updatedUser = await prisma.user.update({
      where: { id: user.id },
      data: {
        emailVerified: true,
        verificationToken: null,
      },
    });

    // Generate tokens
    const tokens = generateTokenPair({
      userId: updatedUser.id,
      email: updatedUser.email,
    });

    return {
      user: this.sanitizeUser(updatedUser),
      ...tokens,
    };
  }

  /**
   * Refresh access token
   */
  async refreshToken(refreshToken: string) {
    try {
      const payload = verifyRefreshToken(refreshToken);

      const user = await prisma.user.findUnique({
        where: { id: payload.userId },
      });

      if (!user) {
        throw new AppError('User not found', 404);
      }

      // Generate new token pair
      const tokens = generateTokenPair({
        userId: user.id,
        email: user.email,
      });

      return {
        user: this.sanitizeUser(user),
        ...tokens,
      };
    } catch (error) {
      throw new AppError('Invalid or expired refresh token', 401);
    }
  }

  /**
   * Handle Google OAuth callback
   */
  async handleGoogleCallback(user: User) {
    // Generate tokens
    const tokens = generateTokenPair({
      userId: user.id,
      email: user.email,
    });

    return {
      user: this.sanitizeUser(user),
      ...tokens,
    };
  }

  /**
   * Remove sensitive data from user object
   */
  private sanitizeUser(user: User) {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { password, verificationToken, ...sanitizedUser } = user;
    return sanitizedUser;
  }
}

export const authService = new AuthService();


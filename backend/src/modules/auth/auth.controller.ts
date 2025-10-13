import { Request, Response } from 'express';
import { authService } from './auth.service';
import { sendSuccess, sendCreated } from '../../utils/response.utils';
import { asyncHandler } from '../../middleware/errorHandler.middleware';
import { RegisterInput, LoginInput, VerifyEmailInput, RefreshTokenInput } from './auth.schemas';
import { User } from '@prisma/client';

export class AuthController {
  /**
   * Register a new user
   */
  register = asyncHandler(async (req: Request, res: Response) => {
    const data: RegisterInput = req.body;
    const result = await authService.register(data);

    return sendCreated(
      res,
      result,
      'Registration successful. Please check your email to verify your account.'
    );
  });

  /**
   * Login user
   */
  login = asyncHandler(async (req: Request, res: Response) => {
    const data: LoginInput = req.body;
    const result = await authService.login(data);

    return sendSuccess(res, result, 'Login successful');
  });

  /**
   * Verify email
   */
  verifyEmail = asyncHandler(async (req: Request, res: Response) => {
    const data: VerifyEmailInput = req.body;
    const result = await authService.verifyEmail(data.token);

    return sendSuccess(res, result, 'Email verified successfully');
  });

  /**
   * Refresh access token
   */
  refreshToken = asyncHandler(async (req: Request, res: Response) => {
    const data: RefreshTokenInput = req.body;
    const result = await authService.refreshToken(data.refreshToken);

    return sendSuccess(res, result, 'Token refreshed successfully');
  });

  /**
   * Google OAuth callback handler
   */
  googleCallback = asyncHandler(async (req: Request, res: Response) => {
    const user = req.user as User;
    const result = await authService.handleGoogleCallback(user);

    // In production, redirect to frontend with tokens as query params
    // or set secure httpOnly cookies
    return sendSuccess(res, result, 'Google authentication successful');
  });

  /**
   * Get current authenticated user
   */
  getCurrentUser = asyncHandler(async (req: Request, res: Response) => {
    const user = req.user;

    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'Not authenticated',
      });
    }

    // Remove sensitive data - password and verificationToken are already excluded by Prisma
    return sendSuccess(res, user);
  });
}

export const authController = new AuthController();


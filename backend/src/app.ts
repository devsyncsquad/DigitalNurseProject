import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import passport from 'passport';
import swaggerUi from 'swagger-ui-express';
import { env } from './config/env';
import { configurePassport } from './config/passport';
import { errorHandler, notFoundHandler } from './middleware/errorHandler.middleware';
import { logger } from './utils/logger.utils';
import { swaggerSpec } from './config/swagger';

// Import routes
// import authRoutes from './modules/auth/auth.routes';
// import usersRoutes from './modules/users/users.routes';
// import subscriptionsRoutes from './modules/subscriptions/subscriptions.routes';
import medicationsRoutes from './modules/medications/medications.routes';
import vitalsRoutes from './modules/vitals/vitals.routes';
import elderAssignmentsRoutes from './modules/elder-assignments/elder-assignments.routes';
import notificationsRoutes from './modules/notifications/notifications.routes';
import lookupsRoutes from './modules/lookups/lookups.routes';

/**
 * Create and configure Express application
 */
export const createApp = (): Application => {
  const app = express();

  // Security middleware
  app.use(helmet());

  // CORS configuration
  app.use(
    cors({
      origin: env.FRONTEND_URL,
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization'],
    })
  );

  // Request logging
  if (env.NODE_ENV === 'development') {
    app.use(morgan('dev'));
  } else {
    app.use(morgan('combined'));
  }

  // BigInt serialization fix for JSON responses
  (BigInt.prototype as any).toJSON = function () {
    return this.toString();
  };

  // Body parsers
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  // Initialize Passport - temporarily disabled for testing
  // configurePassport();
  // app.use(passport.initialize());

  // Rate limiting for auth routes
  const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 10, // Limit each IP to 10 requests per windowMs
    message: 'Too many authentication attempts, please try again later',
    standardHeaders: true,
    legacyHeaders: false,
  });

  // Swagger API Documentation
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
    customCss: '.swagger-ui .topbar { display: none }',
    customSiteTitle: 'Digital Nurse API Docs',
  }));

  /**
   * @openapi
   * /health:
   *   get:
   *     tags:
   *       - Health
   *     summary: Health check endpoint
   *     description: Returns the server health status
   *     responses:
   *       200:
   *         description: Server is running
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 success:
   *                   type: boolean
   *                   example: true
   *                 message:
   *                   type: string
   *                   example: Digital Nurse API is running
   *                 timestamp:
   *                   type: string
   *                   format: date-time
   *                 environment:
   *                   type: string
   *                   example: development
   */
  app.get('/health', (_req: Request, res: Response) => {
    res.status(200).json({
      success: true,
      message: 'Digital Nurse API is running',
      timestamp: new Date().toISOString(),
      environment: env.NODE_ENV,
    });
  });

  // API routes
  // Temporarily disabled auth routes for testing
  // app.use('/api/auth', authLimiter, authRoutes);
  // app.use('/api/users', usersRoutes);
  // app.use('/api/subscriptions', subscriptionsRoutes);

  // New API routes - ready for testing!
  app.use('/api/medications', medicationsRoutes);
  app.use('/api/vitals', vitalsRoutes);
  app.use('/api/elder-assignments', elderAssignmentsRoutes);
  app.use('/api/notifications', notificationsRoutes);
  app.use('/api/lookups', lookupsRoutes);

  // 404 handler
  app.use(notFoundHandler);

  // Global error handler (must be last)
  app.use(errorHandler);

  logger.info('Express app configured successfully');

  return app;
};

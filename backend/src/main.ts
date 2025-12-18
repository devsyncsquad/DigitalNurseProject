import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { AuthService } from './auth/auth.service';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    rawBody: true, // Required for Stripe webhooks
  });

  // Enable CORS for Flutter app
  app.enableCors({
    origin: process.env.FRONTEND_URL || '*',
    credentials: true,
  });

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );

  // API prefix
  app.setGlobalPrefix('api');

  // Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('Digital Nurse API')
    .setDescription('API documentation for Digital Nurse application')
    .setVersion('1.0')
    .addBearerAuth()
    .addTag('Authentication', 'Authentication endpoints')
    .addTag('Users', 'User management endpoints')
    .addTag('Subscriptions', 'Subscription management endpoints')
    .addTag('Medications', 'Medication management endpoints')
    .addTag('Vitals', 'Health vital measurements endpoints')
    .addTag('Caregivers', 'Caregiver management endpoints')
    .addTag('Lifestyle', 'Diet and exercise logging endpoints')
    .addTag('Documents', 'Document management endpoints')
    .addTag('Notifications', 'Notification management endpoints')
    .addTag('Lookups', 'Lookup values endpoints')
    .addTag('Devices', 'Device management endpoints')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  // Email verification GET endpoint (outside /api prefix)
  const authService = app.get(AuthService);
  const expressApp = app.getHttpAdapter().getInstance();
  
  expressApp.get('/email-verification', async (req: any, res: any) => {
    const token = req.query.token as string;
    
    if (!token) {
      return res.status(400).send(`
        <!DOCTYPE html>
        <html>
        <head>
          <title>Email Verification - Digital Nurse</title>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
              display: flex;
              justify-content: center;
              align-items: center;
              min-height: 100vh;
              margin: 0;
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              color: #333;
            }
            .container {
              background: white;
              padding: 2rem;
              border-radius: 12px;
              box-shadow: 0 10px 40px rgba(0,0,0,0.2);
              max-width: 500px;
              text-align: center;
            }
            h1 { color: #e74c3c; margin-top: 0; }
            p { line-height: 1.6; color: #666; }
            .error-icon { font-size: 48px; margin-bottom: 1rem; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="error-icon">⚠️</div>
            <h1>Verification Link Invalid</h1>
            <p>No verification token was provided. Please check your email and click the verification link again.</p>
          </div>
        </body>
        </html>
      `);
    }

    try {
      const result = await authService.verifyEmail(token);
      return res.status(200).send(`
        <!DOCTYPE html>
        <html>
        <head>
          <title>Email Verified - Digital Nurse</title>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
              display: flex;
              justify-content: center;
              align-items: center;
              min-height: 100vh;
              margin: 0;
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              color: #333;
            }
            .container {
              background: white;
              padding: 2rem;
              border-radius: 12px;
              box-shadow: 0 10px 40px rgba(0,0,0,0.2);
              max-width: 500px;
              text-align: center;
            }
            h1 { color: #27ae60; margin-top: 0; }
            p { line-height: 1.6; color: #666; }
            .success-icon { font-size: 48px; margin-bottom: 1rem; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="success-icon">✅</div>
            <h1>Email Verified Successfully!</h1>
            <p>Your email address has been verified. You can now log in to your Digital Nurse account.</p>
            <p style="margin-top: 1.5rem; font-size: 0.9rem; color: #999;">You can close this window and return to the app.</p>
          </div>
        </body>
        </html>
      `);
    } catch (error: any) {
      const statusCode = error.status || 500;
      const message = error.message || 'An error occurred during verification';
      const isExpired = message.includes('expired');
      const isAlreadyVerified = message.includes('already been verified');
      const isInvalid = message.includes('Invalid');
      
      let errorTitle = 'Verification Failed';
      let errorIcon = '❌';
      let errorMessage = message;
      
      if (isExpired) {
        errorTitle = 'Verification Link Expired';
        errorIcon = '⏰';
        errorMessage = 'This verification link has expired. Please request a new verification email.';
      } else if (isAlreadyVerified) {
        errorTitle = 'Already Verified';
        errorIcon = 'ℹ️';
        errorMessage = 'This email address has already been verified. You can log in to your account.';
      } else if (isInvalid) {
        errorTitle = 'Invalid Verification Link';
        errorIcon = '⚠️';
        errorMessage = 'This verification link is invalid. Please check your email and try again.';
      }

      return res.status(statusCode).send(`
        <!DOCTYPE html>
        <html>
        <head>
          <title>${errorTitle} - Digital Nurse</title>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
              display: flex;
              justify-content: center;
              align-items: center;
              min-height: 100vh;
              margin: 0;
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              color: #333;
            }
            .container {
              background: white;
              padding: 2rem;
              border-radius: 12px;
              box-shadow: 0 10px 40px rgba(0,0,0,0.2);
              max-width: 500px;
              text-align: center;
            }
            h1 { 
              color: ${isAlreadyVerified ? '#3498db' : '#e74c3c'}; 
              margin-top: 0; 
            }
            p { line-height: 1.6; color: #666; }
            .error-icon { font-size: 48px; margin-bottom: 1rem; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="error-icon">${errorIcon}</div>
            <h1>${errorTitle}</h1>
            <p>${errorMessage}</p>
          </div>
        </body>
        </html>
      `);
    }
  });

  const port = process.env.PORT || 3000;
  await app.listen(port);

  console.log(`🚀 Application is running on: http://localhost:${port}`);
  console.log(`📚 Swagger documentation: http://localhost:${port}/api/docs`);
}
bootstrap();

# Digital Nurse - Backend API

NestJS backend application for Digital Nurse with authentication, user management, and subscription features.

## 🚀 Quick Start

### Prerequisites

- Node.js v18+
- PostgreSQL 14+
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Configure your .env file with actual values
```

### Database Setup

```bash
# Generate Prisma client
npx prisma generate

# Run migrations
npx prisma migrate dev --name init

# (Optional) Seed database
npx prisma db seed
```

### Running the Application

```bash
# Development mode with hot reload
npm run start:dev

# Production mode
npm run build
npm run start:prod

# Debug mode
npm run start:debug
```

### Access Points

- **API Base URL**: http://localhost:3000/api
- **Swagger Documentation**: http://localhost:3000/api/docs
- **Health Check**: http://localhost:3000/api/health

## 📁 Project Structure

```
backend/
├── src/
│   ├── auth/                # Authentication module
│   ├── users/               # User management module
│   ├── subscriptions/       # Subscription & payment module
│   ├── common/              # Shared utilities, guards, decorators
│   ├── prisma/              # Prisma database module
│   ├── app.module.ts        # Root application module
│   └── main.ts              # Application entry point
├── prisma/
│   └── schema.prisma        # Database schema
├── test/                    # E2E tests
├── .env.example             # Environment variables template
├── nest-cli.json            # NestJS CLI configuration
├── package.json
└── tsconfig.json
```

## 🔑 Authentication

The API uses JWT (JSON Web Tokens) for authentication. Three authentication strategies are implemented:

1. **Local Strategy**: Email/password authentication
2. **JWT Strategy**: Token-based API authentication
3. **Google OAuth**: Google sign-in integration

### Using Authentication

Most endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

Public endpoints (no authentication required):

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/google`
- `GET /api/auth/google/callback`
- `POST /api/auth/verify-email`
- `POST /api/auth/refresh-token`
- `GET /api/subscriptions/plans`
- `GET /api/health`

## 📊 Database

### Prisma Commands

```bash
# Generate Prisma client
npx prisma generate

# Create a migration
npx prisma migrate dev --name migration_name

# Apply migrations in production
npx prisma migrate deploy

# Open Prisma Studio (database GUI)
npx prisma studio

# Reset database (WARNING: deletes all data)
npx prisma migrate reset
```

### Models

- **User**: User accounts with profile information
- **Subscription**: User subscription plans and status
- **Payment**: Payment transactions and history

## 💳 Stripe Integration

### Setup Webhook

1. Install Stripe CLI: https://stripe.com/docs/stripe-cli
2. Login to Stripe: `stripe login`
3. Forward webhooks to local:
   ```bash
   stripe listen --forward-to localhost:3000/api/subscriptions/webhooks/stripe
   ```
4. Copy the webhook signing secret to `.env`

### Supported Events

- `checkout.session.completed`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `invoice.payment_succeeded`
- `invoice.payment_failed`

## 🧪 Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov

# Watch mode
npm run test:watch
```

## 📝 Scripts

```bash
# Development
npm run start              # Start application
npm run start:dev          # Start with hot reload
npm run start:debug        # Start in debug mode

# Building
npm run build              # Build for production

# Code Quality
npm run format             # Format code with Prettier
npm run lint               # Lint code with ESLint

# Testing
npm run test               # Run unit tests
npm run test:e2e           # Run E2E tests
npm run test:cov           # Generate coverage report
```

## 🔧 Configuration

All configuration is done through environment variables in `.env` file.

See `.env.example` for required variables:

- Database connection
- JWT secrets
- Google OAuth credentials
- Stripe API keys
- Application settings

## 📚 API Documentation

Interactive API documentation is available at `/api/docs` when the server is running.

The documentation includes:

- All available endpoints
- Request/response schemas
- Authentication requirements
- Try-it-out functionality

## 🐛 Debugging

### VSCode Debug Configuration

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug NestJS",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "start:debug"],
      "console": "integratedTerminal",
      "restart": true,
      "protocol": "inspector",
      "skipFiles": ["<node_internals>/**"]
    }
  ]
}
```

## 🚢 Deployment

### Railway Deployment (Recommended for Testing)

Deploy to Railway's free tier for testing with your mobile app:

- **[Railway Deployment Guide](./DEPLOYMENT.md)** - Complete step-by-step guide
- **[Mobile App Configuration](./MOBILE_CONFIG.md)** - Configure mobile app to use deployed API

### Production Build

```bash
# Build the application
npm run build

# Start in production mode
NODE_ENV=production npm run start:prod
```

### Environment Variables

See `.env.example` for all required environment variables. Copy it to `.env` and configure:

```bash
cp .env.example .env
# Edit .env with your actual values
```

## 📖 Additional Documentation

- [Main Project Plan](../ProjectPlan.md)
- [NestJS Documentation](https://docs.nestjs.com/)
- [Prisma Documentation](https://www.prisma.io/docs/)

## 🤝 Contributing

1. Create a feature branch from `develop`
2. Make your changes
3. Write/update tests
4. Ensure all tests pass
5. Submit a pull request

## 📄 License

Proprietary and confidential.

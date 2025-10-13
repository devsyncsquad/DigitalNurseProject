# Digital Nurse - Project Plan

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Tech Stack](#tech-stack)
3. [Architecture](#architecture)
4. [Database Schema](#database-schema)
5. [API Endpoints](#api-endpoints)
6. [Authentication Flow](#authentication-flow)
7. [Subscription Flow](#subscription-flow)
8. [Setup Instructions](#setup-instructions)
9. [Environment Variables](#environment-variables)
10. [Development Workflow](#development-workflow)
11. [Deployment Guidelines](#deployment-guidelines)
12. [Testing Strategy](#testing-strategy)

---

## 🎯 Project Overview

Digital Nurse is a healthcare application with a comprehensive onboarding and subscription management system. The application guides new users through registration, email verification, profile completion, and subscription selection, providing a seamless transition from signup to active usage.

### Key Features

- **User Registration**: Email/password or Google OAuth authentication
- **Email Verification**: Secure email confirmation flow
- **Profile Management**: Complete user profile with personal details
- **Subscription Plans**: FREE, BASIC, and PREMIUM tiers
- **Payment Integration**: Stripe payment gateway (with plans for Easypaisa and JazzCash)
- **User Management**: Profile updates and onboarding tracking

---

## 🛠️ Tech Stack

### Backend

- **Framework**: NestJS (Node.js)
- **Language**: TypeScript
- **Database**: PostgreSQL
- **ORM**: Prisma
- **Authentication**: Passport.js (Local, JWT, Google OAuth)
- **Payment**: Stripe SDK
- **API Documentation**: Swagger/OpenAPI
- **Validation**: class-validator, class-transformer

### Mobile

- **Framework**: Flutter (to be implemented)

### Deployment

- **Target**: Linux Server
- **Database**: PostgreSQL

---

## 🏗️ Architecture

### Monorepo Structure

```
DigitalNurse/
├── backend/                 # NestJS API
│   ├── src/
│   │   ├── auth/           # Authentication module
│   │   │   ├── dto/        # Data transfer objects
│   │   │   ├── strategies/ # Passport strategies
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   └── auth.module.ts
│   │   ├── users/          # User management
│   │   │   ├── dto/
│   │   │   ├── users.controller.ts
│   │   │   ├── users.service.ts
│   │   │   └── users.module.ts
│   │   ├── subscriptions/  # Subscription & payments
│   │   │   ├── dto/
│   │   │   ├── constants/
│   │   │   ├── subscriptions.controller.ts
│   │   │   ├── subscriptions.service.ts
│   │   │   └── subscriptions.module.ts
│   │   ├── common/         # Shared utilities
│   │   │   ├── guards/
│   │   │   └── decorators/
│   │   ├── prisma/         # Database module
│   │   │   ├── prisma.service.ts
│   │   │   └── prisma.module.ts
│   │   ├── app.module.ts
│   │   └── main.ts
│   ├── prisma/
│   │   └── schema.prisma   # Database schema
│   ├── .env.example
│   ├── package.json
│   └── tsconfig.json
├── mobile/                 # Flutter app (placeholder)
├── .gitignore
├── ProjectPlan.md
└── Readme.txt
```

### Module Responsibilities

#### Auth Module

- User registration (email/password)
- Login with email/password
- Google OAuth integration
- Email verification
- JWT token generation and validation
- Token refresh functionality

#### Users Module

- User profile retrieval
- Profile updates
- Profile completion (onboarding)

#### Subscriptions Module

- Plan listing
- Subscription creation
- Plan upgrades
- Subscription cancellation
- Stripe webhook handling
- Payment tracking

#### Prisma Module

- Database connection management
- Global access to Prisma client

---

## 🗄️ Database Schema

### User Model

```prisma
model User {
  id                  String         @id @default(uuid())
  email               String         @unique
  password            String?        // Nullable for Google OAuth users
  name                String?
  emailVerified       Boolean        @default(false)
  verificationToken   String?        @unique
  googleId            String?        @unique
  profileCompleted    Boolean        @default(false)

  // Profile details
  phoneNumber         String?
  dateOfBirth         DateTime?
  address             String?
  city                String?
  country             String?

  createdAt           DateTime       @default(now())
  updatedAt           DateTime       @updatedAt

  subscriptions       Subscription[]
  payments            Payment[]
}
```

### Subscription Model

```prisma
model Subscription {
  id                    String                 @id @default(uuid())
  userId                String
  planType              SubscriptionPlanType   @default(FREE)
  status                SubscriptionStatus     @default(ACTIVE)

  stripeCustomerId      String?
  stripeSubscriptionId  String?                @unique
  stripePriceId         String?

  startDate             DateTime               @default(now())
  endDate               DateTime?
  currentPeriodStart    DateTime?
  currentPeriodEnd      DateTime?
  cancelAtPeriodEnd     Boolean                @default(false)
  canceledAt            DateTime?

  createdAt             DateTime               @default(now())
  updatedAt             DateTime               @updatedAt

  user                  User                   @relation(...)
  payments              Payment[]
}
```

### Payment Model

```prisma
model Payment {
  id                     String          @id @default(uuid())
  userId                 String
  subscriptionId         String?
  amount                 Float
  currency               String          @default("USD")
  provider               PaymentProvider
  status                 PaymentStatus   @default(PENDING)
  stripePaymentIntentId  String?         @unique
  providerTransactionId  String?
  description            String?
  failureReason          String?
  createdAt              DateTime        @default(now())
  updatedAt              DateTime        @updatedAt

  user                   User            @relation(...)
  subscription           Subscription?   @relation(...)
}
```

### Enums

- **SubscriptionPlanType**: FREE, BASIC, PREMIUM
- **SubscriptionStatus**: ACTIVE, CANCELLED, EXPIRED, PENDING
- **PaymentProvider**: STRIPE, EASYPAISA, JAZZCASH
- **PaymentStatus**: PENDING, COMPLETED, FAILED, REFUNDED

---

## 🔌 API Endpoints

Base URL: `http://localhost:3000/api`

### Authentication (`/auth`)

| Method | Endpoint                | Description               | Auth Required |
| ------ | ----------------------- | ------------------------- | ------------- |
| POST   | `/auth/register`        | Register new user         | No            |
| POST   | `/auth/login`           | Login with email/password | No            |
| GET    | `/auth/google`          | Initiate Google OAuth     | No            |
| GET    | `/auth/google/callback` | Google OAuth callback     | No            |
| POST   | `/auth/verify-email`    | Verify email address      | No            |
| POST   | `/auth/refresh-token`   | Refresh access token      | No            |

### Users (`/users`)

| Method | Endpoint                  | Description                   | Auth Required |
| ------ | ------------------------- | ----------------------------- | ------------- |
| GET    | `/users/profile`          | Get current user profile      | Yes           |
| PATCH  | `/users/profile`          | Update user profile           | Yes           |
| POST   | `/users/complete-profile` | Complete profile (onboarding) | Yes           |

### Subscriptions (`/subscriptions`)

| Method | Endpoint                         | Description                 | Auth Required |
| ------ | -------------------------------- | --------------------------- | ------------- |
| GET    | `/subscriptions/plans`           | List available plans        | No            |
| GET    | `/subscriptions/current`         | Get current subscription    | Yes           |
| POST   | `/subscriptions/create`          | Create new subscription     | Yes           |
| POST   | `/subscriptions/upgrade`         | Upgrade subscription        | Yes           |
| POST   | `/subscriptions/continue`        | Continue with existing plan | Yes           |
| DELETE | `/subscriptions/cancel`          | Cancel subscription         | Yes           |
| POST   | `/subscriptions/webhooks/stripe` | Stripe webhook handler      | No            |

### Health Check

| Method | Endpoint  | Description     | Auth Required |
| ------ | --------- | --------------- | ------------- |
| GET    | `/`       | Welcome message | No            |
| GET    | `/health` | Health check    | No            |

---

## 🔐 Authentication Flow

### Registration Flow

1. User submits email, password, and optional name
2. System checks for existing user
3. Password is hashed using bcrypt
4. Verification token is generated
5. User record is created
6. Default FREE subscription is created
7. Verification email is sent (to be implemented)
8. User receives success message

### Login Flow

1. User submits email and password
2. System validates credentials
3. JWT access token and refresh token are generated
4. User data and tokens are returned

### Google OAuth Flow

1. User clicks "Sign in with Google"
2. User is redirected to Google OAuth page
3. After authorization, Google redirects to callback URL
4. System validates Google profile
5. If user exists, link Google account; otherwise create new user
6. Default FREE subscription is created for new users
7. Tokens are generated
8. User is redirected to frontend with tokens

### Email Verification Flow

1. User receives verification email with token
2. User clicks verification link
3. System validates token
4. User's `emailVerified` flag is set to true
5. Verification token is cleared

### Token Refresh Flow

1. Client sends refresh token
2. System validates refresh token
3. New access token and refresh token are generated
4. Tokens are returned to client

---

## 💳 Subscription Flow

### Subscription Plans

#### FREE Plan

- **Price**: $0
- **Features**: Basic access, limited features, 1 user

#### BASIC Plan

- **Price**: $9.99/month
- **Features**: Extended access, up to 5 users, email support

#### PREMIUM Plan

- **Price**: $29.99/month
- **Features**: Full access, unlimited users, priority support, advanced analytics

### Creating a Subscription

1. User selects a plan (BASIC or PREMIUM)
2. System creates/retrieves Stripe customer
3. Stripe checkout session is created
4. User is redirected to Stripe checkout
5. User completes payment
6. Stripe webhook confirms payment
7. Subscription status is updated to ACTIVE
8. Payment record is created

### Upgrading a Subscription

1. User selects higher-tier plan
2. System validates upgrade request
3. Stripe subscription is updated with proration
4. Database subscription is updated
5. User gains immediate access to new features

### Continuing with Existing Plan

1. User chooses to keep current plan
2. System confirms current subscription
3. User continues with existing access

### Canceling a Subscription

1. User requests cancellation
2. Stripe subscription is set to cancel at period end
3. Database subscription is marked for cancellation
4. User retains access until period end
5. After period ends, subscription becomes EXPIRED
6. New FREE subscription is created

---

## 🚀 Setup Instructions

### Prerequisites

- Node.js (v18 or higher)
- PostgreSQL (v14 or higher)
- npm or yarn
- Git

### Initial Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd DigitalNurse
   ```

2. **Backend setup**

   ```bash
   cd backend
   npm install
   ```

3. **Configure environment variables**

   ```bash
   cp .env.example .env
   # Edit .env with your actual values
   ```

4. **Set up database**

   ```bash
   # Create PostgreSQL database
   createdb digitalnurse

   # Generate Prisma client
   npx prisma generate

   # Run database migrations
   npx prisma migrate dev --name init
   ```

5. **Start development server**

   ```bash
   npm run start:dev
   ```

6. **Access the application**
   - API: http://localhost:3000/api
   - Swagger Docs: http://localhost:3000/api/docs
   - Health Check: http://localhost:3000/api/health

---

## 🔧 Environment Variables

Create a `.env` file in the `backend/` directory with the following variables:

```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/digitalnurse

# JWT Configuration
JWT_SECRET=your-jwt-secret-change-this-in-production
JWT_EXPIRATION=7d
JWT_REFRESH_SECRET=your-refresh-jwt-secret-change-this-in-production
JWT_REFRESH_EXPIRATION=30d

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_CALLBACK_URL=http://localhost:3000/api/auth/google/callback

# Stripe
STRIPE_SECRET_KEY=your-stripe-secret-key
STRIPE_WEBHOOK_SECRET=your-stripe-webhook-secret
STRIPE_PUBLISHABLE_KEY=your-stripe-publishable-key

# Application
NODE_ENV=development
PORT=3000
FRONTEND_URL=http://localhost:3000
```

### Obtaining API Keys

#### Google OAuth

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google+ API
4. Go to Credentials → Create Credentials → OAuth 2.0 Client ID
5. Add authorized redirect URI: `http://localhost:3000/api/auth/google/callback`
6. Copy Client ID and Client Secret

#### Stripe

1. Go to [Stripe Dashboard](https://dashboard.stripe.com/)
2. Get API keys from Developers → API keys
3. For webhooks, go to Developers → Webhooks
4. Add endpoint: `http://your-domain.com/api/subscriptions/webhooks/stripe`
5. Select events: `checkout.session.completed`, `customer.subscription.updated`, `customer.subscription.deleted`, `invoice.payment_succeeded`, `invoice.payment_failed`
6. Copy webhook signing secret

---

## 👨‍💻 Development Workflow

### Branch Strategy

- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: New features
- `bugfix/*`: Bug fixes
- `hotfix/*`: Production hotfixes

### Commit Guidelines

Follow conventional commits:

- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `refactor:` Code refactoring
- `test:` Test additions/modifications
- `chore:` Build process or tooling changes

### Code Style

- Follow ESLint and Prettier configurations
- Use TypeScript strict mode
- Write descriptive variable and function names
- Add JSDoc comments for complex functions

### Pull Request Process

1. Create feature branch from `develop`
2. Implement changes with tests
3. Ensure all tests pass
4. Update documentation if needed
5. Create PR to `develop` branch
6. Request code review
7. Address review comments
8. Merge after approval

---

## 🚢 Deployment Guidelines

### Linux Server Deployment

#### Prerequisites

- Linux server (Ubuntu 20.04+ recommended)
- Node.js v18+
- PostgreSQL 14+
- Nginx (reverse proxy)
- PM2 (process manager)
- SSL certificate (Let's Encrypt)

#### Deployment Steps

1. **Server setup**

   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y

   # Install Node.js
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt install -y nodejs

   # Install PostgreSQL
   sudo apt install -y postgresql postgresql-contrib

   # Install PM2
   sudo npm install -g pm2

   # Install Nginx
   sudo apt install -y nginx
   ```

2. **Database setup**

   ```bash
   # Create database and user
   sudo -u postgres psql
   CREATE DATABASE digitalnurse;
   CREATE USER digitalnurse_user WITH ENCRYPTED PASSWORD 'secure_password';
   GRANT ALL PRIVILEGES ON DATABASE digitalnurse TO digitalnurse_user;
   \q
   ```

3. **Application deployment**

   ```bash
   # Clone repository
   git clone <repository-url> /var/www/digitalnurse
   cd /var/www/digitalnurse/backend

   # Install dependencies
   npm install --production

   # Set up environment
   cp .env.example .env
   nano .env  # Configure production values

   # Run migrations
   npx prisma migrate deploy
   npx prisma generate

   # Build application
   npm run build
   ```

4. **PM2 configuration**

   ```bash
   # Start application
   pm2 start dist/main.js --name digitalnurse-api

   # Save PM2 configuration
   pm2 save
   pm2 startup
   ```

5. **Nginx configuration**

   ```nginx
   server {
       listen 80;
       server_name api.digitalnurse.com;

       location / {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

6. **SSL setup**

   ```bash
   # Install Certbot
   sudo apt install -y certbot python3-certbot-nginx

   # Obtain SSL certificate
   sudo certbot --nginx -d api.digitalnurse.com
   ```

#### Monitoring

```bash
# View application logs
pm2 logs digitalnurse-api

# Monitor application
pm2 monit

# Check status
pm2 status
```

#### Updates

```bash
cd /var/www/digitalnurse
git pull origin main
cd backend
npm install
npm run build
pm2 restart digitalnurse-api
```

---

## 🧪 Testing Strategy

### Unit Tests

- Test individual services and controllers
- Mock external dependencies
- Use Jest testing framework

### Integration Tests

- Test API endpoints end-to-end
- Use real database (test instance)
- Test authentication flows

### E2E Tests

- Test complete user journeys
- Test payment flows (use Stripe test mode)
- Test webhook handling

### Running Tests

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

---

## 📚 Additional Resources

- [NestJS Documentation](https://docs.nestjs.com/)
- [Prisma Documentation](https://www.prisma.io/docs/)
- [Stripe API Documentation](https://stripe.com/docs/api)
- [Passport.js Documentation](http://www.passportjs.org/docs/)
- [Flutter Documentation](https://flutter.dev/docs)

---

## 🤝 Contributing

Please read the development workflow section and follow the pull request process for contributions.

---

## 📞 Support

For questions or issues, please contact the development team or create an issue in the repository.

---

## 📝 License

This project is proprietary and confidential.

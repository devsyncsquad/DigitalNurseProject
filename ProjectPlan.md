# Digital Nurse - Project Documentation

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Tech Stack](#tech-stack)
4. [Project Structure](#project-structure)
5. [Setup Instructions](#setup-instructions)
6. [Environment Variables](#environment-variables)
7. [Database Schema](#database-schema)
8. [API Endpoints](#api-endpoints)
9. [Authentication Flow](#authentication-flow)
10. [Subscription Flow](#subscription-flow)
11. [Development Workflow](#development-workflow)
12. [Deployment Guide](#deployment-guide)
13. [Security Considerations](#security-considerations)

---

## Project Overview

**Digital Nurse** is a comprehensive healthcare application designed to provide digital health services including symptom checking, health tracking, medication reminders, and telemedicine consultations. The platform follows a freemium business model with three subscription tiers: Free, Basic, and Premium.

### Key Features

- **User Authentication**: Email/password and Google OAuth 2.0
- **Subscription Management**: Three-tier subscription system with Stripe integration
- **Health Tracking**: Symptom checker, medication reminders, and health reports
- **Telemedicine**: Video consultations with healthcare professionals (Premium)
- **AI-Powered Insights**: Personalized health recommendations (Premium)

---

## Architecture

### System Architecture

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Flutter   │ ◄─────► │   Express   │ ◄─────► │ PostgreSQL  │
│  Mobile App │   HTTP  │   Backend   │   ORM   │  Database   │
└─────────────┘         └─────────────┘         └─────────────┘
                              │
                              ├─────► Google OAuth
                              │
                              ├─────► Stripe API
                              │
                              └─────► Email Service
```

### Backend Architecture

The backend follows a **modular/feature-based architecture**:

- **Modules**: Auth, Users, Subscriptions (each with routes, controllers, services, schemas)
- **Middleware**: Authentication, Validation, Error Handling
- **Config**: Environment, Database, Passport
- **Utils**: JWT, Logger, Response helpers

---

## Tech Stack

### Backend

- **Runtime**: Node.js (v18+)
- **Framework**: Express.js
- **Language**: TypeScript
- **Database**: PostgreSQL
- **ORM**: Prisma
- **Authentication**: Passport.js (JWT, Google OAuth)
- **Validation**: Zod
- **Payment**: Stripe
- **Logging**: Winston
- **Security**: Helmet, CORS, Rate Limiting

### Development Tools

- **Code Quality**: ESLint, Prettier
- **Development**: Nodemon, ts-node
- **Testing**: (To be added: Jest, Supertest)

---

## Project Structure

```
DigitalNurse/
├── backend/
│   ├── src/
│   │   ├── modules/
│   │   │   ├── auth/
│   │   │   │   ├── strategies/
│   │   │   │   │   ├── jwt.strategy.ts
│   │   │   │   │   ├── google.strategy.ts
│   │   │   │   │   └── local.strategy.ts
│   │   │   │   ├── auth.routes.ts
│   │   │   │   ├── auth.controller.ts
│   │   │   │   ├── auth.service.ts
│   │   │   │   └── auth.schemas.ts
│   │   │   ├── users/
│   │   │   │   ├── users.routes.ts
│   │   │   │   ├── users.controller.ts
│   │   │   │   ├── users.service.ts
│   │   │   │   └── users.schemas.ts
│   │   │   └── subscriptions/
│   │   │       ├── subscriptions.routes.ts
│   │   │       ├── subscriptions.controller.ts
│   │   │       ├── subscriptions.service.ts
│   │   │       └── subscriptions.schemas.ts
│   │   ├── middleware/
│   │   │   ├── auth.middleware.ts
│   │   │   ├── validate.middleware.ts
│   │   │   └── errorHandler.middleware.ts
│   │   ├── config/
│   │   │   ├── database.ts
│   │   │   ├── passport.ts
│   │   │   └── env.ts
│   │   ├── types/
│   │   │   └── express.d.ts
│   │   ├── utils/
│   │   │   ├── jwt.utils.ts
│   │   │   ├── logger.utils.ts
│   │   │   └── response.utils.ts
│   │   ├── prisma/
│   │   │   └── schema.prisma
│   │   ├── app.ts
│   │   └── server.ts
│   ├── .env.example
│   ├── .gitignore
│   ├── package.json
│   ├── tsconfig.json
│   └── nodemon.json
├── mobile/ (Flutter - to be implemented)
├── ProjectPlan.md
└── Readme.txt
```

---

## Setup Instructions

### Prerequisites

- Node.js v18+ and npm
- PostgreSQL database
- Google OAuth credentials
- Stripe account (test mode)

### Installation Steps

1. **Clone the repository**

```bash
git clone <repository-url>
cd DigitalNurse/backend
```

2. **Install dependencies**

```bash
npm install
```

3. **Set up environment variables**

```bash
cp .env.example .env
# Edit .env with your actual values
```

4. **Set up the database**

```bash
# Create PostgreSQL database
createdb digitalnurse

# Generate Prisma client
npm run prisma:generate

# Run migrations
npm run prisma:migrate
```

5. **Start development server**

```bash
npm run dev
```

The server will start on `http://localhost:3000`

---

## Environment Variables

### Required Variables

| Variable                | Description                       | Example                                              |
| ----------------------- | --------------------------------- | ---------------------------------------------------- |
| `DATABASE_URL`          | PostgreSQL connection string      | `postgresql://user:pass@localhost:5432/digitalnurse` |
| `JWT_SECRET`            | Secret key for JWT access tokens  | Random 64-char string                                |
| `JWT_REFRESH_SECRET`    | Secret key for JWT refresh tokens | Random 64-char string                                |
| `GOOGLE_CLIENT_ID`      | Google OAuth client ID            | From Google Console                                  |
| `GOOGLE_CLIENT_SECRET`  | Google OAuth client secret        | From Google Console                                  |
| `STRIPE_SECRET_KEY`     | Stripe secret API key             | `sk_test_...`                                        |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook signing secret     | `whsec_...`                                          |
| `FRONTEND_URL`          | Frontend application URL          | `http://localhost:3000`                              |

### Optional Variables

| Variable    | Description      | Default       |
| ----------- | ---------------- | ------------- |
| `PORT`      | Server port      | `3000`        |
| `NODE_ENV`  | Environment mode | `development` |
| `LOG_LEVEL` | Logging level    | `info`        |

---

## Database Schema

### User Model

```prisma
model User {
  id                 String     @id @default(uuid())
  email              String     @unique
  password           String?    // Nullable for OAuth users
  name               String
  emailVerified      Boolean    @default(false)
  verificationToken  String?    @unique
  googleId           String?    @unique
  profilePicture     String?
  phone              String?
  dateOfBirth        DateTime?
  gender             Gender?
  profileCompleted   Boolean    @default(false)
  createdAt          DateTime   @default(now())
  updatedAt          DateTime   @updatedAt

  subscriptions      Subscription[]
  payments           Payment[]
}
```

### Subscription Model

```prisma
model Subscription {
  id                    String             @id @default(uuid())
  userId                String
  planType              PlanType           @default(FREE)
  status                SubscriptionStatus @default(ACTIVE)
  stripeCustomerId      String?
  stripeSubscriptionId  String?            @unique
  currentPeriodStart    DateTime?
  currentPeriodEnd      DateTime?
  cancelAtPeriodEnd     Boolean            @default(false)
  createdAt             DateTime           @default(now())
  updatedAt             DateTime           @updatedAt

  user                  User               @relation(...)
  payments              Payment[]
}
```

### Payment Model

```prisma
model Payment {
  id                   String          @id @default(uuid())
  userId               String
  subscriptionId       String?
  amount               Decimal         @db.Decimal(10, 2)
  currency             String          @default("USD")
  provider             PaymentProvider
  status               PaymentStatus   @default(PENDING)
  stripePaymentIntentId String?        @unique
  metadata             Json?
  createdAt            DateTime        @default(now())

  user                 User            @relation(...)
  subscription         Subscription?   @relation(...)
}
```

---

## API Endpoints

### Authentication Endpoints

| Method | Endpoint                    | Description               | Auth    |
| ------ | --------------------------- | ------------------------- | ------- |
| POST   | `/api/auth/register`        | Register new user         | Public  |
| POST   | `/api/auth/login`           | Login with email/password | Public  |
| POST   | `/api/auth/verify-email`    | Verify email address      | Public  |
| POST   | `/api/auth/refresh-token`   | Refresh access token      | Public  |
| GET    | `/api/auth/google`          | Initiate Google OAuth     | Public  |
| GET    | `/api/auth/google/callback` | Google OAuth callback     | Public  |
| GET    | `/api/auth/me`              | Get current user          | Private |

### User Endpoints

| Method | Endpoint                      | Description              | Auth    |
| ------ | ----------------------------- | ------------------------ | ------- |
| GET    | `/api/users/profile`          | Get user profile         | Private |
| PATCH  | `/api/users/profile`          | Update user profile      | Private |
| POST   | `/api/users/complete-profile` | Complete onboarding      | Private |
| GET    | `/api/users/profile-status`   | Check profile completion | Private |

### Subscription Endpoints

| Method | Endpoint                             | Description              | Auth    |
| ------ | ------------------------------------ | ------------------------ | ------- |
| GET    | `/api/subscriptions/plans`           | Get available plans      | Public  |
| GET    | `/api/subscriptions/current`         | Get current subscription | Private |
| POST   | `/api/subscriptions/create`          | Create subscription      | Private |
| POST   | `/api/subscriptions/upgrade`         | Upgrade subscription     | Private |
| DELETE | `/api/subscriptions/cancel`          | Cancel subscription      | Private |
| POST   | `/api/subscriptions/webhooks/stripe` | Stripe webhook handler   | Stripe  |

---

## Authentication Flow

### Email/Password Registration

```
1. User submits registration form
2. Backend validates input (Zod schema)
3. Check if email already exists
4. Hash password with bcrypt
5. Generate email verification token
6. Create user in database
7. Create FREE subscription
8. Send verification email (TODO)
9. Return user data and token
```

### Email/Password Login

```
1. User submits login credentials
2. Backend validates input
3. Find user by email
4. Verify password with bcrypt
5. Check email verification status
6. Generate JWT access & refresh tokens
7. Return user data and tokens
```

### Google OAuth Flow

```
1. User clicks "Login with Google"
2. Redirect to Google consent screen
3. User approves permissions
4. Google redirects to callback URL
5. Backend verifies Google token
6. Create user if doesn't exist
7. Update Google ID if existing user
8. Generate JWT tokens
9. Return user data and tokens
```

### JWT Token Usage

```
Client Request Headers:
Authorization: Bearer <access_token>

Token Payload:
{
  userId: "uuid",
  email: "user@example.com",
  iat: 1234567890,
  exp: 1234567890
}
```

---

## Subscription Flow

### Subscription Plans

#### FREE Plan

- Price: $0/month
- Features:
  - Basic health tracking
  - Limited symptom checker
  - Community access
  - Basic health tips

#### BASIC Plan

- Price: $9.99/month
- Features:
  - All Free features
  - Advanced symptom checker
  - Medication reminders
  - Health reports
  - Priority support

#### PREMIUM Plan

- Price: $19.99/month
- Features:
  - All Basic features
  - AI-powered health insights
  - Telemedicine consultations
  - Family health tracking
  - Personalized health plans
  - 24/7 Priority support

### Creating a Subscription

```
1. User selects a plan
2. Frontend calls /api/subscriptions/create
3. Backend creates Stripe customer (if needed)
4. Backend creates Stripe subscription
5. Returns client secret for payment
6. Frontend handles payment with Stripe.js
7. Stripe webhook confirms payment
8. Backend updates subscription status
```

### Upgrading a Subscription

```
1. User selects higher tier plan
2. Backend verifies upgrade eligibility
3. Update Stripe subscription with proration
4. Update database subscription
5. Apply new features immediately
```

### Canceling a Subscription

```
Option 1: Cancel at period end
- Subscription remains active until end date
- No refund issued
- Downgrade to FREE after expiry

Option 2: Cancel immediately
- Subscription cancelled immediately
- Downgrade to FREE plan
- No refund (as per policy)
```

---

## Development Workflow

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes and commit
git add .
git commit -m "feat: add feature description"

# Push to remote
git push origin feature/your-feature-name

# Create pull request for review
```

### Running Development Server

```bash
# Start with hot reload
npm run dev

# Build TypeScript
npm run build

# Start production server
npm start
```

### Database Migrations

```bash
# Create new migration
npx prisma migrate dev --name migration_name

# Apply migrations
npx prisma migrate deploy

# Reset database (development only)
npx prisma migrate reset

# Open Prisma Studio
npm run prisma:studio
```

### Code Quality

```bash
# Lint code
npm run lint

# Fix linting issues
npm run lint:fix

# Format code
npm run format
```

---

## Deployment Guide

### Linux Server Deployment

#### Prerequisites

- Ubuntu 20.04+ or CentOS 8+
- Node.js v18+
- PostgreSQL 14+
- Nginx (reverse proxy)
- PM2 (process manager)
- SSL certificate (Let's Encrypt)

#### Step 1: Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Install Nginx
sudo apt install -y nginx

# Install PM2
sudo npm install -g pm2
```

#### Step 2: Database Setup

```bash
# Create database user
sudo -u postgres createuser --interactive

# Create database
sudo -u postgres createdb digitalnurse

# Set password
sudo -u postgres psql
ALTER USER your_user WITH PASSWORD 'your_password';
\q
```

#### Step 3: Application Deployment

```bash
# Clone repository
cd /var/www
git clone <repository-url> digitalnurse
cd digitalnurse/backend

# Install dependencies
npm ci --production

# Set up environment
cp .env.example .env
nano .env  # Edit with production values

# Build application
npm run build

# Run migrations
npm run prisma:migrate deploy

# Start with PM2
pm2 start dist/server.js --name digitalnurse-api
pm2 save
pm2 startup
```

#### Step 4: Nginx Configuration

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
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/digitalnurse /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### Step 5: SSL Certificate

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d api.digitalnurse.com

# Auto-renewal (already set up by certbot)
```

#### Step 6: Monitoring

```bash
# PM2 monitoring
pm2 monit

# View logs
pm2 logs digitalnurse-api

# Check status
pm2 status
```

---

## Security Considerations

### Best Practices Implemented

1. **Password Security**

   - Bcrypt hashing with salt rounds (10)
   - Strong password requirements (8+ chars, uppercase, lowercase, number)

2. **JWT Security**

   - Separate secrets for access and refresh tokens
   - Short expiration times (7 days access, 30 days refresh)
   - Token verification on every protected route

3. **API Security**

   - Helmet.js for security headers
   - CORS configuration
   - Rate limiting on authentication routes
   - Input validation with Zod

4. **Database Security**

   - Parameterized queries via Prisma (SQL injection prevention)
   - Connection pooling
   - Environment-based credentials

5. **Payment Security**
   - Stripe webhook signature verification
   - PCI compliance through Stripe
   - No credit card data stored

### Additional Security Recommendations

1. Enable 2FA for user accounts
2. Implement API key rotation
3. Add request logging and monitoring
4. Set up intrusion detection system
5. Regular security audits
6. Dependency vulnerability scanning

---

## Additional Notes

### Future Enhancements

- Email service integration for verification emails
- SMS notifications via Twilio
- Push notifications for mobile app
- Health data encryption at rest
- HIPAA compliance measures
- API documentation with Swagger
- Automated testing (unit, integration, e2e)
- CI/CD pipeline setup

### Support

For issues or questions, please contact the development team or create an issue in the repository.

---

**Last Updated**: October 2025  
**Version**: 1.0.0  
**Status**: Initial Development

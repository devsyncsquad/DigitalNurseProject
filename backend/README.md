# Digital Nurse Backend

Express.js + TypeScript backend API for the Digital Nurse healthcare application.

## Quick Start

### Prerequisites

- Node.js v18+
- PostgreSQL 14+
- npm or yarn

### Installation

1. **Install dependencies**

```bash
npm install
```

2. **Set up environment variables**

```bash
cp .env.example .env
# Edit .env with your configuration
```

3. **Set up database**

```bash
# Generate Prisma client
npm run prisma:generate

# Run migrations
npm run prisma:migrate
```

4. **Start development server**

```bash
npm run dev
```

The API will be available at `http://localhost:3000`

## Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build TypeScript for production
- `npm start` - Start production server
- `npm run lint` - Run ESLint
- `npm run lint:fix` - Fix linting issues
- `npm run format` - Format code with Prettier
- `npm run prisma:generate` - Generate Prisma client
- `npm run prisma:migrate` - Run database migrations
- `npm run prisma:studio` - Open Prisma Studio

## API Documentation

### Health Check

```
GET /health
```

### Authentication

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login with credentials
- `GET /api/auth/google` - Google OAuth login
- `POST /api/auth/verify-email` - Verify email
- `POST /api/auth/refresh-token` - Refresh access token
- `GET /api/auth/me` - Get current user (protected)

### Users

- `GET /api/users/profile` - Get user profile (protected)
- `PATCH /api/users/profile` - Update profile (protected)
- `POST /api/users/complete-profile` - Complete onboarding (protected)

### Subscriptions

- `GET /api/subscriptions/plans` - Get available plans
- `GET /api/subscriptions/current` - Get current subscription (protected)
- `POST /api/subscriptions/create` - Create subscription (protected)
- `POST /api/subscriptions/upgrade` - Upgrade plan (protected)
- `DELETE /api/subscriptions/cancel` - Cancel subscription (protected)

### Medications

- `GET /api/medications` - Get all medications (filter by ?elderUserId=X)
- `GET /api/medications/:id` - Get medication by ID
- `POST /api/medications` - Create medication
- `PUT /api/medications/:id` - Update medication
- `DELETE /api/medications/:id` - Delete medication
- `GET /api/medications/:medicationId/schedules` - Get medication schedules
- `POST /api/medications/schedules` - Create medication schedule
- `PUT /api/medications/schedules/:id` - Update medication schedule
- `DELETE /api/medications/schedules/:id` - Delete medication schedule
- `GET /api/medications/intakes/all` - Get all medication intakes (filter by ?elderUserId=X&status=X)
- `POST /api/medications/intakes` - Record medication intake
- `PUT /api/medications/intakes/:id` - Update medication intake
- `DELETE /api/medications/intakes/:id` - Delete medication intake
- `GET /api/medications/adherence/:elderUserId` - Get medication adherence statistics

### Vitals

- `GET /api/vitals` - Get all vital measurements (filter by ?elderUserId=X&kindCode=X&startDate=X&endDate=X)
- `GET /api/vitals/:id` - Get vital measurement by ID
- `POST /api/vitals` - Record vital measurement
- `PUT /api/vitals/:id` - Update vital measurement
- `DELETE /api/vitals/:id` - Delete vital measurement
- `GET /api/vitals/latest/:elderUserId` - Get latest vitals for each kind
- `GET /api/vitals/trend/:elderUserId/:kindCode` - Get vital trend over time (filter by ?days=X)
- `GET /api/vitals/summary/:elderUserId` - Get vital summary statistics (filter by ?days=X)

### Elder Assignments

- `GET /api/elder-assignments` - Get all assignments (filter by ?elderUserId=X&caregiverUserId=X)
- `GET /api/elder-assignments/:id` - Get assignment by ID
- `POST /api/elder-assignments` - Create assignment
- `PUT /api/elder-assignments/:id` - Update assignment
- `DELETE /api/elder-assignments/:id` - Delete assignment
- `GET /api/elder-assignments/caregiver/:caregiverUserId/elders` - Get all elders for a caregiver
- `GET /api/elder-assignments/elder/:elderUserId/caregivers` - Get all caregivers for an elder
- `PUT /api/elder-assignments/elder/:elderUserId/primary/:caregiverUserId` - Set primary caregiver

### Notifications

- `GET /api/notifications` - Get all notifications (filter by ?userId=X&status=X&isRead=X)
- `GET /api/notifications/:id` - Get notification by ID
- `POST /api/notifications` - Create notification
- `PUT /api/notifications/:id` - Update notification
- `DELETE /api/notifications/:id` - Delete notification
- `GET /api/notifications/user/:userId` - Get user notifications (filter by ?limit=X)
- `GET /api/notifications/user/:userId/unread-count` - Get unread notification count
- `PUT /api/notifications/user/:userId/mark-all-read` - Mark all notifications as read
- `POST /api/notifications/mark-as-read` - Mark specific notifications as read
- `PUT /api/notifications/:id/mark-as-sent` - Mark notification as sent
- `GET /api/notifications/pending` - Get pending notifications

### Lookups

- `GET /api/lookups` - Get all lookups (filter by ?domain=X&isActive=X)
- `GET /api/lookups/:id` - Get lookup by ID
- `GET /api/lookups/domain/:domain` - Get lookups by domain
- `GET /api/lookups/domains` - Get all domains
- `POST /api/lookups` - Create lookup
- `PUT /api/lookups/:id` - Update lookup
- `DELETE /api/lookups/:id` - Delete lookup

## Project Structure

```
src/
├── modules/              # Feature modules
│   ├── auth/            # Authentication
│   ├── users/           # User management
│   ├── subscriptions/   # Subscription & payments
│   ├── medications/     # Medication management
│   ├── vitals/          # Vital measurements
│   ├── elder-assignments/ # Elder-caregiver relationships
│   ├── notifications/   # Notification system
│   └── lookups/         # Reference data
├── middleware/          # Express middleware
├── config/              # Configuration files
├── utils/               # Utility functions
├── types/               # TypeScript type definitions
├── prisma/              # Prisma schema
├── app.ts               # Express app setup
└── server.ts            # Server entry point
```

## Tech Stack

- **Framework**: Express.js
- **Language**: TypeScript
- **Database**: PostgreSQL
- **ORM**: Prisma
- **Authentication**: Passport.js (JWT, Google OAuth)
- **Validation**: Zod
- **Payment**: Stripe
- **Logging**: Winston
- **Security**: Helmet, CORS, Rate Limiting

## Environment Variables

See `.env.example` for all required environment variables.

Key variables:

- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - JWT secret key
- `GOOGLE_CLIENT_ID` - Google OAuth client ID
- `GOOGLE_CLIENT_SECRET` - Google OAuth secret
- `STRIPE_SECRET_KEY` - Stripe API key
- `STRIPE_WEBHOOK_SECRET` - Stripe webhook secret

## Database Schema

The application uses multiple models for comprehensive healthcare management:

### Core Models

- **User** - User accounts and profiles
- **Role & UserRole** - Role-based access control
- **Subscription & SubscriptionPlan** - User subscriptions and plans

### Healthcare Models

- **Medication** - Medication records for elders
- **MedSchedule** - Medication schedules and timing
- **MedIntake** - Medication intake records
- **VitalMeasurement** - Vital signs (blood pressure, glucose, etc.)
- **DietLog** - Diet and nutrition logs
- **ExerciseLog** - Exercise activity logs
- **UserDailySummary** - Daily health summaries

### Relationship Models

- **ElderAssignment** - Elder-caregiver relationships

### System Models

- **Notification & NotificationLog** - Notification system
- **Lookup & Translation** - Reference data and i18n
- **UserDevice** - Device management for push notifications
- **UserDocument** - Document storage
- **UserInvitation** - User invitation system
- **UserLoginEvent** - Login tracking

See `prisma/schema.prisma` for detailed schema.

## Authentication

The API uses JWT-based authentication with Bearer tokens.

Include the token in the Authorization header:

```
Authorization: Bearer <your_access_token>
```

## Development

### Code Style

- ESLint for linting
- Prettier for formatting
- TypeScript strict mode enabled

### Database Migrations

```bash
# Create a new migration
npx prisma migrate dev --name description

# Apply migrations in production
npx prisma migrate deploy

# Reset database (dev only)
npx prisma migrate reset
```

## Deployment

See [ProjectPlan.md](../ProjectPlan.md) for detailed deployment instructions.

## License

Proprietary - All rights reserved

## Support

For questions or issues, please contact the development team.

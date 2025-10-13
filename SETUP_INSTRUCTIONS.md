# Digital Nurse - Quick Setup Guide

## Prerequisites

Before you begin, ensure you have the following installed:

- Node.js v18 or higher
- PostgreSQL 14 or higher
- npm (comes with Node.js)
- Git

## Quick Start (Development)

### 1. Clone & Install Dependencies

```bash
cd DigitalNurse/backend
npm install
```

### 2. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit .env file with your actual values
# At minimum, configure:
# - DATABASE_URL
# - JWT_SECRET
# - JWT_REFRESH_SECRET
```

### 3. Setup Database

```bash
# Create PostgreSQL database
createdb digitalnurse

# Or using psql
psql -U postgres
CREATE DATABASE digitalnurse;
\q

# Generate Prisma Client
npx prisma generate

# Run migrations
npx prisma migrate dev --name init
```

### 4. Start Development Server

```bash
npm run start:dev
```

The API will be available at:

- **API**: http://localhost:3000/api
- **API Docs**: http://localhost:3000/api/docs
- **Health Check**: http://localhost:3000/api/health

## Configuration for External Services

### Google OAuth (Optional)

1. Visit [Google Cloud Console](https://console.cloud.google.com/)
2. Create a project and enable Google+ API
3. Create OAuth 2.0 credentials
4. Add to `.env`:
   ```
   GOOGLE_CLIENT_ID=your-client-id
   GOOGLE_CLIENT_SECRET=your-client-secret
   GOOGLE_CALLBACK_URL=http://localhost:3000/api/auth/google/callback
   ```

### Stripe (Optional - for payments)

1. Visit [Stripe Dashboard](https://dashboard.stripe.com/)
2. Get API keys from Developers → API keys
3. Add to `.env`:
   ```
   STRIPE_SECRET_KEY=sk_test_...
   STRIPE_PUBLISHABLE_KEY=pk_test_...
   ```
4. For webhooks (development):
   ```bash
   stripe listen --forward-to localhost:3000/api/subscriptions/webhooks/stripe
   # Copy the webhook signing secret to STRIPE_WEBHOOK_SECRET in .env
   ```

## Testing the API

### Using Swagger UI

1. Navigate to http://localhost:3000/api/docs
2. Try the authentication endpoints
3. Use the "Authorize" button to add Bearer token

### Using cURL

```bash
# Register a user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","name":"Test User"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Use the returned accessToken for authenticated requests
curl -X GET http://localhost:3000/api/users/profile \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Common Commands

```bash
# Development
npm run start:dev          # Start with hot reload
npm run start:debug        # Start in debug mode

# Building
npm run build              # Build for production
npm run start:prod         # Run production build

# Database
npx prisma studio          # Open database GUI
npx prisma migrate dev     # Create new migration
npx prisma db seed         # Seed database

# Code Quality
npm run format             # Format code
npm run lint               # Lint code
npm run test               # Run tests
```

## Troubleshooting

### Database Connection Issues

- Ensure PostgreSQL is running: `sudo service postgresql status`
- Check DATABASE_URL in .env is correct
- Verify database exists: `psql -U postgres -l`

### Port Already in Use

```bash
# Change PORT in .env file
PORT=3001
```

### Prisma Client Not Generated

```bash
npx prisma generate
```

### Build Errors

```bash
# Clean and rebuild
rm -rf node_modules dist
npm install
npm run build
```

## Next Steps

1. **Review Documentation**: Read `ProjectPlan.md` for detailed architecture
2. **Set up Git Hooks**: Consider adding pre-commit hooks for linting
3. **Configure CI/CD**: Set up GitHub Actions or similar
4. **Flutter App**: Initialize the mobile app in the `mobile/` directory

## Need Help?

- Check the detailed documentation in `ProjectPlan.md`
- Review backend-specific docs in `backend/README.md`
- Check API documentation at `/api/docs` when server is running

## Important Notes

- Never commit `.env` files
- Always use `package-lock.json` for reproducible builds
- Run migrations before deploying
- Use environment-specific configuration files
- Keep secrets secure and rotate them regularly

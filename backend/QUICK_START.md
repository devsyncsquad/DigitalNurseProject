# Digital Nurse Backend - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Environment Setup

Create a `.env` file in the backend root:

```env
DATABASE_URL="postgresql://admin_bm:BioMass@786@109.199.116.191:5432/DigitalNurse"
JWT_SECRET="your-super-secret-jwt-key-change-in-production"
JWT_EXPIRATION="7d"
JWT_REFRESH_SECRET="your-super-secret-refresh-key-change-in-production"
JWT_REFRESH_EXPIRATION="30d"
GOOGLE_CLIENT_ID="your-google-client-id"
GOOGLE_CLIENT_SECRET="your-google-client-secret"
GOOGLE_CALLBACK_URL="http://localhost:3000/api/auth/google/callback"
STRIPE_SECRET_KEY="your-stripe-secret-key"
STRIPE_WEBHOOK_SECRET="your-stripe-webhook-secret"
NODE_ENV="development"
PORT="3000"
FRONTEND_URL="http://localhost:5173"
API_BASE_URL="http://localhost:3000"
LOG_LEVEL="info"
```

### Step 2: Install & Generate

```bash
# Install dependencies
npm install

# Generate Prisma client from the database
npx prisma generate
```

### Step 3: Start the Server

```bash
# Development mode with hot reload
npm run dev
```

Server will start at: `http://localhost:3000`

### Step 4: Test the API

#### Health Check

```bash
curl http://localhost:3000/health
```

#### Get All Medications

```bash
curl http://localhost:3000/api/medications
```

#### Get Lookups by Domain

```bash
curl http://localhost:3000/api/lookups/domain/vital_kinds
```

## 📋 Common Tasks

### View Database in Prisma Studio

```bash
npm run prisma:studio
```

Opens at `http://localhost:5555`

### Check Database Schema

```bash
npx prisma db pull
```

### Build for Production

```bash
npm run build
npm start
```

## 🔑 Key API Endpoints

### Medications

- `GET /api/medications?elderUserId=1` - Get medications for an elder
- `POST /api/medications` - Create new medication
- `GET /api/medications/adherence/1` - Get adherence stats

### Vitals

- `GET /api/vitals?elderUserId=1` - Get vital measurements
- `POST /api/vitals` - Record new vital
- `GET /api/vitals/latest/1` - Get latest vitals for each type
- `GET /api/vitals/trend/1/blood_pressure?days=7` - Get 7-day trend

### Elder Assignments

- `GET /api/elder-assignments/caregiver/1/elders` - Get elders for caregiver
- `POST /api/elder-assignments` - Link elder with caregiver

### Notifications

- `GET /api/notifications/user/1` - Get user notifications
- `GET /api/notifications/user/1/unread-count` - Get unread count
- `PUT /api/notifications/user/1/mark-all-read` - Mark all as read

### Lookups (Reference Data)

- `GET /api/lookups/domains` - Get all domains
- `GET /api/lookups/domain/vital_kinds` - Get vital types
- `GET /api/lookups/domain/medication_forms` - Get medication forms

## 📊 Example Requests

### Record a Vital Measurement

```bash
curl -X POST http://localhost:3000/api/vitals \
  -H "Content-Type: application/json" \
  -d '{
    "elderUserId": "1",
    "kindCode": "blood_pressure",
    "value1": 120,
    "value2": 80,
    "unitCode": "mmHg",
    "recordedAt": "2025-10-13T10:00:00Z"
  }'
```

### Create Medication

```bash
curl -X POST http://localhost:3000/api/medications \
  -H "Content-Type: application/json" \
  -d '{
    "elderUserId": "1",
    "medicationName": "Metformin",
    "doseValue": 500,
    "doseUnitCode": "mg",
    "formCode": "tablet",
    "instructions": "Take with meals"
  }'
```

### Get Medication Adherence

```bash
curl http://localhost:3000/api/medications/adherence/1?days=7
```

Response:

```json
{
  "success": true,
  "message": "Medication adherence retrieved successfully",
  "data": {
    "total": 42,
    "taken": 38,
    "missed": 3,
    "skipped": 1,
    "adherenceRate": "90.48"
  }
}
```

## 🛠️ Development Commands

```bash
# Start dev server
npm run dev

# Build TypeScript
npm run build

# Run production
npm start

# Lint code
npm run lint
npm run lint:fix

# Format code
npm run format

# Prisma commands
npm run prisma:generate  # Generate client
npm run prisma:studio    # Open Studio
```

## 🐛 Troubleshooting

### Port Already in Use

```bash
# Kill process on port 3000 (Windows)
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### Prisma Client Not Found

```bash
npx prisma generate
```

### Database Connection Error

Check your `.env` file has the correct `DATABASE_URL`

### TypeScript Errors

The new modules (medications, vitals, elder-assignments, notifications, lookups) compile successfully. Existing modules (auth, subscriptions, users) have pre-existing errors that need to be fixed separately.

## 📚 Next Steps

1. Test the endpoints using Postman or curl
2. Review the database schema: `npx prisma studio`
3. Read the full API documentation in `README.md`
4. Check implementation details in `API_IMPLEMENTATION_SUMMARY.md`

## 🆘 Need Help?

- Check `README.md` for full documentation
- View `API_IMPLEMENTATION_SUMMARY.md` for implementation details
- Explore the Prisma schema at `prisma/schema.prisma`
- Review module code in `src/modules/`

---

**Ready to go!** 🎉 Your backend is connected to the database with 5 new API modules and 50+ endpoints.

# Swagger API Documentation Guide

## 🎯 Access Swagger UI

**Open in your browser:**

```
http://localhost:3000/api-docs
```

## 📚 What's Available

### Documented API Modules

1. **Health** - Server health check
2. **Medications** - Full medication management with examples
3. **Vitals** - Vital measurements with trend analysis
4. **Elder Assignments** - Caregiver-elder relationships
5. **Notifications** - Notification system
6. **Lookups** - Reference data (domains, types, units)

## 🚀 How to Use Swagger UI

### 1. View Endpoints

- Click on any endpoint to expand details
- See request parameters, body schemas, and response formats

### 2. Test APIs Directly

- Click "Try it out" button on any endpoint
- Fill in the parameters
- Click "Execute" to test
- View the response directly in Swagger

### 3. Example Workflow

#### Get All Lookup Domains

1. Open Swagger: `http://localhost:3000/api-docs`
2. Find **Lookups** section
3. Click on `GET /api/lookups/domains`
4. Click "Try it out"
5. Click "Execute"
6. See the response with all domains

#### Get Vital Types

1. Click on `GET /api/lookups/domain/{domain}`
2. Click "Try it out"
3. Enter `vital_kinds` in the domain parameter
4. Click "Execute"
5. See blood pressure, glucose, weight, pulse types

#### Create a Vital Measurement

1. Click on `POST /api/vitals`
2. Click "Try it out"
3. Fill in the request body:

```json
{
  "elderUserId": "6",
  "kindCode": "bp",
  "value1": 120,
  "value2": 80,
  "unitCode": "mmHg",
  "recordedAt": "2025-10-13T10:00:00Z"
}
```

4. Click "Execute"
5. See the created vital measurement

## 📊 Available Domains in Database

Based on your database, these lookup domains are available:

- `languages` - Supported languages
- `med_forms` - Medication forms (tablet, capsule, syrup, etc.)
- `med_units` - Medication units (mg, ml, etc.)
- `relationships` - Caregiver relationships (son, daughter, etc.)
- `skip_reasons` - Reasons for skipping medications
- `vital_kinds` - Types of vitals (bp, glucose, weight, pulse)
- `vital_units` - Units for vitals (mmHg, mg/dL, kg, bpm)

## 🔍 Testing Scenarios in Swagger

### Scenario 1: Create and Track Medication

1. `POST /api/medications` - Create medication for elder
2. `GET /api/medications?elderUserId=6` - View elder's medications
3. `POST /api/medications/schedules` - Add schedule
4. `POST /api/medications/intakes` - Record intake
5. `GET /api/medications/adherence/6` - Check adherence

### Scenario 2: Record and Monitor Vitals

1. `GET /api/lookups/domain/vital_kinds` - Get vital types
2. `POST /api/vitals` - Record blood pressure
3. `POST /api/vitals` - Record glucose
4. `GET /api/vitals/latest/6` - Get latest of each type
5. `GET /api/vitals/trend/6/bp?days=7` - View 7-day trend
6. `GET /api/vitals/summary/6` - Get statistics

### Scenario 3: Manage Caregivers

1. `POST /api/elder-assignments` - Assign caregiver to elder
2. `GET /api/elder-assignments/caregiver/7/elders` - View caregiver's elders
3. `GET /api/elder-assignments/elder/6/caregivers` - View elder's caregivers
4. `PUT /api/elder-assignments/elder/6/primary/7` - Set primary caregiver

## 💡 Tips

### Request Bodies

Swagger auto-generates sample request bodies from schemas. You can:

- Edit the JSON directly
- Use the "Example Value" button
- See required vs optional fields

### Response Codes

- `200` - Success
- `201` - Created
- `400` - Validation error
- `404` - Not found
- `500` - Server error

### Query Parameters

Use query parameters for filtering:

- `?elderUserId=6` - Filter by elder
- `?status=pending` - Filter by status
- `?days=7` - Set time range
- `?limit=50` - Limit results

## 🎨 Swagger Features

- **Interactive Testing** - Test APIs without Postman
- **Auto-generated Schemas** - See exact data structures
- **Response Examples** - View sample responses
- **Authentication** - (Will be added when auth is re-enabled)
- **Export OpenAPI Spec** - Download JSON/YAML

## 📱 Mobile Testing

You can also access Swagger from your mobile device:

```
http://<your-computer-ip>:3000/api-docs
```

## 🔧 Customization

To add more documentation:

1. Add `@openapi` JSDoc comments to route files
2. Define schemas in `src/config/swagger.ts`
3. Server auto-restarts on changes

## 📖 Example Swagger Annotations

```typescript
/**
 * @openapi
 * /api/yourEndpoint:
 *   get:
 *     tags:
 *       - YourTag
 *     summary: Your summary
 *     responses:
 *       200:
 *         description: Success
 */
router.get('/yourEndpoint', controller.method);
```

---

**Swagger URL**: http://localhost:3000/api-docs  
**API Base URL**: http://localhost:3000/api  
**Health Check**: http://localhost:3000/health

🎉 **Happy Testing!**

import swaggerJsdoc from 'swagger-jsdoc';
import { env } from './env';

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Digital Nurse API',
      version: '1.0.0',
      description: 'API documentation for Digital Nurse healthcare application',
      contact: {
        name: 'Digital Nurse Team',
        email: 'support@digitalnurse.com',
      },
    },
    servers: [
      {
        url: env.API_BASE_URL,
        description: 'Development server',
      },
    ],
    components: {
      schemas: {
        Medication: {
          type: 'object',
          properties: {
            medicationId: { type: 'string' },
            elderUserId: { type: 'string' },
            medicationName: { type: 'string' },
            doseValue: { type: 'number' },
            doseUnitCode: { type: 'string' },
            formCode: { type: 'string' },
            instructions: { type: 'string' },
            notes: { type: 'string' },
            createdAt: { type: 'string', format: 'date-time' },
            updatedAt: { type: 'string', format: 'date-time' },
          },
        },
        VitalMeasurement: {
          type: 'object',
          properties: {
            vitalMeasurementId: { type: 'string' },
            elderUserId: { type: 'string' },
            kindCode: { type: 'string' },
            unitCode: { type: 'string' },
            value1: { type: 'number' },
            value2: { type: 'number' },
            valueText: { type: 'string' },
            recordedAt: { type: 'string', format: 'date-time' },
            source: { type: 'string' },
            notes: { type: 'string' },
          },
        },
        ElderAssignment: {
          type: 'object',
          properties: {
            elderAssignmentId: { type: 'string' },
            elderUserId: { type: 'string' },
            caregiverUserId: { type: 'string' },
            relationshipCode: { type: 'string' },
            isPrimary: { type: 'boolean' },
          },
        },
        Notification: {
          type: 'object',
          properties: {
            notificationId: { type: 'string' },
            userId: { type: 'string' },
            title: { type: 'string' },
            message: { type: 'string' },
            notificationType: { type: 'string' },
            isRead: { type: 'boolean' },
            isSent: { type: 'boolean' },
            status: { type: 'string' },
          },
        },
        Lookup: {
          type: 'object',
          properties: {
            lookupId: { type: 'string' },
            lookupDomain: { type: 'string' },
            lookupCode: { type: 'string' },
            lookupLabel: { type: 'string' },
            sortOrder: { type: 'integer' },
            isActive: { type: 'boolean' },
          },
        },
        ApiResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean' },
            message: { type: 'string' },
            data: { type: 'object' },
          },
        },
        Error: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            error: { type: 'string' },
          },
        },
      },
    },
    tags: [
      { name: 'Health', description: 'Health check endpoints' },
      { name: 'Medications', description: 'Medication management' },
      { name: 'Vitals', description: 'Vital measurements' },
      { name: 'Elder Assignments', description: 'Elder-caregiver relationships' },
      { name: 'Notifications', description: 'Notification management' },
      { name: 'Lookups', description: 'Reference data' },
    ],
  },
  apis: ['./src/app.ts', './src/modules/**/*.routes.ts'],
};

export const swaggerSpec = swaggerJsdoc(options);

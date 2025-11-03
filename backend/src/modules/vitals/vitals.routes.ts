import { Router } from 'express';
import { vitalController } from './vitals.controller';
import { validate } from '../../middleware/validate.middleware';
import { createVitalMeasurementSchema, updateVitalMeasurementSchema } from './vitals.schemas';

const router = Router();

/**
 * @openapi
 * /api/vitals:
 *   get:
 *     tags:
 *       - Vitals
 *     summary: Get all vital measurements
 *     parameters:
 *       - in: query
 *         name: elderUserId
 *         schema:
 *           type: string
 *       - in: query
 *         name: kindCode
 *         schema:
 *           type: string
 *         description: Vital type (e.g., bp, glucose, weight)
 *       - in: query
 *         name: startDate
 *         schema:
 *           type: string
 *           format: date-time
 *       - in: query
 *         name: endDate
 *         schema:
 *           type: string
 *           format: date-time
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 100
 *     responses:
 *       200:
 *         description: Vitals retrieved successfully
 */
router.get('/', vitalController.getAllVitals);

router.get('/:id', vitalController.getVitalById);

/**
 * @openapi
 * /api/vitals:
 *   post:
 *     tags:
 *       - Vitals
 *     summary: Record new vital measurement
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - elderUserId
 *               - kindCode
 *             properties:
 *               elderUserId:
 *                 type: string
 *               kindCode:
 *                 type: string
 *                 description: Type of vital (bp, glucose, weight, pulse, etc.)
 *               value1:
 *                 type: number
 *                 description: Primary value (e.g., systolic BP)
 *               value2:
 *                 type: number
 *                 description: Secondary value (e.g., diastolic BP)
 *               valueText:
 *                 type: string
 *               unitCode:
 *                 type: string
 *                 description: Unit of measurement
 *               recordedAt:
 *                 type: string
 *                 format: date-time
 *               source:
 *                 type: string
 *                 default: manual
 *               notes:
 *                 type: string
 *           example:
 *             elderUserId: "6"
 *             kindCode: "bp"
 *             value1: 120
 *             value2: 80
 *             unitCode: "mmHg"
 *             recordedAt: "2025-10-13T10:00:00Z"
 *     responses:
 *       201:
 *         description: Vital measurement created successfully
 */
router.post('/', validate(createVitalMeasurementSchema), vitalController.createVital);

router.put('/:id', validate(updateVitalMeasurementSchema), vitalController.updateVital);
router.delete('/:id', vitalController.deleteVital);

/**
 * @openapi
 * /api/vitals/latest/{elderUserId}:
 *   get:
 *     tags:
 *       - Vitals
 *     summary: Get latest vitals for each type
 *     description: Returns the most recent measurement for each vital type
 *     parameters:
 *       - in: path
 *         name: elderUserId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Latest vitals retrieved successfully
 */
router.get('/latest/:elderUserId', vitalController.getLatestVitals);

/**
 * @openapi
 * /api/vitals/trend/{elderUserId}/{kindCode}:
 *   get:
 *     tags:
 *       - Vitals
 *     summary: Get vital trend over time
 *     parameters:
 *       - in: path
 *         name: elderUserId
 *         required: true
 *         schema:
 *           type: string
 *       - in: path
 *         name: kindCode
 *         required: true
 *         schema:
 *           type: string
 *       - in: query
 *         name: days
 *         schema:
 *           type: integer
 *           default: 7
 *     responses:
 *       200:
 *         description: Vital trend retrieved successfully
 */
router.get('/trend/:elderUserId/:kindCode', vitalController.getVitalTrend);

/**
 * @openapi
 * /api/vitals/summary/{elderUserId}:
 *   get:
 *     tags:
 *       - Vitals
 *     summary: Get vital summary statistics
 *     parameters:
 *       - in: path
 *         name: elderUserId
 *         required: true
 *         schema:
 *           type: string
 *       - in: query
 *         name: days
 *         schema:
 *           type: integer
 *           default: 7
 *     responses:
 *       200:
 *         description: Statistics retrieved successfully
 */
router.get('/summary/:elderUserId', vitalController.getVitalSummary);

export default router;

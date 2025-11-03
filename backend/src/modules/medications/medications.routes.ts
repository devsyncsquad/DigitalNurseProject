import { Router } from 'express';
import { medicationController } from './medications.controller';
import { validate } from '../../middleware/validate.middleware';
import {
  createMedicationSchema,
  updateMedicationSchema,
  createMedScheduleSchema,
  updateMedScheduleSchema,
  createMedIntakeSchema,
  updateMedIntakeSchema,
} from './medications.schemas';

const router = Router();

/**
 * @openapi
 * /api/medications:
 *   get:
 *     tags:
 *       - Medications
 *     summary: Get all medications
 *     description: Retrieve all medications, optionally filtered by elder user ID
 *     parameters:
 *       - in: query
 *         name: elderUserId
 *         schema:
 *           type: string
 *         description: Filter medications by elder user ID
 *     responses:
 *       200:
 *         description: Medications retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Medication'
 */
router.get('/', medicationController.getAllMedications);

/**
 * @openapi
 * /api/medications/{id}:
 *   get:
 *     tags:
 *       - Medications
 *     summary: Get medication by ID
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Medication ID
 *     responses:
 *       200:
 *         description: Medication retrieved successfully
 *       404:
 *         description: Medication not found
 */
router.get('/:id', medicationController.getMedicationById);

/**
 * @openapi
 * /api/medications:
 *   post:
 *     tags:
 *       - Medications
 *     summary: Create new medication
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - elderUserId
 *               - medicationName
 *             properties:
 *               elderUserId:
 *                 type: string
 *               medicationName:
 *                 type: string
 *               doseValue:
 *                 type: number
 *               doseUnitCode:
 *                 type: string
 *               formCode:
 *                 type: string
 *               instructions:
 *                 type: string
 *               notes:
 *                 type: string
 *     responses:
 *       201:
 *         description: Medication created successfully
 *       400:
 *         description: Validation error
 */
router.post('/', validate(createMedicationSchema), medicationController.createMedication);

/**
 * @openapi
 * /api/medications/{id}:
 *   put:
 *     tags:
 *       - Medications
 *     summary: Update medication
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               medicationName:
 *                 type: string
 *               doseValue:
 *                 type: number
 *               doseUnitCode:
 *                 type: string
 *               formCode:
 *                 type: string
 *               instructions:
 *                 type: string
 *               notes:
 *                 type: string
 *     responses:
 *       200:
 *         description: Medication updated successfully
 *       400:
 *         description: Validation error
 *       404:
 *         description: Medication not found
 */
router.put('/:id', validate(updateMedicationSchema), medicationController.updateMedication);

/**
 * @openapi
 * /api/medications/{id}:
 *   delete:
 *     tags:
 *       - Medications
 *     summary: Delete medication
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Medication deleted successfully
 */
router.delete('/:id', medicationController.deleteMedication);

/**
 * @openapi
 * /api/medications/{medicationId}/schedules:
 *   get:
 *     tags:
 *       - Medications
 *     summary: Get medication schedules
 *     parameters:
 *       - in: path
 *         name: medicationId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Schedules retrieved successfully
 */
router.get('/:medicationId/schedules', medicationController.getMedicationSchedules);

router.post(
  '/schedules',
  validate(createMedScheduleSchema),
  medicationController.createMedSchedule
);
router.put(
  '/schedules/:id',
  validate(updateMedScheduleSchema),
  medicationController.updateMedSchedule
);
router.delete('/schedules/:id', medicationController.deleteMedSchedule);

/**
 * @openapi
 * /api/medications/intakes/all:
 *   get:
 *     tags:
 *       - Medications
 *     summary: Get all medication intakes
 *     parameters:
 *       - in: query
 *         name: elderUserId
 *         schema:
 *           type: string
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [pending, taken, missed, skipped]
 *     responses:
 *       200:
 *         description: Intakes retrieved successfully
 */
router.get('/intakes/all', medicationController.getMedIntakes);
router.post('/intakes', validate(createMedIntakeSchema), medicationController.createMedIntake);
router.put('/intakes/:id', validate(updateMedIntakeSchema), medicationController.updateMedIntake);
router.delete('/intakes/:id', medicationController.deleteMedIntake);

/**
 * @openapi
 * /api/medications/adherence/{elderUserId}:
 *   get:
 *     tags:
 *       - Medications
 *     summary: Get medication adherence statistics
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
 *         description: Adherence stats retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 total:
 *                   type: integer
 *                 taken:
 *                   type: integer
 *                 missed:
 *                   type: integer
 *                 skipped:
 *                   type: integer
 *                 adherenceRate:
 *                   type: string
 */
router.get('/adherence/:elderUserId', medicationController.getMedAdherence);

export default router;

import { Router } from 'express';
import { lookupController } from './lookups.controller';
import { validate } from '../../middleware/validate.middleware';
import { createLookupSchema, updateLookupSchema } from './lookups.schemas';

const router = Router();

/**
 * @openapi
 * /api/lookups:
 *   get:
 *     tags:
 *       - Lookups
 *     summary: Get all lookups
 *     parameters:
 *       - in: query
 *         name: domain
 *         schema:
 *           type: string
 *         description: Filter by lookup domain
 *       - in: query
 *         name: isActive
 *         schema:
 *           type: boolean
 *     responses:
 *       200:
 *         description: Lookups retrieved successfully
 */
router.get('/', lookupController.getAllLookups);

/**
 * @openapi
 * /api/lookups/domains:
 *   get:
 *     tags:
 *       - Lookups
 *     summary: Get all lookup domains
 *     description: Returns a list of all available lookup domains (e.g., vital_kinds, med_forms)
 *     responses:
 *       200:
 *         description: Domains retrieved successfully
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
 *                     type: string
 *             example:
 *               success: true
 *               message: Domains retrieved successfully
 *               data: ["languages", "med_forms", "vital_kinds"]
 */
router.get('/domains', lookupController.getAllDomains);

/**
 * @openapi
 * /api/lookups/domain/{domain}:
 *   get:
 *     tags:
 *       - Lookups
 *     summary: Get lookups by domain
 *     description: Get all lookup values for a specific domain
 *     parameters:
 *       - in: path
 *         name: domain
 *         required: true
 *         schema:
 *           type: string
 *         description: Lookup domain name
 *         example: vital_kinds
 *     responses:
 *       200:
 *         description: Lookups retrieved successfully
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
 *                     $ref: '#/components/schemas/Lookup'
 */
router.get('/domain/:domain', lookupController.getLookupsByDomain);

router.get('/:id', lookupController.getLookupById);
router.post('/', validate(createLookupSchema), lookupController.createLookup);
router.put('/:id', validate(updateLookupSchema), lookupController.updateLookup);
router.delete('/:id', lookupController.deleteLookup);

export default router;

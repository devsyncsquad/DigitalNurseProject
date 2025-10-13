import { Router } from 'express';
import { elderAssignmentController } from './elder-assignments.controller';
import { validate } from '../../middleware/validate.middleware';
import {
  createElderAssignmentSchema,
  updateElderAssignmentSchema,
} from './elder-assignments.schemas';

const router = Router();

// ==================== Elder Assignment Routes ====================
router.get('/', elderAssignmentController.getAllAssignments);
router.get('/:id', elderAssignmentController.getAssignmentById);
router.post('/', validate(createElderAssignmentSchema), elderAssignmentController.createAssignment);
router.put(
  '/:id',
  validate(updateElderAssignmentSchema),
  elderAssignmentController.updateAssignment
);
router.delete('/:id', elderAssignmentController.deleteAssignment);

// ==================== Helper Routes ====================
router.get('/caregiver/:caregiverUserId/elders', elderAssignmentController.getEldersByCaregiver);
router.get('/elder/:elderUserId/caregivers', elderAssignmentController.getCaregiversByElder);
router.put(
  '/elder/:elderUserId/primary/:caregiverUserId',
  elderAssignmentController.setPrimaryCaregiver
);

export default router;

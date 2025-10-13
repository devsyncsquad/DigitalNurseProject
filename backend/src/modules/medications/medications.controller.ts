import { Request, Response } from 'express';
import { medicationService } from './medications.service';
import {
  createMedicationSchema,
  updateMedicationSchema,
  createMedScheduleSchema,
  updateMedScheduleSchema,
  createMedIntakeSchema,
  updateMedIntakeSchema,
} from './medications.schemas';
import { sendSuccess, sendError } from '../../utils/response.utils';

export class MedicationController {
  // ==================== Medications ====================

  async getAllMedications(req: Request, res: Response) {
    try {
      const { elderUserId } = req.query;
      const medications = await medicationService.getAllMedications(elderUserId as string);

      return sendSuccess(res, medications, 'Medications retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async getMedicationById(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const medication = await medicationService.getMedicationById(id);

      if (!medication) {
        return sendError(res, 'Medication not found', 404);
      }

      return sendSuccess(res, medication, 'Medication retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async createMedication(req: Request, res: Response) {
    try {
      const validatedData = createMedicationSchema.parse(req.body);
      const createdByUserId = (req.user as any)?.userId?.toString() || '1';

      const medication = await medicationService.createMedication(validatedData, createdByUserId);

      return sendSuccess(res, medication, 'Medication created successfully', 201);
    } catch (error: any) {
      return sendError(res, error.message, 400);
    }
  }

  async updateMedication(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const validatedData = updateMedicationSchema.parse(req.body);

      const medication = await medicationService.updateMedication(id, validatedData);

      return sendSuccess(res, medication, 'Medication updated successfully');
    } catch (error: any) {
      return sendError(res, error.message, 400);
    }
  }

  async deleteMedication(req: Request, res: Response) {
    try {
      const { id } = req.params;
      await medicationService.deleteMedication(id);

      return sendSuccess(res, null, 'Medication deleted successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  // ==================== Med Schedules ====================

  async getMedicationSchedules(req: Request, res: Response) {
    try {
      const { medicationId } = req.params;
      const schedules = await medicationService.getMedicationSchedules(medicationId);

      return sendSuccess(res, schedules, 'Medication schedules retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async createMedSchedule(req: Request, res: Response) {
    try {
      const validatedData = createMedScheduleSchema.parse(req.body);
      const schedule = await medicationService.createMedSchedule(validatedData);

      return sendSuccess(res, schedule, 'Medication schedule created successfully', 201);
    } catch (error: any) {
      return sendError(res, error.message, 400);
    }
  }

  async updateMedSchedule(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const validatedData = updateMedScheduleSchema.parse(req.body);

      const schedule = await medicationService.updateMedSchedule(id, validatedData);

      return sendSuccess(res, schedule, 'Medication schedule updated successfully');
    } catch (error: any) {
      return sendError(res, error.message, 400);
    }
  }

  async deleteMedSchedule(req: Request, res: Response) {
    try {
      const { id } = req.params;
      await medicationService.deleteMedSchedule(id);

      return sendSuccess(res, null, 'Medication schedule deleted successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  // ==================== Med Intakes ====================

  async getMedIntakes(req: Request, res: Response) {
    try {
      const { elderUserId, status } = req.query;
      const intakes = await medicationService.getMedIntakes(
        elderUserId as string,
        status as string
      );

      return sendSuccess(res, intakes, 'Medication intakes retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async createMedIntake(req: Request, res: Response) {
    try {
      const validatedData = createMedIntakeSchema.parse(req.body);
      const recordedByUserId = (req.user as any)?.userId?.toString();

      const intake = await medicationService.createMedIntake(validatedData, recordedByUserId);

      return sendSuccess(res, intake, 'Medication intake created successfully', 201);
    } catch (error: any) {
      return sendError(res, error.message, 400);
    }
  }

  async updateMedIntake(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const validatedData = updateMedIntakeSchema.parse(req.body);
      const recordedByUserId = (req.user as any)?.userId?.toString();

      const intake = await medicationService.updateMedIntake(id, validatedData, recordedByUserId);

      return sendSuccess(res, intake, 'Medication intake updated successfully');
    } catch (error: any) {
      return sendError(res, error.message, 400);
    }
  }

  async deleteMedIntake(req: Request, res: Response) {
    try {
      const { id } = req.params;
      await medicationService.deleteMedIntake(id);

      return sendSuccess(res, null, 'Medication intake deleted successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  // ==================== Analytics ====================

  async getMedAdherence(req: Request, res: Response) {
    try {
      const { elderUserId } = req.params;
      const { days } = req.query;

      const adherence = await medicationService.getMedAdherence(
        elderUserId,
        days ? parseInt(days as string) : 7
      );

      return sendSuccess(res, adherence, 'Medication adherence retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }
}

export const medicationController = new MedicationController();

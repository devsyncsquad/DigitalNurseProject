import { Request, Response } from 'express';
import { elderAssignmentService } from './elder-assignments.service';
import {
  createElderAssignmentSchema,
  updateElderAssignmentSchema,
} from './elder-assignments.schemas';
import { sendSuccess, sendError } from '../../utils/response.utils';

export class ElderAssignmentController {
  async getAllAssignments(req: Request, res: Response) {
    try {
      const { elderUserId, caregiverUserId } = req.query;

      const assignments = await elderAssignmentService.getAllAssignments(
        elderUserId as string,
        caregiverUserId as string
      );

      return sendSuccess(res, assignments, 'Assignments retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async getAssignmentById(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const assignment = await elderAssignmentService.getAssignmentById(id);

      if (!assignment) {
        return sendError(res, 'Assignment not found', 404);
      }

      return sendSuccess(res, assignment, 'Assignment retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async createAssignment(req: Request, res: Response) {
    try {
      const validatedData = createElderAssignmentSchema.parse(req.body);

      const assignment = await elderAssignmentService.createAssignment(validatedData);

      return sendSuccess(res, assignment, 'Assignment created successfully', 201);
    } catch (error: any) {
      return sendError(res, error.message, 400);
    }
  }

  async updateAssignment(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const validatedData = updateElderAssignmentSchema.parse(req.body);

      const assignment = await elderAssignmentService.updateAssignment(id, validatedData);

      return sendSuccess(res, assignment, 'Assignment updated successfully');
    } catch (error: any) {
      return sendError(res, error.message, 400);
    }
  }

  async deleteAssignment(req: Request, res: Response) {
    try {
      const { id } = req.params;
      await elderAssignmentService.deleteAssignment(id);

      return sendSuccess(res, null, 'Assignment deleted successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async getEldersByCaregiver(req: Request, res: Response) {
    try {
      const { caregiverUserId } = req.params;
      const elders = await elderAssignmentService.getEldersByCaregiver(caregiverUserId);

      return sendSuccess(res, elders, 'Elders retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async getCaregiversByElder(req: Request, res: Response) {
    try {
      const { elderUserId } = req.params;
      const caregivers = await elderAssignmentService.getCaregiversByElder(elderUserId);

      return sendSuccess(res, caregivers, 'Caregivers retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async setPrimaryCaregiver(req: Request, res: Response) {
    try {
      const { elderUserId, caregiverUserId } = req.params;

      await elderAssignmentService.setPrimaryCaregiver(elderUserId, caregiverUserId);

      return sendSuccess(res, null, 'Primary caregiver set successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }
}

export const elderAssignmentController = new ElderAssignmentController();

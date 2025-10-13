import { Request, Response } from 'express';
import { vitalService } from './vitals.service';
import { createVitalMeasurementSchema, updateVitalMeasurementSchema } from './vitals.schemas';
import { sendSuccess, sendError } from '../../utils/response.utils';

export class VitalController {
  async getAllVitals(req: Request, res: Response) {
    try {
      const { elderUserId, kindCode, startDate, endDate, limit } = req.query;

      const vitals = await vitalService.getAllVitals(
        elderUserId as string,
        kindCode as string,
        startDate as string,
        endDate as string,
        limit ? parseInt(limit as string) : 100
      );

      return sendSuccess(res, vitals, 'Vitals retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async getVitalById(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const vital = await vitalService.getVitalById(id);

      if (!vital) {
        return sendError(res, 'Vital measurement not found', 404);
      }

      return sendSuccess(res, vital, 'Vital retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async createVital(req: Request, res: Response) {
    try {
      const validatedData = createVitalMeasurementSchema.parse(req.body);
      const recordedByUserId = (req.user as any)?.userId?.toString();

      const vital = await vitalService.createVital(validatedData, recordedByUserId);

      return sendSuccess(res, vital, 'Vital measurement created successfully', 201);
    } catch (error: any) {
      return sendError(res, error.message, 400);
    }
  }

  async updateVital(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const validatedData = updateVitalMeasurementSchema.parse(req.body);
      const recordedByUserId = (req.user as any)?.userId?.toString();

      const vital = await vitalService.updateVital(id, validatedData, recordedByUserId);

      return sendSuccess(res, vital, 'Vital measurement updated successfully');
    } catch (error: any) {
      return sendError(res, error.message, 400);
    }
  }

  async deleteVital(req: Request, res: Response) {
    try {
      const { id } = req.params;
      await vitalService.deleteVital(id);

      return sendSuccess(res, null, 'Vital measurement deleted successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  // ==================== Analytics ====================

  async getLatestVitals(req: Request, res: Response) {
    try {
      const { elderUserId } = req.params;
      const vitals = await vitalService.getLatestVitals(elderUserId);

      return sendSuccess(res, vitals, 'Latest vitals retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async getVitalTrend(req: Request, res: Response) {
    try {
      const { elderUserId, kindCode } = req.params;
      const { days } = req.query;

      const trend = await vitalService.getVitalTrend(
        elderUserId,
        kindCode,
        days ? parseInt(days as string) : 7
      );

      return sendSuccess(res, trend, 'Vital trend retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async getVitalSummary(req: Request, res: Response) {
    try {
      const { elderUserId } = req.params;
      const { days } = req.query;

      const summary = await vitalService.getVitalSummary(
        elderUserId,
        days ? parseInt(days as string) : 7
      );

      return sendSuccess(res, summary, 'Vital summary retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }
}

export const vitalController = new VitalController();

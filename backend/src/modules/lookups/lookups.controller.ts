import { Request, Response } from 'express';
import { lookupService } from './lookups.service';
import { createLookupSchema, updateLookupSchema } from './lookups.schemas';
import { sendSuccess, sendError } from '../../utils/response.utils';

export class LookupController {
  async getAllLookups(req: Request, res: Response) {
    try {
      const { domain, isActive } = req.query;

      const lookups = await lookupService.getAllLookups(
        domain as string,
        isActive === 'true' ? true : isActive === 'false' ? false : undefined
      );

      return sendSuccess(res, lookups, 'Lookups retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async getLookupById(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const lookup = await lookupService.getLookupById(id);

      if (!lookup) {
        return sendError(res, 'Lookup not found', 404);
      }

      return sendSuccess(res, lookup, 'Lookup retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async getLookupsByDomain(req: Request, res: Response) {
    try {
      const { domain } = req.params;
      const lookups = await lookupService.getLookupsByDomain(domain);

      return sendSuccess(res, lookups, 'Lookups retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async createLookup(req: Request, res: Response) {
    try {
      const validatedData = createLookupSchema.parse(req.body);

      const lookup = await lookupService.createLookup(validatedData);

      return sendSuccess(res, lookup, 'Lookup created successfully', 201);
    } catch (error: any) {
      return sendError(res, error.message, 400);
    }
  }

  async updateLookup(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const validatedData = updateLookupSchema.parse(req.body);

      const lookup = await lookupService.updateLookup(id, validatedData);

      return sendSuccess(res, lookup, 'Lookup updated successfully');
    } catch (error: any) {
      return sendError(res, error.message, 400);
    }
  }

  async deleteLookup(req: Request, res: Response) {
    try {
      const { id } = req.params;
      await lookupService.deleteLookup(id);

      return sendSuccess(res, null, 'Lookup deleted successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async getAllDomains(req: Request, res: Response) {
    try {
      const domains = await lookupService.getAllDomains();

      return sendSuccess(res, domains, 'Domains retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }
}

export const lookupController = new LookupController();

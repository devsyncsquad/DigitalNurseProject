import { Response } from 'express';

export interface ApiResponse<T = unknown> {
  success: boolean;
  message?: string;
  data?: T;
  error?: string;
}

/**
 * Send success response
 */
export const sendSuccess = <T>(
  res: Response,
  data?: T,
  message?: string,
  statusCode: number = 200
): Response => {
  const response: ApiResponse<T> = {
    success: true,
    ...(message && { message }),
    ...(data && { data }),
  };
  return res.status(statusCode).json(response);
};

/**
 * Send error response
 */
export const sendError = (
  res: Response,
  error: string,
  statusCode: number = 400,
  message?: string
): Response => {
  const response: ApiResponse = {
    success: false,
    error,
    ...(message && { message }),
  };
  return res.status(statusCode).json(response);
};

/**
 * Send created response
 */
export const sendCreated = <T>(res: Response, data: T, message?: string): Response => {
  return sendSuccess(res, data, message, 201);
};

/**
 * Send no content response
 */
export const sendNoContent = (res: Response): Response => {
  return res.status(204).send();
};


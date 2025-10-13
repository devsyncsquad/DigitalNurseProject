import { Request, Response } from 'express';
import { notificationService } from './notifications.service';
import {
  createNotificationSchema,
  updateNotificationSchema,
  markAsReadSchema,
} from './notifications.schemas';
import { sendSuccess, sendError } from '../../utils/response.utils';

export class NotificationController {
  async getAllNotifications(req: Request, res: Response) {
    try {
      const { userId, status, isRead } = req.query;

      const notifications = await notificationService.getAllNotifications(
        userId as string,
        status as string,
        isRead === 'true' ? true : isRead === 'false' ? false : undefined
      );

      return sendSuccess(res, notifications, 'Notifications retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async getNotificationById(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const notification = await notificationService.getNotificationById(id);

      if (!notification) {
        return sendError(res, 'Notification not found', 404);
      }

      return sendSuccess(res, notification, 'Notification retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async createNotification(req: Request, res: Response) {
    try {
      const validatedData = createNotificationSchema.parse(req.body);

      const notification = await notificationService.createNotification(validatedData);

      return sendSuccess(res, notification, 'Notification created successfully', 201);
    } catch (error: any) {
      return sendError(res, error.message, 400);
    }
  }

  async updateNotification(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const validatedData = updateNotificationSchema.parse(req.body);

      const notification = await notificationService.updateNotification(id, validatedData);

      return sendSuccess(res, notification, 'Notification updated successfully');
    } catch (error: any) {
      return sendError(res, error.message, 400);
    }
  }

  async deleteNotification(req: Request, res: Response) {
    try {
      const { id } = req.params;
      await notificationService.deleteNotification(id);

      return sendSuccess(res, null, 'Notification deleted successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async markAsRead(req: Request, res: Response) {
    try {
      const validatedData = markAsReadSchema.parse(req.body);

      await notificationService.markAsRead(validatedData.notificationIds);

      return sendSuccess(res, null, 'Notifications marked as read successfully');
    } catch (error: any) {
      return sendError(res, error.message, 400);
    }
  }

  async markAllAsRead(req: Request, res: Response) {
    try {
      const { userId } = req.params;

      await notificationService.markAllAsRead(userId);

      return sendSuccess(res, null, 'All notifications marked as read successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async getUnreadCount(req: Request, res: Response) {
    try {
      const { userId } = req.params;

      const count = await notificationService.getUnreadCount(userId);

      return sendSuccess(res, { count }, 'Unread count retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async getUserNotifications(req: Request, res: Response) {
    try {
      const { userId } = req.params;
      const { limit } = req.query;

      const notifications = await notificationService.getUserNotifications(
        userId,
        limit ? parseInt(limit as string) : 50
      );

      return sendSuccess(res, notifications, 'User notifications retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async getPendingNotifications(req: Request, res: Response) {
    try {
      const notifications = await notificationService.getPendingNotifications();

      return sendSuccess(res, notifications, 'Pending notifications retrieved successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }

  async markAsSent(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const notification = await notificationService.markAsSent(id);

      return sendSuccess(res, notification, 'Notification marked as sent successfully');
    } catch (error: any) {
      return sendError(res, error.message, 500);
    }
  }
}

export const notificationController = new NotificationController();

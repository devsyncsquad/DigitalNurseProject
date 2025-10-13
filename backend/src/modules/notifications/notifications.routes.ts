import { Router } from 'express';
import { notificationController } from './notifications.controller';
import { validate } from '../../middleware/validate.middleware';
import {
  createNotificationSchema,
  updateNotificationSchema,
  markAsReadSchema,
} from './notifications.schemas';

const router = Router();

// ==================== Notification Routes ====================
router.get('/', notificationController.getAllNotifications);
router.get('/pending', notificationController.getPendingNotifications);
router.get('/:id', notificationController.getNotificationById);
router.post('/', validate(createNotificationSchema), notificationController.createNotification);
router.put('/:id', validate(updateNotificationSchema), notificationController.updateNotification);
router.delete('/:id', notificationController.deleteNotification);

// ==================== User Notification Routes ====================
router.get('/user/:userId', notificationController.getUserNotifications);
router.get('/user/:userId/unread-count', notificationController.getUnreadCount);
router.put('/user/:userId/mark-all-read', notificationController.markAllAsRead);

// ==================== Mark as Read ====================
router.post('/mark-as-read', validate(markAsReadSchema), notificationController.markAsRead);
router.put('/:id/mark-as-sent', notificationController.markAsSent);

export default router;

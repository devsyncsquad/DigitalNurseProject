import { prisma } from '../../config/database';
import { CreateNotificationInput, UpdateNotificationInput } from './notifications.schemas';

export class NotificationService {
  async getAllNotifications(userId?: string, status?: string, isRead?: boolean) {
    const where: any = {};

    if (userId) {
      where.userId = BigInt(userId);
    }

    if (status) {
      where.status = status;
    }

    if (isRead !== undefined) {
      where.isRead = isRead;
    }

    return await prisma.notification.findMany({
      where,
      include: {
        user: {
          select: {
            userId: true,
            full_name: true,
            email: true,
          },
        },
        notificationLogs: {
          select: {
            logId: true,
            deliveryStatus: true,
            sentAt: true,
            responseMessage: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
      take: 100,
    });
  }

  async getNotificationById(notificationId: string) {
    return await prisma.notification.findUnique({
      where: { notificationId: BigInt(notificationId) },
      include: {
        user: {
          select: {
            userId: true,
            full_name: true,
            email: true,
          },
        },
        notificationLogs: true,
      },
    });
  }

  async createNotification(data: CreateNotificationInput) {
    return await prisma.notification.create({
      data: {
        userId: BigInt(data.userId),
        title: data.title,
        message: data.message,
        notificationType: data.notificationType,
        scheduledTime: data.scheduledTime ? new Date(data.scheduledTime) : null,
        status: 'pending',
        isRead: false,
        isSent: false,
      },
      include: {
        user: {
          select: {
            userId: true,
            full_name: true,
            email: true,
          },
        },
      },
    });
  }

  async updateNotification(notificationId: string, data: UpdateNotificationInput) {
    return await prisma.notification.update({
      where: { notificationId: BigInt(notificationId) },
      data: {
        title: data.title,
        message: data.message,
        notificationType: data.notificationType,
        scheduledTime: data.scheduledTime
          ? new Date(data.scheduledTime)
          : data.scheduledTime === null
            ? null
            : undefined,
        isRead: data.isRead,
        isSent: data.isSent,
        status: data.status,
      },
      include: {
        user: {
          select: {
            userId: true,
            full_name: true,
          },
        },
      },
    });
  }

  async deleteNotification(notificationId: string) {
    return await prisma.notification.delete({
      where: { notificationId: BigInt(notificationId) },
    });
  }

  async markAsRead(notificationIds: (string | number)[]) {
    const ids = notificationIds.map((id) => BigInt(id));

    return await prisma.notification.updateMany({
      where: {
        notificationId: { in: ids },
      },
      data: {
        isRead: true,
      },
    });
  }

  async markAllAsRead(userId: string) {
    return await prisma.notification.updateMany({
      where: {
        userId: BigInt(userId),
        isRead: false,
      },
      data: {
        isRead: true,
      },
    });
  }

  async getUnreadCount(userId: string) {
    return await prisma.notification.count({
      where: {
        userId: BigInt(userId),
        isRead: false,
      },
    });
  }

  async getUserNotifications(userId: string, limit: number = 50) {
    return await prisma.notification.findMany({
      where: { userId: BigInt(userId) },
      orderBy: {
        createdAt: 'desc',
      },
      take: limit,
      include: {
        notificationLogs: {
          select: {
            deliveryStatus: true,
            sentAt: true,
            responseMessage: true,
          },
        },
      },
    });
  }

  async getPendingNotifications() {
    const now = new Date();

    return await prisma.notification.findMany({
      where: {
        status: 'pending',
        isSent: false,
        OR: [{ scheduledTime: null }, { scheduledTime: { lte: now } }],
      },
      include: {
        user: {
          select: {
            userId: true,
            full_name: true,
            email: true,
            phone: true,
          },
        },
      },
      orderBy: {
        scheduledTime: 'asc',
      },
    });
  }

  async markAsSent(notificationId: string) {
    return await prisma.notification.update({
      where: { notificationId: BigInt(notificationId) },
      data: {
        isSent: true,
        sentTime: new Date(),
        status: 'sent',
      },
    });
  }

  async createNotificationLog(
    notificationId: string,
    deliveryStatus: string,
    responseMessage?: string
  ) {
    return await prisma.notificationLog.create({
      data: {
        notificationId: BigInt(notificationId),
        deliveryStatus,
        sentAt: deliveryStatus === 'success' ? new Date() : null,
        responseMessage,
      },
    });
  }
}

export const notificationService = new NotificationService();

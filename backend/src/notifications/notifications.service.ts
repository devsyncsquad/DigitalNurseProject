import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateNotificationDto, NotificationType } from './dto/create-notification.dto';

@Injectable()
export class NotificationsService {
  constructor(private prisma: PrismaService) {}

  /**
   * Create notification
   */
  async create(userId: bigint, createDto: CreateNotificationDto) {
    const notification = await this.prisma.notification.create({
      data: {
        userId,
        title: createDto.title,
        message: createDto.body,
        notificationType: createDto.type,
        scheduledTime: createDto.scheduledTime ? new Date(createDto.scheduledTime) : null,
        actionData: createDto.actionData ? (createDto.actionData as any) : null,
        status: 'pending',
        isRead: false,
        isSent: false,
      },
    });

    return this.mapToResponse(notification);
  }

  /**
   * Find all notifications for a user
   */
  async findAll(userId: bigint, isRead?: boolean) {
    const where: any = { userId };
    if (isRead !== undefined) {
      where.isRead = isRead;
    }

    const notifications = await this.prisma.notification.findMany({
      where,
      orderBy: {
        createdAt: 'desc',
      },
    });

    return notifications.map((n) => this.mapToResponse(n));
  }

  /**
   * Get unread notifications
   */
  async getUnread(userId: bigint) {
    const notifications = await this.prisma.notification.findMany({
      where: {
        userId,
        isRead: false,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return notifications.map((n) => this.mapToResponse(n));
  }

  /**
   * Get unread count
   */
  async getUnreadCount(userId: bigint) {
    const count = await this.prisma.notification.count({
      where: {
        userId,
        isRead: false,
      },
    });

    return { count };
  }

  /**
   * Mark notification as read
   */
  async markAsRead(userId: bigint, notificationId: bigint) {
    const notification = await this.prisma.notification.findFirst({
      where: {
        notificationId,
        userId,
      },
    });

    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    const updated = await this.prisma.notification.update({
      where: { notificationId },
      data: { isRead: true },
    });

    return this.mapToResponse(updated);
  }

  /**
   * Mark all notifications as read
   */
  async markAllAsRead(userId: bigint) {
    await this.prisma.notification.updateMany({
      where: {
        userId,
        isRead: false,
      },
      data: {
        isRead: true,
      },
    });

    return { message: 'All notifications marked as read' };
  }

  /**
   * Delete notification
   */
  async remove(userId: bigint, notificationId: bigint) {
    const notification = await this.prisma.notification.findFirst({
      where: {
        notificationId,
        userId,
      },
    });

    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    await this.prisma.notification.delete({
      where: { notificationId },
    });

    return { message: 'Notification deleted successfully' };
  }

  /**
   * Map database model to API response
   */
  private mapToResponse(notification: any) {
    return {
      id: notification.notificationId.toString(),
      title: notification.title,
      body: notification.message,
      type: notification.notificationType,
      timestamp: (notification.scheduledTime || notification.sentTime || notification.createdAt).toISOString(),
      isRead: notification.isRead,
      actionData: notification.actionData ? JSON.stringify(notification.actionData) : null,
    };
  }
}


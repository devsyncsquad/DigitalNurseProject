import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateDeviceDto } from './dto/create-device.dto';

@Injectable()
export class DevicesService {
  constructor(private prisma: PrismaService) {}

  /**
   * Register or update device
   */
  async register(userId: bigint, createDto: CreateDeviceDto, ipAddress?: string, userAgent?: string) {
    // Check if device already exists for this user with same push token
    const existing = await this.prisma.userDevice.findFirst({
      where: {
        userId,
        pushToken: createDto.pushToken || undefined,
      },
    });

    if (existing) {
      // Update existing device
      const updated = await this.prisma.userDevice.update({
        where: { deviceId: existing.deviceId },
        data: {
          platform: createDto.platform,
          deviceModel: createDto.deviceModel || null,
          osName: createDto.osName || null,
          osVersion: createDto.osVersion || null,
          appVersion: createDto.appVersion || null,
          pushToken: createDto.pushToken || null,
          lastLoginAt: new Date(),
          lastSeenAt: new Date(),
          ipAddress: ipAddress || null,
          userAgent: userAgent || null,
        },
      });

      return this.mapToResponse(updated);
    }

    // Create new device
    const device = await this.prisma.userDevice.create({
      data: {
        userId,
        platform: createDto.platform,
        deviceModel: createDto.deviceModel || null,
        osName: createDto.osName || null,
        osVersion: createDto.osVersion || null,
        appVersion: createDto.appVersion || null,
        pushToken: createDto.pushToken || null,
        lastLoginAt: new Date(),
        lastSeenAt: new Date(),
        ipAddress: ipAddress || null,
        userAgent: userAgent || null,
      },
    });

    return this.mapToResponse(device);
  }

  /**
   * Get all devices for a user
   */
  async findAll(userId: bigint) {
    const devices = await this.prisma.userDevice.findMany({
      where: { userId },
      orderBy: {
        lastLoginAt: 'desc',
      },
    });

    return devices.map((d) => this.mapToResponse(d));
  }

  /**
   * Map database model to API response
   */
  private mapToResponse(device: any) {
    return {
      id: device.deviceId.toString(),
      platform: device.platform,
      deviceModel: device.deviceModel,
      osName: device.osName,
      osVersion: device.osVersion,
      appVersion: device.appVersion,
      pushToken: device.pushToken,
      lastLoginAt: device.lastLoginAt?.toISOString() || null,
      lastSeenAt: device.lastSeenAt?.toISOString() || null,
    };
  }
}


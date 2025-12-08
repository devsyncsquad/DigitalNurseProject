import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AppConfigService {
  constructor(private prisma: PrismaService) {}

  /**
   * Get a config value by key
   */
  async getConfigByKey(configKey: string) {
    return this.prisma.appConfig.findUnique({
      where: { configKey, isActive: true },
      select: {
        configKey: true,
        configValue: true,
        description: true,
      },
    });
  }

  /**
   * Get the Gemini API key specifically
   */
  async getGeminiApiKey() {
    const config = await this.prisma.appConfig.findUnique({
      where: { configKey: 'gemini_api_key' },
      select: {
        configValue: true,
        isActive: true,
      },
    });

    if (!config || !config.isActive) {
      return null;
    }

    return config.configValue;
  }

  /**
   * Get all active config values
   */
  async getAllConfig() {
    return this.prisma.appConfig.findMany({
      where: { isActive: true },
      select: {
        configKey: true,
        configValue: true,
        description: true,
      },
    });
  }

  /**
   * Upsert a config value (create or update)
   */
  async upsertConfig(
    configKey: string,
    configValue: string,
    description?: string,
  ) {
    return this.prisma.appConfig.upsert({
      where: { configKey },
      update: {
        configValue,
        description,
        updatedAt: new Date(),
      },
      create: {
        configKey,
        configValue,
        description,
        isActive: true,
      },
    });
  }

  /**
   * Deactivate a config value (soft delete)
   */
  async deactivateConfig(configKey: string) {
    return this.prisma.appConfig.update({
      where: { configKey },
      data: { isActive: false },
    });
  }
}

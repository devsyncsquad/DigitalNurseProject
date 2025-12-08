import { Controller, Get, NotFoundException } from '@nestjs/common';
import { AppConfigService } from './config.service';

@Controller('config')
export class AppConfigController {
  constructor(private readonly configService: AppConfigService) {}

  /**
   * GET /config/gemini-api-key
   * Returns the Gemini API key from the database
   * This endpoint requires authentication (JWT guard is applied globally)
   */
  @Get('gemini-api-key')
  async getGeminiApiKey() {
    const apiKey = await this.configService.getGeminiApiKey();

    if (!apiKey) {
      throw new NotFoundException('Gemini API key not configured');
    }

    return {
      apiKey,
      config_key: 'gemini_api_key',
      config_value: apiKey,
    };
  }

  /**
   * GET /config
   * Returns all active configuration values
   * This endpoint requires authentication (JWT guard is applied globally)
   */
  @Get()
  async getAllConfig() {
    const configs = await this.configService.getAllConfig();
    return configs;
  }
}

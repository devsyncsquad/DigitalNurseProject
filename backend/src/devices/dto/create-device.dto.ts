import { IsString, IsNotEmpty, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateDeviceDto {
  @ApiProperty({ example: 'android', description: 'Platform (android/ios)' })
  @IsString()
  @IsNotEmpty()
  platform!: string;

  @ApiPropertyOptional({ example: 'Samsung Galaxy S21' })
  @IsString()
  @IsOptional()
  deviceModel?: string;

  @ApiPropertyOptional({ example: 'Android' })
  @IsString()
  @IsOptional()
  osName?: string;

  @ApiPropertyOptional({ example: '12' })
  @IsString()
  @IsOptional()
  osVersion?: string;

  @ApiPropertyOptional({ example: '1.0.0' })
  @IsString()
  @IsOptional()
  appVersion?: string;

  @ApiPropertyOptional({ example: 'fcm-token-here', description: 'Push notification token' })
  @IsString()
  @IsOptional()
  pushToken?: string;
}


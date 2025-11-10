import { IsString, IsNotEmpty, IsOptional, IsDateString, IsEnum, IsObject } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export enum NotificationType {
  MEDICINE_REMINDER = 'medicineReminder',
  HEALTH_ALERT = 'healthAlert',
  CAREGIVER_INVITATION = 'caregiverInvitation',
  MISSED_DOSE = 'missedDose',
  GENERAL = 'general',
}

export class CreateNotificationDto {
  @ApiPropertyOptional({
    example: '1',
    description: 'Target elder user ID (required when caregiver)',
  })
  @IsString()
  @IsOptional()
  elderUserId?: string;

  @ApiProperty({ example: 'Medicine Reminder', description: 'Notification title' })
  @IsString()
  @IsNotEmpty()
  title!: string;

  @ApiProperty({ example: 'Time to take Aspirin', description: 'Notification message' })
  @IsString()
  @IsNotEmpty()
  body!: string;

  @ApiProperty({ enum: NotificationType, example: NotificationType.MEDICINE_REMINDER })
  @IsEnum(NotificationType)
  type!: NotificationType;

  @ApiPropertyOptional({ example: '2024-01-15T08:00:00Z', description: 'Scheduled time' })
  @IsDateString()
  @IsOptional()
  scheduledTime?: string;

  @ApiPropertyOptional({ example: '{"medicineId": "123"}', description: 'Action data as JSON' })
  @IsObject()
  @IsOptional()
  actionData?: any;
}


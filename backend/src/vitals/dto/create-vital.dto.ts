import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsDateString,
  IsEnum,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export enum VitalType {
  BLOOD_PRESSURE = 'bloodPressure',
  BLOOD_SUGAR = 'bloodSugar',
  HEART_RATE = 'heartRate',
  TEMPERATURE = 'temperature',
  OXYGEN_SATURATION = 'oxygenSaturation',
  WEIGHT = 'weight',
}

export class CreateVitalDto {
  @ApiProperty({ enum: VitalType, example: VitalType.BLOOD_PRESSURE })
  @IsEnum(VitalType)
  type!: VitalType;

  @ApiProperty({
    example: '120/80',
    description: 'Value as string. For blood pressure use "systolic/diastolic" format',
  })
  @IsString()
  @IsNotEmpty()
  value!: string;

  @ApiProperty({ example: '2024-01-15T08:00:00Z', description: 'Timestamp' })
  @IsDateString()
  timestamp!: string;

  @ApiPropertyOptional({ example: 'Morning reading' })
  @IsString()
  @IsOptional()
  notes?: string;
}


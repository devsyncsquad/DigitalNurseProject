import { IsString, IsOptional, IsNumber, IsEnum, IsArray } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export enum InsightType {
  MEDICATION_ADHERENCE = 'medication_adherence',
  HEALTH_TREND = 'health_trend',
  RECOMMENDATION = 'recommendation',
  ALERT = 'alert',
  PATTERN_DETECTION = 'pattern_detection',
}

export enum InsightPriority {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  CRITICAL = 'critical',
}

export enum InsightCategory {
  MEDICATION = 'medication',
  VITALS = 'vitals',
  LIFESTYLE = 'lifestyle',
  GENERAL = 'general',
}

export class GenerateInsightDto {
  @ApiProperty({
    description: 'Type of insight to generate',
    enum: InsightType,
  })
  @IsEnum(InsightType)
  insightType: InsightType;

  @ApiProperty({
    description: 'Elder user ID for the insight',
  })
  @IsNumber()
  elderUserId: bigint;

  @ApiPropertyOptional({
    description: 'Priority level',
    enum: InsightPriority,
    default: InsightPriority.MEDIUM,
  })
  @IsOptional()
  @IsEnum(InsightPriority)
  priority?: InsightPriority;

  @ApiPropertyOptional({
    description: 'Category of insight',
    enum: InsightCategory,
  })
  @IsOptional()
  @IsEnum(InsightCategory)
  category?: InsightCategory;

  @ApiPropertyOptional({
    description: 'Additional metadata',
  })
  @IsOptional()
  metadata?: Record<string, any>;
}

export class GetInsightsDto {
  @ApiPropertyOptional({
    description: 'Filter by insight type',
    enum: InsightType,
    isArray: true,
  })
  @IsOptional()
  @IsArray()
  @IsEnum(InsightType, { each: true })
  types?: InsightType[];

  @ApiPropertyOptional({
    description: 'Filter by priority',
    enum: InsightPriority,
    isArray: true,
  })
  @IsOptional()
  @IsArray()
  @IsEnum(InsightPriority, { each: true })
  priorities?: InsightPriority[];

  @ApiPropertyOptional({
    description: 'Filter by category',
    enum: InsightCategory,
    isArray: true,
  })
  @IsOptional()
  @IsArray()
  @IsEnum(InsightCategory, { each: true })
  categories?: InsightCategory[];

  @ApiPropertyOptional({
    description: 'Filter by read status',
  })
  @IsOptional()
  isRead?: boolean;

  @ApiPropertyOptional({
    description: 'Elder user ID to filter',
  })
  @IsOptional()
  @IsNumber()
  elderUserId?: bigint;

  @ApiPropertyOptional({
    description: 'Limit number of results',
    default: 20,
  })
  @IsOptional()
  @IsNumber()
  limit?: number;
}


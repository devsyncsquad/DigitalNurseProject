import { IsString, IsNotEmpty, IsOptional, IsEnum } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export enum DocumentType {
  PRESCRIPTION = 'prescription',
  LAB_REPORT = 'labReport',
  XRAY = 'xray',
  SCAN = 'scan',
  DISCHARGE = 'discharge',
  INSURANCE = 'insurance',
  OTHER = 'other',
}

export enum DocumentVisibility {
  PRIVATE = 'private',
  SHARED_WITH_CAREGIVER = 'sharedWithCaregiver',
  PUBLIC = 'public',
}

export class CreateDocumentDto {
  @ApiProperty({ example: 'Blood Test Results', description: 'Document title' })
  @IsString()
  @IsNotEmpty()
  title!: string;

  @ApiProperty({ enum: DocumentType, example: DocumentType.LAB_REPORT })
  @IsEnum(DocumentType)
  type!: DocumentType;

  @ApiPropertyOptional({ example: 'Complete blood count', description: 'Document description' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({ enum: DocumentVisibility, example: DocumentVisibility.PRIVATE })
  @IsEnum(DocumentVisibility)
  @IsOptional()
  visibility?: DocumentVisibility;
}


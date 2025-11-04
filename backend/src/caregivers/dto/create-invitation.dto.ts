import { IsString, IsNotEmpty, IsOptional, IsEnum } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateInvitationDto {
  @ApiProperty({ example: '+1234567890', description: 'Phone number of caregiver to invite' })
  @IsString()
  @IsNotEmpty()
  phone!: string;

  @ApiPropertyOptional({ example: 'John Doe', description: 'Name of caregiver (optional)' })
  @IsString()
  @IsOptional()
  name?: string;

  @ApiProperty({ example: 'son', description: 'Relationship code' })
  @IsString()
  @IsNotEmpty()
  relationship!: string;

  @ApiPropertyOptional({
    example: '1',
    description: 'Elder user ID (defaults to current user)',
  })
  @IsString()
  @IsOptional()
  elderUserId?: string;
}


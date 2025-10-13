import { IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { SubscriptionPlanType } from '@prisma/client';

export class CreateSubscriptionDto {
  @ApiProperty({ enum: ['BASIC', 'PREMIUM'] })
  @IsEnum(SubscriptionPlanType)
  planType!: SubscriptionPlanType;
}

import { IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum SubscriptionPlanType {
  FREE = 'FREE',
  BASIC = 'BASIC',
  PREMIUM = 'PREMIUM',
}

export class CreateSubscriptionDto {
  @ApiProperty({ enum: SubscriptionPlanType, example: SubscriptionPlanType.BASIC })
  @IsEnum(SubscriptionPlanType)
  planType!: SubscriptionPlanType;
}

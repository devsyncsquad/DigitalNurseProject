import { IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { SubscriptionPlanType } from './create-subscription.dto';

export class UpgradeSubscriptionDto {
  @ApiProperty({ enum: SubscriptionPlanType, example: SubscriptionPlanType.PREMIUM })
  @IsEnum(SubscriptionPlanType)
  newPlanType!: SubscriptionPlanType;
}

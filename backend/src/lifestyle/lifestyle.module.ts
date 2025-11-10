import { Module } from '@nestjs/common';
import { LifestyleService } from './lifestyle.service';
import { LifestyleController } from './lifestyle.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { AccessControlService } from '../common/services/access-control.service';

@Module({
  imports: [PrismaModule],
  controllers: [LifestyleController],
  providers: [LifestyleService, AccessControlService],
  exports: [LifestyleService],
})
export class LifestyleModule {}


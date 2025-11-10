import { Module } from '@nestjs/common';
import { VitalsService } from './vitals.service';
import { VitalsController } from './vitals.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { AccessControlService } from '../common/services/access-control.service';

@Module({
  imports: [PrismaModule],
  controllers: [VitalsController],
  providers: [VitalsService, AccessControlService],
  exports: [VitalsService],
})
export class VitalsModule {}


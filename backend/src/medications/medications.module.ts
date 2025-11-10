import { Module } from '@nestjs/common';
import { MedicationsService } from './medications.service';
import { MedicationsController } from './medications.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { AccessControlService } from '../common/services/access-control.service';

@Module({
  imports: [PrismaModule],
  controllers: [MedicationsController],
  providers: [MedicationsService, AccessControlService],
  exports: [MedicationsService],
})
export class MedicationsModule {}


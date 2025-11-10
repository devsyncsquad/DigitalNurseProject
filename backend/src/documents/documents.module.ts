import { Module } from '@nestjs/common';
import { DocumentsService } from './documents.service';
import { DocumentsController } from './documents.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { AccessControlService } from '../common/services/access-control.service';

@Module({
  imports: [PrismaModule],
  controllers: [DocumentsController],
  providers: [DocumentsService, AccessControlService],
  exports: [DocumentsService],
})
export class DocumentsModule {}


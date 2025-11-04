import { Module } from '@nestjs/common';
import { LifestyleService } from './lifestyle.service';
import { LifestyleController } from './lifestyle.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [LifestyleController],
  providers: [LifestyleService],
  exports: [LifestyleService],
})
export class LifestyleModule {}


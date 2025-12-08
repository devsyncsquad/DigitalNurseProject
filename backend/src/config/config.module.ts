import { Module } from '@nestjs/common';
import { AppConfigController } from './config.controller';
import { AppConfigService } from './config.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [AppConfigController],
  providers: [AppConfigService],
  exports: [AppConfigService],
})
export class AppConfigModule {}

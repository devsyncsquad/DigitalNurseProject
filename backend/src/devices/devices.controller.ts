import { Controller, Get, Post, Body, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { DevicesService } from './devices.service';
import { CreateDeviceDto } from './dto/create-device.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Devices')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('devices')
export class DevicesController {
  constructor(private readonly devicesService: DevicesService) {}

  @Post()
  @ApiOperation({ summary: 'Register or update device for push notifications' })
  @ApiResponse({ status: 201, description: 'Device registered successfully' })
  register(
    @CurrentUser() user: any,
    @Body() createDto: CreateDeviceDto,
    @Req() req: any,
  ) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    const ipAddress = req.ip || req.headers['x-forwarded-for']?.toString() || undefined;
    const userAgent = req.headers['user-agent'] || undefined;
    return this.devicesService.register(userId, createDto, ipAddress, userAgent);
  }

  @Get()
  @ApiOperation({ summary: 'Get all devices for the current user' })
  @ApiResponse({ status: 200, description: 'List of devices' })
  findAll(@CurrentUser() user: any) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.devicesService.findAll(userId);
  }
}


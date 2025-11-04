import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  ParseIntPipe,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { VitalsService } from './vitals.service';
import { CreateVitalDto, VitalType } from './dto/create-vital.dto';
import { UpdateVitalDto } from './dto/update-vital.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Vitals')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('vitals')
export class VitalsController {
  constructor(private readonly vitalsService: VitalsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new vital measurement' })
  @ApiResponse({ status: 201, description: 'Vital measurement created successfully' })
  create(@CurrentUser() user: any, @Body() createDto: CreateVitalDto) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.vitalsService.create(userId, createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all vital measurements for the current user' })
  @ApiQuery({ name: 'type', enum: VitalType, required: false })
  @ApiQuery({ name: 'startDate', required: false, type: String })
  @ApiQuery({ name: 'endDate', required: false, type: String })
  @ApiResponse({ status: 200, description: 'List of vital measurements' })
  findAll(
    @CurrentUser() user: any,
    @Query('type') type?: VitalType,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.vitalsService.findAll(
      userId,
      type,
      startDate ? new Date(startDate) : undefined,
      endDate ? new Date(endDate) : undefined,
    );
  }

  @Get('latest')
  @ApiOperation({ summary: 'Get latest vital measurements per kind' })
  @ApiResponse({ status: 200, description: 'Latest vital measurements' })
  getLatest(@CurrentUser() user: any) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.vitalsService.getLatest(userId);
  }

  @Get('trends')
  @ApiOperation({ summary: 'Get 7-day trends for vital measurements' })
  @ApiQuery({ name: 'kindCode', required: false, type: String })
  @ApiResponse({ status: 200, description: 'Trend data' })
  getTrends(@CurrentUser() user: any, @Query('kindCode') kindCode?: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.vitalsService.getTrends(userId, kindCode);
  }

  @Get('abnormal')
  @ApiOperation({ summary: 'Get abnormal vital readings' })
  @ApiResponse({ status: 200, description: 'List of abnormal readings' })
  getAbnormal(@CurrentUser() user: any) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.vitalsService.getAbnormal(userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a vital measurement by ID' })
  @ApiResponse({ status: 200, description: 'Vital measurement details' })
  @ApiResponse({ status: 404, description: 'Vital measurement not found' })
  findOne(@CurrentUser() user: any, @Param('id', ParseIntPipe) id: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.vitalsService.findOne(userId, BigInt(id));
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a vital measurement' })
  @ApiResponse({ status: 200, description: 'Vital measurement updated successfully' })
  @ApiResponse({ status: 404, description: 'Vital measurement not found' })
  update(
    @CurrentUser() user: any,
    @Param('id', ParseIntPipe) id: string,
    @Body() updateDto: UpdateVitalDto,
  ) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.vitalsService.update(userId, BigInt(id), updateDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a vital measurement' })
  @ApiResponse({ status: 200, description: 'Vital measurement deleted successfully' })
  @ApiResponse({ status: 404, description: 'Vital measurement not found' })
  remove(@CurrentUser() user: any, @Param('id', ParseIntPipe) id: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.vitalsService.remove(userId, BigInt(id));
  }
}


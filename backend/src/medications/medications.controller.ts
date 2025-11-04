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
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { MedicationsService } from './medications.service';
import { CreateMedicationDto } from './dto/create-medication.dto';
import { UpdateMedicationDto } from './dto/update-medication.dto';
import { LogIntakeDto } from './dto/log-intake.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Medications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('medications')
export class MedicationsController {
  constructor(private readonly medicationsService: MedicationsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new medication' })
  @ApiResponse({ status: 201, description: 'Medication created successfully' })
  create(@CurrentUser() user: any, @Body() createDto: CreateMedicationDto) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.medicationsService.create(userId, createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all medications for the current user' })
  @ApiResponse({ status: 200, description: 'List of medications' })
  findAll(@CurrentUser() user: any) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.medicationsService.findAll(userId);
  }

  @Get('upcoming')
  @ApiOperation({ summary: 'Get upcoming medication reminders' })
  @ApiResponse({ status: 200, description: 'List of upcoming reminders' })
  getUpcomingReminders(@CurrentUser() user: any) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.medicationsService.getUpcomingReminders(userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a medication by ID' })
  @ApiResponse({ status: 200, description: 'Medication details' })
  @ApiResponse({ status: 404, description: 'Medication not found' })
  findOne(@CurrentUser() user: any, @Param('id', ParseIntPipe) id: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.medicationsService.findOne(userId, BigInt(id));
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a medication' })
  @ApiResponse({ status: 200, description: 'Medication updated successfully' })
  @ApiResponse({ status: 404, description: 'Medication not found' })
  update(
    @CurrentUser() user: any,
    @Param('id', ParseIntPipe) id: string,
    @Body() updateDto: UpdateMedicationDto,
  ) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.medicationsService.update(userId, BigInt(id), updateDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a medication' })
  @ApiResponse({ status: 200, description: 'Medication deleted successfully' })
  @ApiResponse({ status: 404, description: 'Medication not found' })
  remove(@CurrentUser() user: any, @Param('id', ParseIntPipe) id: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.medicationsService.remove(userId, BigInt(id));
  }

  @Get(':id/intakes')
  @ApiOperation({ summary: 'Get intake history for a medication' })
  @ApiResponse({ status: 200, description: 'List of intakes' })
  getIntakeHistory(@CurrentUser() user: any, @Param('id', ParseIntPipe) id: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.medicationsService.getIntakeHistory(userId, BigInt(id));
  }

  @Post(':id/intakes')
  @ApiOperation({ summary: 'Log medication intake' })
  @ApiResponse({ status: 201, description: 'Intake logged successfully' })
  logIntake(
    @CurrentUser() user: any,
    @Param('id', ParseIntPipe) id: string,
    @Body() logDto: LogIntakeDto,
  ) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.medicationsService.logIntake(userId, BigInt(id), logDto);
  }

  @Get(':id/adherence')
  @ApiOperation({ summary: 'Get medication adherence percentage' })
  @ApiResponse({ status: 200, description: 'Adherence percentage' })
  getAdherence(
    @CurrentUser() user: any,
    @Param('id', ParseIntPipe) id: string,
    @Query('days') days?: string,
  ) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.medicationsService.getAdherence(
      userId,
      BigInt(id),
      days ? parseInt(days, 10) : 7,
    );
  }

  @Get(':id/streak')
  @ApiOperation({ summary: 'Get medication adherence streak' })
  @ApiResponse({ status: 200, description: 'Adherence streak' })
  getAdherenceStreak(@CurrentUser() user: any, @Param('id', ParseIntPipe) id: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.medicationsService.getAdherenceStreak(userId, BigInt(id));
  }
}


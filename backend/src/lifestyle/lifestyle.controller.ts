import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  UseGuards,
  ParseIntPipe,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { LifestyleService } from './lifestyle.service';
import { CreateDietLogDto } from './dto/create-diet-log.dto';
import { CreateExerciseLogDto } from './dto/create-exercise-log.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { AccessControlService } from '../common/services/access-control.service';

@ApiTags('Lifestyle')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('lifestyle')
export class LifestyleController {
  constructor(
    private readonly lifestyleService: LifestyleService,
    private readonly accessControlService: AccessControlService,
  ) {}

  private async resolveContext(user: any, elderUserId?: string) {
    return this.accessControlService.resolveActorContext(user, elderUserId);
  }

  @Post('diet')
  @ApiOperation({ summary: 'Add a diet log entry' })
  @ApiResponse({ status: 201, description: 'Diet log created successfully' })
  async createDietLog(@CurrentUser() user: any, @Body() createDto: CreateDietLogDto) {
    const context = await this.resolveContext(user, createDto.elderUserId);
    return this.lifestyleService.createDietLog(context, createDto);
  }

  @Get('diet')
  @ApiOperation({ summary: 'Get all diet logs' })
  @ApiQuery({ name: 'date', required: false, type: String })
  @ApiResponse({ status: 200, description: 'List of diet logs' })
  async findAllDietLogs(
    @CurrentUser() user: any,
    @Query('date') date?: string,
    @Query('elderUserId') elderUserId?: string,
  ) {
    const context = await this.resolveContext(user, elderUserId);
    return this.lifestyleService.findAllDietLogs(context, date);
  }

  @Delete('diet/:id')
  @ApiOperation({ summary: 'Delete a diet log' })
  @ApiResponse({ status: 200, description: 'Diet log deleted successfully' })
  async removeDietLog(
    @CurrentUser() user: any,
    @Param('id', ParseIntPipe) id: string,
    @Query('elderUserId') elderUserId?: string,
  ) {
    const context = await this.resolveContext(user, elderUserId);
    return this.lifestyleService.removeDietLog(context, BigInt(id));
  }

  @Post('exercise')
  @ApiOperation({ summary: 'Add an exercise log entry' })
  @ApiResponse({ status: 201, description: 'Exercise log created successfully' })
  async createExerciseLog(
    @CurrentUser() user: any,
    @Body() createDto: CreateExerciseLogDto,
  ) {
    const context = await this.resolveContext(user, createDto.elderUserId);
    return this.lifestyleService.createExerciseLog(context, createDto);
  }

  @Get('exercise')
  @ApiOperation({ summary: 'Get all exercise logs' })
  @ApiQuery({ name: 'date', required: false, type: String })
  @ApiResponse({ status: 200, description: 'List of exercise logs' })
  async findAllExerciseLogs(
    @CurrentUser() user: any,
    @Query('date') date?: string,
    @Query('elderUserId') elderUserId?: string,
  ) {
    const context = await this.resolveContext(user, elderUserId);
    return this.lifestyleService.findAllExerciseLogs(context, date);
  }

  @Delete('exercise/:id')
  @ApiOperation({ summary: 'Delete an exercise log' })
  @ApiResponse({ status: 200, description: 'Exercise log deleted successfully' })
  async removeExerciseLog(
    @CurrentUser() user: any,
    @Param('id', ParseIntPipe) id: string,
    @Query('elderUserId') elderUserId?: string,
  ) {
    const context = await this.resolveContext(user, elderUserId);
    return this.lifestyleService.removeExerciseLog(context, BigInt(id));
  }

  @Get('summary')
  @ApiOperation({ summary: 'Get daily summary' })
  @ApiQuery({ name: 'date', required: true, type: String })
  @ApiResponse({ status: 200, description: 'Daily summary' })
  async getDailySummary(
    @CurrentUser() user: any,
    @Query('date') date: string,
    @Query('elderUserId') elderUserId?: string,
  ) {
    const context = await this.resolveContext(user, elderUserId);
    return this.lifestyleService.getDailySummary(context, date);
  }

  @Get('summary/weekly')
  @ApiOperation({ summary: 'Get weekly summary' })
  @ApiResponse({ status: 200, description: 'Weekly summary' })
  async getWeeklySummary(
    @CurrentUser() user: any,
    @Query('elderUserId') elderUserId?: string,
  ) {
    const context = await this.resolveContext(user, elderUserId);
    return this.lifestyleService.getWeeklySummary(context);
  }
}


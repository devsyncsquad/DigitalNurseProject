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

@ApiTags('Lifestyle')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('lifestyle')
export class LifestyleController {
  constructor(private readonly lifestyleService: LifestyleService) {}

  @Post('diet')
  @ApiOperation({ summary: 'Add a diet log entry' })
  @ApiResponse({ status: 201, description: 'Diet log created successfully' })
  createDietLog(@CurrentUser() user: any, @Body() createDto: CreateDietLogDto) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.lifestyleService.createDietLog(userId, createDto);
  }

  @Get('diet')
  @ApiOperation({ summary: 'Get all diet logs' })
  @ApiQuery({ name: 'date', required: false, type: String })
  @ApiResponse({ status: 200, description: 'List of diet logs' })
  findAllDietLogs(@CurrentUser() user: any, @Query('date') date?: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.lifestyleService.findAllDietLogs(userId, date);
  }

  @Delete('diet/:id')
  @ApiOperation({ summary: 'Delete a diet log' })
  @ApiResponse({ status: 200, description: 'Diet log deleted successfully' })
  removeDietLog(@CurrentUser() user: any, @Param('id', ParseIntPipe) id: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.lifestyleService.removeDietLog(userId, BigInt(id));
  }

  @Post('exercise')
  @ApiOperation({ summary: 'Add an exercise log entry' })
  @ApiResponse({ status: 201, description: 'Exercise log created successfully' })
  createExerciseLog(@CurrentUser() user: any, @Body() createDto: CreateExerciseLogDto) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.lifestyleService.createExerciseLog(userId, createDto);
  }

  @Get('exercise')
  @ApiOperation({ summary: 'Get all exercise logs' })
  @ApiQuery({ name: 'date', required: false, type: String })
  @ApiResponse({ status: 200, description: 'List of exercise logs' })
  findAllExerciseLogs(@CurrentUser() user: any, @Query('date') date?: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.lifestyleService.findAllExerciseLogs(userId, date);
  }

  @Delete('exercise/:id')
  @ApiOperation({ summary: 'Delete an exercise log' })
  @ApiResponse({ status: 200, description: 'Exercise log deleted successfully' })
  removeExerciseLog(@CurrentUser() user: any, @Param('id', ParseIntPipe) id: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.lifestyleService.removeExerciseLog(userId, BigInt(id));
  }

  @Get('summary')
  @ApiOperation({ summary: 'Get daily summary' })
  @ApiQuery({ name: 'date', required: true, type: String })
  @ApiResponse({ status: 200, description: 'Daily summary' })
  getDailySummary(@CurrentUser() user: any, @Query('date') date: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.lifestyleService.getDailySummary(userId, date);
  }

  @Get('summary/weekly')
  @ApiOperation({ summary: 'Get weekly summary' })
  @ApiResponse({ status: 200, description: 'Weekly summary' })
  getWeeklySummary(@CurrentUser() user: any) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.lifestyleService.getWeeklySummary(userId);
  }
}


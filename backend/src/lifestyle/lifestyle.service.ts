import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateDietLogDto } from './dto/create-diet-log.dto';
import { CreateExerciseLogDto } from './dto/create-exercise-log.dto';
import { ActorContext } from '../common/services/access-control.service';

@Injectable()
export class LifestyleService {
  constructor(private prisma: PrismaService) {}

  // ============================================
  // Diet Log Methods
  // ============================================

  async createDietLog(context: ActorContext, createDto: CreateDietLogDto) {
    const dietLog = await this.prisma.dietLog.create({
      data: {
        userId: context.elderUserId,
        logDate: new Date(createDto.logDate),
        mealType: createDto.mealType,
        foodItems: createDto.description,
        calories: createDto.calories,
        notes: createDto.notes || null,
      },
    });

    return this.mapDietLogToResponse(dietLog);
  }

  async findAllDietLogs(context: ActorContext, date?: string) {
    const where: any = { userId: context.elderUserId };
    if (date) {
      const targetDate = new Date(date);
      where.logDate = targetDate;
    }

    const dietLogs = await this.prisma.dietLog.findMany({
      where,
      orderBy: {
        logDate: 'desc',
      },
    });

    return dietLogs.map((log) => this.mapDietLogToResponse(log));
  }

  async removeDietLog(context: ActorContext, dietId: bigint) {
    const dietLog = await this.prisma.dietLog.findFirst({
      where: {
        dietId,
        userId: context.elderUserId,
      },
    });

    if (!dietLog) {
      throw new NotFoundException('Diet log not found');
    }

    await this.prisma.dietLog.delete({
      where: { dietId },
    });

    return { message: 'Diet log deleted successfully' };
  }

  // ============================================
  // Exercise Log Methods
  // ============================================

  async createExerciseLog(context: ActorContext, createDto: CreateExerciseLogDto) {
    const exerciseLog = await this.prisma.exerciseLog.create({
      data: {
        userId: context.elderUserId,
        logDate: new Date(createDto.logDate),
        exerciseType: createDto.activityType,
        description: createDto.description,
        durationMinutes: createDto.durationMinutes,
        caloriesBurned: createDto.caloriesBurned,
        intensity: createDto.intensity || null,
        notes: createDto.notes || null,
      },
    });

    return this.mapExerciseLogToResponse(exerciseLog);
  }

  async findAllExerciseLogs(context: ActorContext, date?: string) {
    const where: any = { userId: context.elderUserId };
    if (date) {
      const targetDate = new Date(date);
      where.logDate = targetDate;
    }

    const exerciseLogs = await this.prisma.exerciseLog.findMany({
      where,
      orderBy: {
        logDate: 'desc',
      },
    });

    return exerciseLogs.map((log) => this.mapExerciseLogToResponse(log));
  }

  async removeExerciseLog(context: ActorContext, exerciseId: bigint) {
    const exerciseLog = await this.prisma.exerciseLog.findFirst({
      where: {
        exerciseId,
        userId: context.elderUserId,
      },
    });

    if (!exerciseLog) {
      throw new NotFoundException('Exercise log not found');
    }

    await this.prisma.exerciseLog.delete({
      where: { exerciseId },
    });

    return { message: 'Exercise log deleted successfully' };
  }

  // ============================================
  // Summary Methods
  // ============================================

  async getDailySummary(context: ActorContext, date: string) {
    const targetDate = new Date(date);

    const dietLogs = await this.prisma.dietLog.findMany({
      where: {
        userId: context.elderUserId,
        logDate: targetDate,
      },
    });

    const exerciseLogs = await this.prisma.exerciseLog.findMany({
      where: {
        userId: context.elderUserId,
        logDate: targetDate,
      },
    });

    const totalCaloriesIn = dietLogs.reduce((sum, log) => sum + (log.calories || 0), 0);
    const totalCaloriesOut = exerciseLogs.reduce((sum, log) => sum + (log.caloriesBurned || 0), 0);
    const totalExerciseMinutes = exerciseLogs.reduce(
      (sum, log) => sum + (log.durationMinutes || 0),
      0,
    );

    return {
      date: targetDate.toISOString().split('T')[0],
      caloriesIn: totalCaloriesIn,
      caloriesOut: totalCaloriesOut,
      netCalories: totalCaloriesIn - totalCaloriesOut,
      exerciseMinutes: totalExerciseMinutes,
      mealCount: dietLogs.length,
      workoutCount: exerciseLogs.length,
    };
  }

  async getWeeklySummary(context: ActorContext) {
    const now = new Date();
    const weekStart = new Date(now);
    weekStart.setDate(weekStart.getDate() - 7);

    const dietLogs = await this.prisma.dietLog.findMany({
      where: {
        userId: context.elderUserId,
        logDate: {
          gte: weekStart,
        },
      },
    });

    const exerciseLogs = await this.prisma.exerciseLog.findMany({
      where: {
        userId: context.elderUserId,
        logDate: {
          gte: weekStart,
        },
      },
    });

    const totalCaloriesIn = dietLogs.reduce((sum, log) => sum + (log.calories || 0), 0);
    const totalCaloriesOut = exerciseLogs.reduce((sum, log) => sum + (log.caloriesBurned || 0), 0);
    const totalExerciseMinutes = exerciseLogs.reduce(
      (sum, log) => sum + (log.durationMinutes || 0),
      0,
    );

    return {
      weekStart: weekStart.toISOString(),
      weekEnd: now.toISOString(),
      totalCaloriesIn,
      totalCaloriesOut,
      avgCaloriesPerDay: totalCaloriesIn / 7,
      totalExerciseMinutes,
      avgExercisePerDay: totalExerciseMinutes / 7,
    };
  }

  // ============================================
  // Mappers
  // ============================================

  private mapDietLogToResponse(log: any) {
    return {
      id: log.dietId.toString(),
      mealType: log.mealType,
      description: log.foodItems || '',
      calories: log.calories || 0,
      timestamp: log.logDate.toISOString(),
      userId: log.userId.toString(),
    };
  }

  private mapExerciseLogToResponse(log: any) {
    return {
      id: log.exerciseId.toString(),
      activityType: log.exerciseType,
      description: log.description || '',
      durationMinutes: log.durationMinutes || 0,
      caloriesBurned: log.caloriesBurned || 0,
      timestamp: log.logDate.toISOString(),
      userId: log.userId.toString(),
    };
  }
}


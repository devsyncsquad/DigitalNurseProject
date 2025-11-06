import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMedicationDto, MedicineFrequency } from './dto/create-medication.dto';
import { UpdateMedicationDto } from './dto/update-medication.dto';
import { LogIntakeDto, IntakeStatus } from './dto/log-intake.dto';

@Injectable()
export class MedicationsService {
  constructor(private prisma: PrismaService) {}

  /**
   * Convert days array to bitmask (1=Monday, 7=Sunday)
   * Bit 0 = Monday, Bit 6 = Sunday
   */
  private daysToBitmask(days: number[]): number {
    if (!days || days.length === 0) return 127; // All days (1111111)
    let mask = 0;
    for (const day of days) {
      if (day >= 1 && day <= 7) {
        mask |= 1 << (day - 1);
      }
    }
    return mask;
  }

  /**
   * Convert frequency enum to days mask
   */
  private frequencyToDaysMask(frequency: MedicineFrequency, periodicDays?: number[]): number {
    switch (frequency) {
      case MedicineFrequency.DAILY:
      case MedicineFrequency.TWICE_DAILY:
      case MedicineFrequency.THRICE_DAILY:
      case MedicineFrequency.BEFORE_MEAL:
      case MedicineFrequency.AFTER_MEAL:
        return 127; // All days
      case MedicineFrequency.WEEKLY:
        return 127; // All days (can be adjusted)
      case MedicineFrequency.PERIODIC:
        return this.daysToBitmask(periodicDays || []);
      case MedicineFrequency.AS_NEEDED:
        return 127; // All days
      default:
        return 127;
    }
  }

  /**
   * Convert reminder times to JSONB array
   */
  private reminderTimesToJson(times: { time: string }[]): string[] {
    return times.map((t) => t.time);
  }

  /**
   * Create medication with schedule
   */
  async create(userId: bigint, createDto: CreateMedicationDto) {
    try {
      const { reminderTimes, frequency, periodicDays, startDate, endDate, ...medicationData } =
        createDto;

      // Parse dose value from strength and doseAmount
      let doseValue: any = null;
      if (medicationData.doseAmount) {
        try {
          // Convert to string if it's not already (handles number input)
          const doseAmountStr = String(medicationData.doseAmount).trim();
          if (doseAmountStr) {
            const match = doseAmountStr.match(/(\d+(?:\.\d+)?)/);
            if (match) {
              doseValue = parseFloat(match[1]);
            }
          }
        } catch (error) {
          // If parsing fails, continue without doseValue
          console.warn('Failed to parse doseAmount:', error);
        }
      }

      // Handle empty strength field - only set unit code if strength is provided and not empty
      const doseUnitCode =
        medicationData.strength && String(medicationData.strength).trim()
          ? 'mg'
          : null;

      // Create medication with schedule
      const medication = await this.prisma.medication.create({
        data: {
          elderUserId: userId,
          medicationName: medicationData.name,
          doseValue: doseValue,
          doseUnitCode: doseUnitCode,
          formCode: medicationData.medicineForm || null,
          instructions: medicationData.dosage,
          notes: medicationData.notes || null,
          createdByUserId: userId,
          schedules: {
            create: {
              timezone: 'Asia/Karachi',
              startDate: new Date(startDate),
              endDate: endDate ? new Date(endDate) : null,
              daysMask: this.frequencyToDaysMask(frequency, periodicDays),
              timesLocal: this.reminderTimesToJson(reminderTimes) as any,
              isPrn: frequency === MedicineFrequency.AS_NEEDED,
            },
          },
        },
        include: {
          schedules: true,
        },
      });

      return this.mapToResponse(medication);
    } catch (error) {
      console.error('Error creating medication:', error);
      if (error instanceof NotFoundException || error instanceof BadRequestException) {
        throw error;
      }
      throw new BadRequestException(
        `Failed to create medication: ${error instanceof Error ? error.message : 'Unknown error'}`,
      );
    }
  }

  /**
   * Find all medications for a user
   */
  async findAll(userId: bigint) {
    const medications = await this.prisma.medication.findMany({
      where: {
        elderUserId: userId,
      },
      include: {
        schedules: {
          orderBy: {
            createdAt: 'desc',
          },
          take: 1, // Get latest schedule
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return medications.map((med) => this.mapToResponse(med));
  }

  /**
   * Find one medication by ID
   */
  async findOne(userId: bigint, medicationId: bigint) {
    const medication = await this.prisma.medication.findFirst({
      where: {
        medicationId,
        elderUserId: userId,
      },
      include: {
        schedules: {
          orderBy: {
            createdAt: 'desc',
          },
        },
      },
    });

    if (!medication) {
      throw new NotFoundException('Medication not found');
    }

    return this.mapToResponse(medication);
  }

  /**
   * Update medication
   */
  async update(userId: bigint, medicationId: bigint, updateDto: UpdateMedicationDto) {
    const medication = await this.prisma.medication.findFirst({
      where: {
        medicationId,
        elderUserId: userId,
      },
      include: {
        schedules: true,
      },
    });

    if (!medication) {
      throw new NotFoundException('Medication not found');
    }

    const { reminderTimes, frequency, periodicDays, startDate, endDate, ...medicationData } =
      updateDto;

    // Update medication
    const updateData: any = {};
    if (medicationData.name) updateData.medicationName = medicationData.name;
    if (medicationData.dosage) updateData.instructions = medicationData.dosage;
    if (medicationData.notes !== undefined) updateData.notes = medicationData.notes;
    if (medicationData.medicineForm) updateData.formCode = medicationData.medicineForm;

    // Parse dose value
    if (medicationData.doseAmount) {
      try {
        // Convert to string if it's not already (handles number input)
        const doseAmountStr = String(medicationData.doseAmount).trim();
        if (doseAmountStr) {
          const match = doseAmountStr.match(/(\d+(?:\.\d+)?)/);
          if (match) {
            updateData.doseValue = parseFloat(match[1]);
          }
        }
      } catch (error) {
        // If parsing fails, continue without doseValue
        console.warn('Failed to parse doseAmount:', error);
      }
    }

    // Handle strength field update - only set unit code if strength is provided and not empty
    if (medicationData.strength !== undefined) {
      updateData.doseUnitCode =
        medicationData.strength && String(medicationData.strength).trim() ? 'mg' : null;
    }

    const updated = await this.prisma.medication.update({
      where: { medicationId },
      data: updateData,
      include: {
        schedules: true,
      },
    });

    // Update or create schedule if schedule data provided
    if (reminderTimes || frequency || startDate !== undefined) {
      const latestSchedule = medication.schedules[0];
      if (latestSchedule) {
        // Update existing schedule
        await this.prisma.medSchedule.update({
          where: { medScheduleId: latestSchedule.medScheduleId },
          data: {
            startDate: startDate ? new Date(startDate) : latestSchedule.startDate,
            endDate: endDate !== undefined ? (endDate ? new Date(endDate) : null) : latestSchedule.endDate,
            daysMask:
              frequency !== undefined
                ? this.frequencyToDaysMask(frequency, periodicDays)
                : latestSchedule.daysMask,
            timesLocal:
              reminderTimes !== undefined
                ? (this.reminderTimesToJson(reminderTimes) as any)
                : latestSchedule.timesLocal,
          },
        });
      } else {
        // Create new schedule
        await this.prisma.medSchedule.create({
          data: {
            medicationId,
            timezone: 'Asia/Karachi',
            startDate: startDate ? new Date(startDate) : new Date(),
            endDate: endDate ? new Date(endDate) : null,
            daysMask:
              frequency !== undefined
                ? this.frequencyToDaysMask(frequency, periodicDays)
                : 127,
            timesLocal:
              reminderTimes !== undefined
                ? (this.reminderTimesToJson(reminderTimes) as any)
                : ([] as any),
            isPrn: frequency === MedicineFrequency.AS_NEEDED,
          },
        });
      }
    }

    return this.findOne(userId, medicationId);
  }

  /**
   * Delete medication
   */
  async remove(userId: bigint, medicationId: bigint) {
    const medication = await this.prisma.medication.findFirst({
      where: {
        medicationId,
        elderUserId: userId,
      },
    });

    if (!medication) {
      throw new NotFoundException('Medication not found');
    }

    await this.prisma.medication.delete({
      where: { medicationId },
    });

    return { message: 'Medication deleted successfully' };
  }

  /**
   * Get intake history for a medication
   */
  async getIntakeHistory(userId: bigint, medicationId: bigint) {
    const medication = await this.prisma.medication.findFirst({
      where: {
        medicationId,
        elderUserId: userId,
      },
    });

    if (!medication) {
      throw new NotFoundException('Medication not found');
    }

    const intakes = await this.prisma.medIntake.findMany({
      where: {
        schedule: {
          medicationId,
        },
      },
      include: {
        schedule: true,
      },
      orderBy: {
        dueAt: 'desc',
      },
    });

    return intakes.map((intake) => ({
      id: intake.intakeId.toString(),
      medicationId: medicationId.toString(),
      scheduledTime: intake.dueAt.toISOString(),
      takenTime: intake.takenAt?.toISOString() || null,
      status: intake.status,
    }));
  }

  /**
   * Log medication intake
   */
  async logIntake(userId: bigint, medicationId: bigint, logDto: LogIntakeDto) {
    const medication = await this.prisma.medication.findFirst({
      where: {
        medicationId,
        elderUserId: userId,
      },
      include: {
        schedules: {
          orderBy: {
            createdAt: 'desc',
          },
          take: 1,
        },
      },
    });

    if (!medication) {
      throw new NotFoundException('Medication not found');
    }

    if (medication.schedules.length === 0) {
      throw new BadRequestException('Medication has no schedule');
    }

    const schedule = medication.schedules[0];
    const dueAt = new Date(logDto.scheduledTime);

    // Check if intake already exists
    const existing = await this.prisma.medIntake.findFirst({
      where: {
        medScheduleId: schedule.medScheduleId,
        dueAt,
      },
    });

    if (existing) {
      // Update existing intake
      const updated = await this.prisma.medIntake.update({
        where: { intakeId: existing.intakeId },
        data: {
          status: logDto.status,
          takenAt: logDto.status === IntakeStatus.TAKEN ? (logDto.takenTime ? new Date(logDto.takenTime) : new Date()) : null,
          notes: logDto.notes || null,
        },
      });

      return {
        id: updated.intakeId.toString(),
        medicationId: medicationId.toString(),
        scheduledTime: updated.dueAt.toISOString(),
        takenTime: updated.takenAt?.toISOString() || null,
        status: updated.status,
      };
    } else {
      // Create new intake
      const intake = await this.prisma.medIntake.create({
        data: {
          medScheduleId: schedule.medScheduleId,
          dueAt,
          status: logDto.status,
          takenAt: logDto.status === IntakeStatus.TAKEN ? (logDto.takenTime ? new Date(logDto.takenTime) : new Date()) : null,
          notes: logDto.notes || null,
          recordedByUserId: userId,
        },
      });

      return {
        id: intake.intakeId.toString(),
        medicationId: medicationId.toString(),
        scheduledTime: intake.dueAt.toISOString(),
        takenTime: intake.takenAt?.toISOString() || null,
        status: intake.status,
      };
    }
  }

  /**
   * Get adherence percentage
   */
  async getAdherence(userId: bigint, medicationId: bigint, days: number = 7) {
    const medication = await this.prisma.medication.findFirst({
      where: {
        medicationId,
        elderUserId: userId,
      },
    });

    if (!medication) {
      throw new NotFoundException('Medication not found');
    }

    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - days);

    const intakes = await this.prisma.medIntake.findMany({
      where: {
        schedule: {
          medicationId,
        },
        dueAt: {
          gte: cutoffDate,
        },
      },
    });

    if (intakes.length === 0) {
      return { percentage: 100, total: 0, taken: 0 };
    }

    const taken = intakes.filter((i) => i.status === 'taken').length;
    const percentage = (taken / intakes.length) * 100;

    return {
      percentage: Math.round(percentage * 100) / 100,
      total: intakes.length,
      taken,
    };
  }

  /**
   * Get adherence streak
   */
  async getAdherenceStreak(userId: bigint, medicationId: bigint) {
    const medication = await this.prisma.medication.findFirst({
      where: {
        medicationId,
        elderUserId: userId,
      },
    });

    if (!medication) {
      throw new NotFoundException('Medication not found');
    }

    // Get all intakes ordered by date descending
    const intakes = await this.prisma.medIntake.findMany({
      where: {
        schedule: {
          medicationId,
        },
      },
      orderBy: {
        dueAt: 'desc',
      },
    });

    if (intakes.length === 0) {
      return { streak: 0 };
    }

    // Calculate streak
    let streak = 0;
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    for (let i = 0; i < 365; i++) {
      const checkDate = new Date(today);
      checkDate.setDate(checkDate.getDate() - i);

      const dayIntakes = intakes.filter((intake) => {
        const intakeDate = new Date(intake.dueAt);
        return (
          intakeDate.getFullYear() === checkDate.getFullYear() &&
          intakeDate.getMonth() === checkDate.getMonth() &&
          intakeDate.getDate() === checkDate.getDate()
        );
      });

      if (dayIntakes.length === 0) {
        if (i === 0 || streak > 0) {
          if (i > 0) streak++;
        } else {
          break;
        }
        continue;
      }

      const allTaken = dayIntakes.every((intake) => intake.status === 'taken');
      if (allTaken) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    return { streak };
  }

  /**
   * Get upcoming reminders
   */
  async getUpcomingReminders(userId: bigint) {
    const medications = await this.prisma.medication.findMany({
      where: {
        elderUserId: userId,
      },
      include: {
        schedules: {
          orderBy: {
            createdAt: 'desc',
          },
          take: 1,
        },
      },
    });

    const reminders: any[] = [];
    const now = new Date();

    for (const medication of medications) {
      if (medication.schedules.length === 0) continue;

      const schedule = medication.schedules[0];
      const times = schedule.timesLocal as string[];

      if (!Array.isArray(times)) continue;

      for (const timeStr of times) {
        const [hours, minutes] = timeStr.split(':').map(Number);
        const reminderTime = new Date(now);
        reminderTime.setHours(hours, minutes, 0, 0);

        if (reminderTime < now) {
          reminderTime.setDate(reminderTime.getDate() + 1);
        }

        reminders.push({
          medicine: this.mapToResponse(medication),
          reminderTime: reminderTime.toISOString(),
        });
      }
    }

    reminders.sort((a, b) =>
      new Date(a.reminderTime).getTime() - new Date(b.reminderTime).getTime(),
    );

    return reminders.slice(0, 10);
  }

  /**
   * Map database model to API response
   */
  private mapToResponse(medication: any) {
    const schedule = medication.schedules?.[0];
    const timesLocal = (schedule?.timesLocal as string[]) || [];

    return {
      id: medication.medicationId.toString(),
      name: medication.medicationName,
      dosage: medication.instructions || '',
      frequency: this.determineFrequency(schedule),
      startDate: schedule?.startDate?.toISOString() || medication.createdAt.toISOString(),
      endDate: schedule?.endDate?.toISOString() || null,
      reminderTimes: timesLocal.map((time) => ({ time })),
      notes: medication.notes || null,
      userId: medication.elderUserId.toString(),
      medicineForm: medication.formCode || null,
      strength: medication.doseUnitCode || null,
      doseAmount: medication.doseValue
        ? `${medication.doseValue} ${medication.doseUnitCode || ''}`
        : null,
      periodicDays: schedule ? this.bitmaskToDays(schedule.daysMask) : null,
    };
  }

  /**
   * Determine frequency from schedule
   */
  private determineFrequency(schedule: any): MedicineFrequency {
    if (!schedule) return MedicineFrequency.DAILY;
    if (schedule.isPrn) return MedicineFrequency.AS_NEEDED;
    const timesCount = Array.isArray(schedule.timesLocal) ? schedule.timesLocal.length : 0;
    if (timesCount === 1) return MedicineFrequency.DAILY;
    if (timesCount === 2) return MedicineFrequency.TWICE_DAILY;
    if (timesCount === 3) return MedicineFrequency.THRICE_DAILY;
    if (schedule.daysMask !== 127) return MedicineFrequency.PERIODIC;
    return MedicineFrequency.DAILY;
  }

  /**
   * Convert bitmask to days array
   */
  private bitmaskToDays(mask: number): number[] {
    const days: number[] = [];
    for (let i = 0; i < 7; i++) {
      if (mask & (1 << i)) {
        days.push(i + 1);
      }
    }
    return days;
  }
}


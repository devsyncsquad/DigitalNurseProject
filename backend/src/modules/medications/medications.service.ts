import { prisma } from '../../config/database';
import {
  CreateMedicationInput,
  UpdateMedicationInput,
  CreateMedScheduleInput,
  UpdateMedScheduleInput,
  CreateMedIntakeInput,
  UpdateMedIntakeInput,
} from './medications.schemas';

export class MedicationService {
  // ==================== Medications ====================

  async getAllMedications(elderUserId?: string) {
    const where = elderUserId ? { elderUserId: BigInt(elderUserId) } : {};

    return await prisma.medication.findMany({
      where,
      include: {
        elder: {
          select: {
            userId: true,
            full_name: true,
            email: true,
          },
        },
        createdBy: {
          select: {
            userId: true,
            full_name: true,
          },
        },
        medSchedules: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async getMedicationById(medicationId: string) {
    return await prisma.medication.findUnique({
      where: { medicationId: BigInt(medicationId) },
      include: {
        elder: {
          select: {
            userId: true,
            full_name: true,
            email: true,
          },
        },
        createdBy: {
          select: {
            userId: true,
            full_name: true,
          },
        },
        medSchedules: true,
        medIntakes: {
          take: 10,
          orderBy: {
            scheduledTime: 'desc',
          },
        },
      },
    });
  }

  async createMedication(data: CreateMedicationInput, createdByUserId: string) {
    return await prisma.medication.create({
      data: {
        elderUserId: BigInt(data.elderUserId),
        medicationName: data.medicationName,
        doseValue: data.doseValue,
        doseUnitCode: data.doseUnitCode,
        formCode: data.formCode,
        instructions: data.instructions,
        notes: data.notes,
        createdByUserId: BigInt(createdByUserId),
      },
      include: {
        elder: {
          select: {
            userId: true,
            full_name: true,
          },
        },
        createdBy: {
          select: {
            userId: true,
            full_name: true,
          },
        },
      },
    });
  }

  async updateMedication(medicationId: string, data: UpdateMedicationInput) {
    return await prisma.medication.update({
      where: { medicationId: BigInt(medicationId) },
      data: {
        medicationName: data.medicationName,
        doseValue: data.doseValue,
        doseUnitCode: data.doseUnitCode,
        formCode: data.formCode,
        instructions: data.instructions,
        notes: data.notes,
      },
      include: {
        elder: {
          select: {
            userId: true,
            full_name: true,
          },
        },
      },
    });
  }

  async deleteMedication(medicationId: string) {
    return await prisma.medication.delete({
      where: { medicationId: BigInt(medicationId) },
    });
  }

  // ==================== Med Schedules ====================

  async getMedicationSchedules(medicationId: string) {
    return await prisma.medSchedule.findMany({
      where: { medicationId: BigInt(medicationId) },
      include: {
        medication: {
          select: {
            medicationId: true,
            medicationName: true,
            doseValue: true,
            doseUnitCode: true,
          },
        },
      },
      orderBy: {
        startDate: 'desc',
      },
    });
  }

  async createMedSchedule(data: CreateMedScheduleInput) {
    return await prisma.medSchedule.create({
      data: {
        medicationId: BigInt(data.medicationId),
        timezone: data.timezone,
        startDate: new Date(data.startDate),
        endDate: data.endDate ? new Date(data.endDate) : null,
        daysMask: data.daysMask,
        timesLocal: data.timesLocal,
        isPrn: data.isPrn,
        snoozeMinutesDefault: data.snoozeMinutesDefault,
      },
      include: {
        medication: true,
      },
    });
  }

  async updateMedSchedule(medScheduleId: string, data: UpdateMedScheduleInput) {
    return await prisma.medSchedule.update({
      where: { medScheduleId: BigInt(medScheduleId) },
      data: {
        timezone: data.timezone,
        startDate: data.startDate ? new Date(data.startDate) : undefined,
        endDate: data.endDate ? new Date(data.endDate) : data.endDate === null ? null : undefined,
        daysMask: data.daysMask,
        timesLocal: data.timesLocal,
        isPrn: data.isPrn,
        snoozeMinutesDefault: data.snoozeMinutesDefault,
      },
    });
  }

  async deleteMedSchedule(medScheduleId: string) {
    return await prisma.medSchedule.delete({
      where: { medScheduleId: BigInt(medScheduleId) },
    });
  }

  // ==================== Med Intakes ====================

  async getMedIntakes(elderUserId?: string, status?: string) {
    const where: any = {};

    if (elderUserId) {
      where.elderUserId = BigInt(elderUserId);
    }

    if (status) {
      where.status = status;
    }

    return await prisma.medIntake.findMany({
      where,
      include: {
        medication: {
          select: {
            medicationId: true,
            medicationName: true,
            doseValue: true,
            doseUnitCode: true,
          },
        },
        elder: {
          select: {
            userId: true,
            full_name: true,
          },
        },
        recordedBy: {
          select: {
            userId: true,
            full_name: true,
          },
        },
      },
      orderBy: {
        scheduledTime: 'desc',
      },
      take: 100,
    });
  }

  async createMedIntake(data: CreateMedIntakeInput, recordedByUserId?: string) {
    return await prisma.medIntake.create({
      data: {
        medicationId: BigInt(data.medicationId),
        elderUserId: BigInt(data.elderUserId),
        scheduledTime: data.scheduledTime ? new Date(data.scheduledTime) : null,
        actualTime: data.actualTime ? new Date(data.actualTime) : null,
        status: data.status,
        doseValue: data.doseValue,
        doseUnitCode: data.doseUnitCode,
        notes: data.notes,
        recordedByUserId: recordedByUserId ? BigInt(recordedByUserId) : null,
      },
      include: {
        medication: true,
        elder: true,
      },
    });
  }

  async updateMedIntake(
    medIntakeId: string,
    data: UpdateMedIntakeInput,
    recordedByUserId?: string
  ) {
    return await prisma.medIntake.update({
      where: { medIntakeId: BigInt(medIntakeId) },
      data: {
        actualTime: data.actualTime ? new Date(data.actualTime) : undefined,
        status: data.status,
        doseValue: data.doseValue,
        doseUnitCode: data.doseUnitCode,
        notes: data.notes,
        recordedByUserId: recordedByUserId ? BigInt(recordedByUserId) : undefined,
      },
      include: {
        medication: true,
        elder: true,
      },
    });
  }

  async deleteMedIntake(medIntakeId: string) {
    return await prisma.medIntake.delete({
      where: { medIntakeId: BigInt(medIntakeId) },
    });
  }

  // ==================== Analytics ====================

  async getMedAdherence(elderUserId: string, days: number = 7) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const intakes = await prisma.medIntake.findMany({
      where: {
        elderUserId: BigInt(elderUserId),
        scheduledTime: {
          gte: startDate,
        },
      },
      select: {
        status: true,
      },
    });

    const total = intakes.length;
    const taken = intakes.filter((i) => i.status === 'taken').length;

    return {
      total,
      taken,
      missed: intakes.filter((i) => i.status === 'missed').length,
      skipped: intakes.filter((i) => i.status === 'skipped').length,
      adherenceRate: total > 0 ? ((taken / total) * 100).toFixed(2) : 0,
    };
  }
}

export const medicationService = new MedicationService();

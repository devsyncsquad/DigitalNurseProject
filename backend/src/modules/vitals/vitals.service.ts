import { prisma } from '../../config/database';
import { CreateVitalMeasurementInput, UpdateVitalMeasurementInput } from './vitals.schemas';

export class VitalService {
  async getAllVitals(
    elderUserId?: string,
    kindCode?: string,
    startDate?: string,
    endDate?: string,
    limit: number = 100
  ) {
    const where: any = {};

    if (elderUserId) {
      where.elderUserId = BigInt(elderUserId);
    }

    if (kindCode) {
      where.kindCode = kindCode;
    }

    if (startDate || endDate) {
      where.recordedAt = {};
      if (startDate) {
        where.recordedAt.gte = new Date(startDate);
      }
      if (endDate) {
        where.recordedAt.lte = new Date(endDate);
      }
    }

    return await prisma.vitalMeasurement.findMany({
      where,
      include: {
        elder: {
          select: {
            userId: true,
            full_name: true,
            email: true,
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
        recordedAt: 'desc',
      },
      take: limit,
    });
  }

  async getVitalById(vitalMeasurementId: string) {
    return await prisma.vitalMeasurement.findUnique({
      where: { vitalMeasurementId: BigInt(vitalMeasurementId) },
      include: {
        elder: {
          select: {
            userId: true,
            full_name: true,
            email: true,
          },
        },
        recordedBy: {
          select: {
            userId: true,
            full_name: true,
          },
        },
      },
    });
  }

  async createVital(data: CreateVitalMeasurementInput, recordedByUserId?: string) {
    return await prisma.vitalMeasurement.create({
      data: {
        elderUserId: BigInt(data.elderUserId),
        kindCode: data.kindCode,
        unitCode: data.unitCode,
        value1: data.value1,
        value2: data.value2,
        valueText: data.valueText,
        recordedAt: new Date(data.recordedAt),
        source: data.source,
        deviceInfo: data.deviceInfo,
        notes: data.notes,
        recordedByUserId: recordedByUserId ? BigInt(recordedByUserId) : null,
      },
      include: {
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
    });
  }

  async updateVital(
    vitalMeasurementId: string,
    data: UpdateVitalMeasurementInput,
    recordedByUserId?: string
  ) {
    return await prisma.vitalMeasurement.update({
      where: { vitalMeasurementId: BigInt(vitalMeasurementId) },
      data: {
        kindCode: data.kindCode,
        unitCode: data.unitCode,
        value1: data.value1,
        value2: data.value2,
        valueText: data.valueText,
        recordedAt: data.recordedAt ? new Date(data.recordedAt) : undefined,
        source: data.source,
        deviceInfo: data.deviceInfo,
        notes: data.notes,
        recordedByUserId: recordedByUserId ? BigInt(recordedByUserId) : undefined,
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

  async deleteVital(vitalMeasurementId: string) {
    return await prisma.vitalMeasurement.delete({
      where: { vitalMeasurementId: BigInt(vitalMeasurementId) },
    });
  }

  // ==================== Analytics ====================

  async getLatestVitals(elderUserId: string) {
    const vitalKinds = await prisma.vitalMeasurement.findMany({
      where: { elderUserId: BigInt(elderUserId) },
      distinct: ['kindCode'],
      select: { kindCode: true },
    });

    const latestVitals = await Promise.all(
      vitalKinds.map(async ({ kindCode }) => {
        return await prisma.vitalMeasurement.findFirst({
          where: {
            elderUserId: BigInt(elderUserId),
            kindCode,
          },
          orderBy: {
            recordedAt: 'desc',
          },
          include: {
            recordedBy: {
              select: {
                userId: true,
                full_name: true,
              },
            },
          },
        });
      })
    );

    return latestVitals.filter((v) => v !== null);
  }

  async getVitalTrend(elderUserId: string, kindCode: string, days: number = 7) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    return await prisma.vitalMeasurement.findMany({
      where: {
        elderUserId: BigInt(elderUserId),
        kindCode,
        recordedAt: {
          gte: startDate,
        },
      },
      orderBy: {
        recordedAt: 'asc',
      },
      select: {
        vitalMeasurementId: true,
        value1: true,
        value2: true,
        valueText: true,
        unitCode: true,
        recordedAt: true,
        notes: true,
      },
    });
  }

  async getVitalSummary(elderUserId: string, days: number = 7) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const vitals = await prisma.vitalMeasurement.findMany({
      where: {
        elderUserId: BigInt(elderUserId),
        recordedAt: {
          gte: startDate,
        },
      },
      select: {
        kindCode: true,
        value1: true,
        value2: true,
        recordedAt: true,
      },
    });

    // Group by kindCode
    const summary: any = {};

    vitals.forEach((vital) => {
      if (!summary[vital.kindCode]) {
        summary[vital.kindCode] = {
          count: 0,
          values: [],
        };
      }
      summary[vital.kindCode].count++;
      if (vital.value1 !== null) {
        summary[vital.kindCode].values.push(Number(vital.value1));
      }
    });

    // Calculate averages
    Object.keys(summary).forEach((kindCode) => {
      const values = summary[kindCode].values;
      if (values.length > 0) {
        const sum = values.reduce((a: number, b: number) => a + b, 0);
        summary[kindCode].average = (sum / values.length).toFixed(2);
        summary[kindCode].min = Math.min(...values);
        summary[kindCode].max = Math.max(...values);
      }
      delete summary[kindCode].values; // Remove raw values from response
    });

    return summary;
  }
}

export const vitalService = new VitalService();

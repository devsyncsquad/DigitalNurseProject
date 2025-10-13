import { prisma } from '../../config/database';
import {
  CreateElderAssignmentInput,
  UpdateElderAssignmentInput,
} from './elder-assignments.schemas';

export class ElderAssignmentService {
  async getAllAssignments(elderUserId?: string, caregiverUserId?: string) {
    const where: any = {};

    if (elderUserId) {
      where.elderUserId = BigInt(elderUserId);
    }

    if (caregiverUserId) {
      where.caregiverUserId = BigInt(caregiverUserId);
    }

    return await prisma.elderAssignment.findMany({
      where,
      include: {
        elder: {
          select: {
            userId: true,
            full_name: true,
            email: true,
            phone: true,
            avatarUrl: true,
            dob: true,
            gender: true,
            address: true,
          },
        },
        caregiver: {
          select: {
            userId: true,
            full_name: true,
            email: true,
            phone: true,
            avatarUrl: true,
          },
        },
      },
      orderBy: [{ isPrimary: 'desc' }, { createdAt: 'desc' }],
    });
  }

  async getAssignmentById(elderAssignmentId: string) {
    return await prisma.elderAssignment.findUnique({
      where: { elderAssignmentId: BigInt(elderAssignmentId) },
      include: {
        elder: {
          select: {
            userId: true,
            full_name: true,
            email: true,
            phone: true,
            avatarUrl: true,
            dob: true,
            gender: true,
            address: true,
          },
        },
        caregiver: {
          select: {
            userId: true,
            full_name: true,
            email: true,
            phone: true,
            avatarUrl: true,
          },
        },
      },
    });
  }

  async createAssignment(data: CreateElderAssignmentInput) {
    // Check if assignment already exists
    const existing = await prisma.elderAssignment.findFirst({
      where: {
        elderUserId: BigInt(data.elderUserId),
        caregiverUserId: BigInt(data.caregiverUserId),
      },
    });

    if (existing) {
      throw new Error('Assignment already exists for this elder and caregiver');
    }

    return await prisma.elderAssignment.create({
      data: {
        elderUserId: BigInt(data.elderUserId),
        caregiverUserId: BigInt(data.caregiverUserId),
        relationshipDomain: data.relationshipDomain,
        relationshipCode: data.relationshipCode,
        isPrimary: data.isPrimary,
        notifyPrefs: data.notifyPrefs,
      },
      include: {
        elder: {
          select: {
            userId: true,
            full_name: true,
            email: true,
          },
        },
        caregiver: {
          select: {
            userId: true,
            full_name: true,
            email: true,
          },
        },
      },
    });
  }

  async updateAssignment(elderAssignmentId: string, data: UpdateElderAssignmentInput) {
    return await prisma.elderAssignment.update({
      where: { elderAssignmentId: BigInt(elderAssignmentId) },
      data: {
        relationshipDomain: data.relationshipDomain,
        relationshipCode: data.relationshipCode,
        isPrimary: data.isPrimary,
        notifyPrefs: data.notifyPrefs,
      },
      include: {
        elder: {
          select: {
            userId: true,
            full_name: true,
          },
        },
        caregiver: {
          select: {
            userId: true,
            full_name: true,
          },
        },
      },
    });
  }

  async deleteAssignment(elderAssignmentId: string) {
    return await prisma.elderAssignment.delete({
      where: { elderAssignmentId: BigInt(elderAssignmentId) },
    });
  }

  async getEldersByCaregiver(caregiverUserId: string) {
    return await prisma.elderAssignment.findMany({
      where: { caregiverUserId: BigInt(caregiverUserId) },
      include: {
        elder: {
          select: {
            userId: true,
            full_name: true,
            email: true,
            phone: true,
            avatarUrl: true,
            dob: true,
            gender: true,
            address: true,
            status: true,
          },
        },
      },
      orderBy: [{ isPrimary: 'desc' }, { createdAt: 'desc' }],
    });
  }

  async getCaregiversByElder(elderUserId: string) {
    return await prisma.elderAssignment.findMany({
      where: { elderUserId: BigInt(elderUserId) },
      include: {
        caregiver: {
          select: {
            userId: true,
            full_name: true,
            email: true,
            phone: true,
            avatarUrl: true,
            status: true,
          },
        },
      },
      orderBy: [{ isPrimary: 'desc' }, { createdAt: 'desc' }],
    });
  }

  async setPrimaryCaregiver(elderUserId: string, caregiverUserId: string) {
    // First, set all caregivers for this elder to non-primary
    await prisma.elderAssignment.updateMany({
      where: { elderUserId: BigInt(elderUserId) },
      data: { isPrimary: false },
    });

    // Then set the specified caregiver as primary
    return await prisma.elderAssignment.updateMany({
      where: {
        elderUserId: BigInt(elderUserId),
        caregiverUserId: BigInt(caregiverUserId),
      },
      data: { isPrimary: true },
    });
  }
}

export const elderAssignmentService = new ElderAssignmentService();

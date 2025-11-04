import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateInvitationDto } from './dto/create-invitation.dto';

@Injectable()
export class CaregiversService {
  constructor(private prisma: PrismaService) {}

  /**
   * Generate unique invitation code
   */
  private generateInviteCode(): string {
    return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
  }

  /**
   * Get all caregivers (elder assignments) for a user
   */
  async findAll(userId: bigint) {
    const assignments = await this.prisma.elderAssignment.findMany({
      where: {
        elderUserId: userId,
      },
      include: {
        caregiverUser: {
          select: {
            userId: true,
            full_name: true,
            phone: true,
            email: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return assignments.map((assignment) => ({
      id: assignment.elderAssignmentId.toString(),
      name: assignment.caregiverUser.full_name,
      phone: assignment.caregiverUser.phone || '',
      status: 'accepted' as const,
      relationship: assignment.relationshipCode,
      linkedPatientId: assignment.elderUserId.toString(),
      invitedAt: assignment.createdAt.toISOString(),
      acceptedAt: assignment.createdAt.toISOString(),
    }));
  }

  /**
   * Send caregiver invitation
   */
  async sendInvitation(userId: bigint, createDto: CreateInvitationDto) {
    const elderUserId = createDto.elderUserId ? BigInt(createDto.elderUserId) : userId;

    // Check if elder user exists
    const elderUser = await this.prisma.user.findUnique({
      where: { userId: elderUserId },
    });

    if (!elderUser) {
      throw new NotFoundException('Elder user not found');
    }

    // Check if invitation already exists for this phone
    const existingInvitation = await this.prisma.userInvitation.findFirst({
      where: {
        elderUserId,
        invitePhone: createDto.phone,
        status: 'pending',
        expiresAt: {
          gt: new Date(),
        },
      },
    });

    if (existingInvitation) {
      throw new BadRequestException('Invitation already sent to this phone number');
    }

    // Create invitation
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7); // 7 days expiry

    const invitation = await this.prisma.userInvitation.create({
      data: {
        inviterUserId: userId,
        elderUserId,
        targetRoleCode: 'caregiver',
        relationshipCode: createDto.relationship,
        invitePhone: createDto.phone,
        inviteCode: this.generateInviteCode(),
        status: 'pending',
        expiresAt,
      },
    });

    return {
      id: invitation.invitationId.toString(),
      phone: invitation.invitePhone,
      inviteCode: invitation.inviteCode,
      status: invitation.status,
      expiresAt: invitation.expiresAt.toISOString(),
      relationship: invitation.relationshipCode,
    };
  }

  /**
   * Get all pending invitations
   */
  async getInvitations(userId: bigint) {
    const invitations = await this.prisma.userInvitation.findMany({
      where: {
        inviterUserId: userId,
        status: 'pending',
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return invitations.map((invitation) => ({
      id: invitation.invitationId.toString(),
      phone: invitation.invitePhone,
      inviteCode: invitation.inviteCode,
      status: invitation.status,
      expiresAt: invitation.expiresAt.toISOString(),
      relationship: invitation.relationshipCode,
      elderUserId: invitation.elderUserId.toString(),
    }));
  }

  /**
   * Get invitation by code
   */
  async getInvitationByCode(inviteCode: string) {
    const invitation = await this.prisma.userInvitation.findUnique({
      where: {
        inviteCode,
      },
      include: {
        elderUser: {
          select: {
            userId: true,
            full_name: true,
            phone: true,
          },
        },
      },
    });

    if (!invitation) {
      throw new NotFoundException('Invitation not found');
    }

    if (invitation.status !== 'pending') {
      throw new BadRequestException('Invitation already processed');
    }

    if (invitation.expiresAt < new Date()) {
      throw new BadRequestException('Invitation has expired');
    }

    return {
      id: invitation.invitationId.toString(),
      phone: invitation.invitePhone,
      inviteCode: invitation.inviteCode,
      status: invitation.status,
      expiresAt: invitation.expiresAt.toISOString(),
      relationship: invitation.relationshipCode,
      elderUser: {
        id: invitation.elderUser.userId.toString(),
        name: invitation.elderUser.full_name,
        phone: invitation.elderUser.phone,
      },
    };
  }

  /**
   * Accept invitation
   */
  async acceptInvitation(userId: bigint, invitationId: bigint) {
    const invitation = await this.prisma.userInvitation.findUnique({
      where: {
        invitationId,
      },
    });

    if (!invitation) {
      throw new NotFoundException('Invitation not found');
    }

    if (invitation.status !== 'pending') {
      throw new BadRequestException('Invitation already processed');
    }

    if (invitation.expiresAt < new Date()) {
      throw new BadRequestException('Invitation has expired');
    }

    // Update invitation
    await this.prisma.userInvitation.update({
      where: { invitationId },
      data: {
        status: 'accepted',
        acceptedUserId: userId,
        acceptedAt: new Date(),
      },
    });

    // Create elder assignment
    const assignment = await this.prisma.elderAssignment.create({
      data: {
        elderUserId: invitation.elderUserId,
        caregiverUserId: userId,
        relationshipCode: invitation.relationshipCode,
        isPrimary: false,
      },
      include: {
        caregiverUser: {
          select: {
            userId: true,
            full_name: true,
            phone: true,
          },
        },
      },
    });

    return {
      id: assignment.elderAssignmentId.toString(),
      name: assignment.caregiverUser.full_name,
      phone: assignment.caregiverUser.phone || '',
      status: 'accepted' as const,
      relationship: assignment.relationshipCode,
      linkedPatientId: assignment.elderUserId.toString(),
      invitedAt: invitation.createdAt.toISOString(),
      acceptedAt: invitation.acceptedAt?.toISOString() || new Date().toISOString(),
    };
  }

  /**
   * Decline invitation
   */
  async declineInvitation(userId: bigint, invitationId: bigint) {
    const invitation = await this.prisma.userInvitation.findUnique({
      where: {
        invitationId,
      },
    });

    if (!invitation) {
      throw new NotFoundException('Invitation not found');
    }

    if (invitation.status !== 'pending') {
      throw new BadRequestException('Invitation already processed');
    }

    await this.prisma.userInvitation.update({
      where: { invitationId },
      data: {
        status: 'declined',
      },
    });

    return { message: 'Invitation declined successfully' };
  }

  /**
   * Remove caregiver assignment
   */
  async remove(userId: bigint, assignmentId: bigint) {
    const assignment = await this.prisma.elderAssignment.findFirst({
      where: {
        elderAssignmentId: assignmentId,
        elderUserId: userId,
      },
    });

    if (!assignment) {
      throw new NotFoundException('Caregiver assignment not found');
    }

    await this.prisma.elderAssignment.delete({
      where: { elderAssignmentId: assignmentId },
    });

    return { message: 'Caregiver removed successfully' };
  }
}


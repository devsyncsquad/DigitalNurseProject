import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  UseGuards,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { CaregiversService } from './caregivers.service';
import { CreateInvitationDto } from './dto/create-invitation.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Caregivers')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('caregivers')
export class CaregiversController {
  constructor(private readonly caregiversService: CaregiversService) {}

  @Get()
  @ApiOperation({ summary: 'Get all caregivers for the current user' })
  @ApiResponse({ status: 200, description: 'List of caregivers' })
  findAll(@CurrentUser() user: any) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.caregiversService.findAll(userId);
  }

  @Post('invitations')
  @ApiOperation({ summary: 'Send caregiver invitation' })
  @ApiResponse({ status: 201, description: 'Invitation sent successfully' })
  sendInvitation(@CurrentUser() user: any, @Body() createDto: CreateInvitationDto) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.caregiversService.sendInvitation(userId, createDto);
  }

  @Get('invitations')
  @ApiOperation({ summary: 'Get all pending invitations' })
  @ApiResponse({ status: 200, description: 'List of invitations' })
  getInvitations(@CurrentUser() user: any) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.caregiversService.getInvitations(userId);
  }

  @Get('invitations/:code')
  @ApiOperation({ summary: 'Get invitation by code' })
  @ApiResponse({ status: 200, description: 'Invitation details' })
  @ApiResponse({ status: 404, description: 'Invitation not found' })
  getInvitationByCode(@Param('code') code: string) {
    return this.caregiversService.getInvitationByCode(code);
  }

  @Post('invitations/:id/accept')
  @ApiOperation({ summary: 'Accept caregiver invitation' })
  @ApiResponse({ status: 200, description: 'Invitation accepted successfully' })
  @ApiResponse({ status: 404, description: 'Invitation not found' })
  acceptInvitation(@CurrentUser() user: any, @Param('id', ParseIntPipe) id: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.caregiversService.acceptInvitation(userId, BigInt(id));
  }

  @Post('invitations/:id/decline')
  @ApiOperation({ summary: 'Decline caregiver invitation' })
  @ApiResponse({ status: 200, description: 'Invitation declined successfully' })
  @ApiResponse({ status: 404, description: 'Invitation not found' })
  declineInvitation(@CurrentUser() user: any, @Param('id', ParseIntPipe) id: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.caregiversService.declineInvitation(userId, BigInt(id));
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Remove caregiver assignment' })
  @ApiResponse({ status: 200, description: 'Caregiver removed successfully' })
  @ApiResponse({ status: 404, description: 'Caregiver assignment not found' })
  remove(@CurrentUser() user: any, @Param('id', ParseIntPipe) id: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.caregiversService.remove(userId, BigInt(id));
  }
}


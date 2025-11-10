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
  UseInterceptors,
  UploadedFile,
  Res,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse, ApiConsumes, ApiQuery } from '@nestjs/swagger';
import { DocumentsService } from './documents.service';
import { CreateDocumentDto, DocumentType } from './dto/create-document.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Response } from 'express';
import * as fs from 'fs';
import { AccessControlService } from '../common/services/access-control.service';

@ApiTags('Documents')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('documents')
export class DocumentsController {
  constructor(
    private readonly documentsService: DocumentsService,
    private readonly accessControlService: AccessControlService,
  ) {}

  private async resolveContext(user: any, elderUserId?: string) {
    return this.accessControlService.resolveActorContext(user, elderUserId);
  }

  @Post()
  @ApiOperation({ summary: 'Upload a document' })
  @ApiConsumes('multipart/form-data')
  @ApiResponse({ status: 201, description: 'Document uploaded successfully' })
  @UseInterceptors(FileInterceptor('file'))
  async create(
    @CurrentUser() user: any,
    @Body() createDto: CreateDocumentDto,
    @UploadedFile() file: any,
  ) {
    if (!file) {
      throw new Error('File is required');
    }
    const context = await this.resolveContext(user, createDto.elderUserId);
    return this.documentsService.create(context, createDto, file);
  }

  @Get()
  @ApiOperation({ summary: 'Get all documents for the current user' })
  @ApiQuery({ name: 'type', enum: DocumentType, required: false })
  @ApiQuery({ name: 'elderUserId', required: false, type: String })
  @ApiResponse({ status: 200, description: 'List of documents' })
  async findAll(
    @CurrentUser() user: any,
    @Query('type') type?: DocumentType,
    @Query('elderUserId') elderUserId?: string,
  ) {
    const context = await this.resolveContext(user, elderUserId);
    return this.documentsService.findAll(context, type);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a document by ID' })
  @ApiResponse({ status: 200, description: 'Document details' })
  @ApiResponse({ status: 404, description: 'Document not found' })
  async findOne(
    @CurrentUser() user: any,
    @Param('id', ParseIntPipe) id: string,
    @Query('elderUserId') elderUserId?: string,
  ) {
    const context = await this.resolveContext(user, elderUserId);
    return this.documentsService.findOne(context, BigInt(id));
  }

  @Get(':id/file')
  @ApiOperation({ summary: 'Download document file' })
  @ApiResponse({ status: 200, description: 'File download' })
  @ApiResponse({ status: 404, description: 'Document or file not found' })
  async getFile(
    @CurrentUser() user: any,
    @Param('id', ParseIntPipe) id: string,
    @Query('elderUserId') elderUserId: string | undefined,
    @Res() res: any,
  ) {
    const context = await this.resolveContext(user, elderUserId);
    const fileInfo = await this.documentsService.getFile(context, BigInt(id));

    if (!fs.existsSync(fileInfo.filePath)) {
      return res.status(404).json({ message: 'File not found' });
    }

    res.setHeader('Content-Type', fileInfo.fileType || 'application/octet-stream');
    res.setHeader('Content-Disposition', `attachment; filename="${fileInfo.fileName}"`);
    return res.sendFile(fileInfo.filePath);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update document metadata' })
  @ApiResponse({ status: 200, description: 'Document updated successfully' })
  @ApiResponse({ status: 404, description: 'Document not found' })
  async update(
    @CurrentUser() user: any,
    @Param('id', ParseIntPipe) id: string,
    @Body() updateDto: Partial<CreateDocumentDto>,
  ) {
    const context = await this.resolveContext(user, (updateDto as any)?.elderUserId);
    return this.documentsService.update(context, BigInt(id), updateDto);
  }

  @Patch(':id/visibility')
  @ApiOperation({ summary: 'Update document visibility' })
  @ApiResponse({ status: 200, description: 'Visibility updated successfully' })
  @ApiResponse({ status: 404, description: 'Document not found' })
  async updateVisibility(
    @CurrentUser() user: any,
    @Param('id', ParseIntPipe) id: string,
    @Body('visibility') visibility: string,
    @Query('elderUserId') elderUserId?: string,
  ) {
    const context = await this.resolveContext(user, elderUserId);
    return this.documentsService.updateVisibility(context, BigInt(id), visibility as any);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a document' })
  @ApiResponse({ status: 200, description: 'Document deleted successfully' })
  @ApiResponse({ status: 404, description: 'Document not found' })
  async remove(
    @CurrentUser() user: any,
    @Param('id', ParseIntPipe) id: string,
    @Query('elderUserId') elderUserId?: string,
  ) {
    const context = await this.resolveContext(user, elderUserId);
    return this.documentsService.remove(context, BigInt(id));
  }
}


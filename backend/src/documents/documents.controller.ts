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

@ApiTags('Documents')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('documents')
export class DocumentsController {
  constructor(private readonly documentsService: DocumentsService) {}

  @Post()
  @ApiOperation({ summary: 'Upload a document' })
  @ApiConsumes('multipart/form-data')
  @ApiResponse({ status: 201, description: 'Document uploaded successfully' })
  @UseInterceptors(FileInterceptor('file'))
  create(
    @CurrentUser() user: any,
    @Body() createDto: CreateDocumentDto,
    @UploadedFile() file: any,
  ) {
    if (!file) {
      throw new Error('File is required');
    }
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.documentsService.create(userId, createDto, file);
  }

  @Get()
  @ApiOperation({ summary: 'Get all documents for the current user' })
  @ApiQuery({ name: 'type', enum: DocumentType, required: false })
  @ApiResponse({ status: 200, description: 'List of documents' })
  findAll(@CurrentUser() user: any, @Query('type') type?: DocumentType) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.documentsService.findAll(userId, type);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a document by ID' })
  @ApiResponse({ status: 200, description: 'Document details' })
  @ApiResponse({ status: 404, description: 'Document not found' })
  findOne(@CurrentUser() user: any, @Param('id', ParseIntPipe) id: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.documentsService.findOne(userId, BigInt(id));
  }

  @Get(':id/file')
  @ApiOperation({ summary: 'Download document file' })
  @ApiResponse({ status: 200, description: 'File download' })
  @ApiResponse({ status: 404, description: 'Document or file not found' })
  async getFile(
    @CurrentUser() user: any,
    @Param('id', ParseIntPipe) id: string,
    @Res() res: any,
  ) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    const fileInfo = await this.documentsService.getFile(userId, BigInt(id));

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
  update(
    @CurrentUser() user: any,
    @Param('id', ParseIntPipe) id: string,
    @Body() updateDto: Partial<CreateDocumentDto>,
  ) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.documentsService.update(userId, BigInt(id), updateDto);
  }

  @Patch(':id/visibility')
  @ApiOperation({ summary: 'Update document visibility' })
  @ApiResponse({ status: 200, description: 'Visibility updated successfully' })
  @ApiResponse({ status: 404, description: 'Document not found' })
  updateVisibility(
    @CurrentUser() user: any,
    @Param('id', ParseIntPipe) id: string,
    @Body('visibility') visibility: string,
  ) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.documentsService.updateVisibility(userId, BigInt(id), visibility as any);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a document' })
  @ApiResponse({ status: 200, description: 'Document deleted successfully' })
  @ApiResponse({ status: 404, description: 'Document not found' })
  remove(@CurrentUser() user: any, @Param('id', ParseIntPipe) id: string) {
    const userId = typeof user.userId === 'bigint' ? user.userId : BigInt(user.userId);
    return this.documentsService.remove(userId, BigInt(id));
  }
}


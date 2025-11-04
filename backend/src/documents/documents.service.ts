import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateDocumentDto, DocumentType, DocumentVisibility } from './dto/create-document.dto';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class DocumentsService {
  private readonly uploadDir = path.join(process.cwd(), 'uploads', 'documents');

  constructor(private prisma: PrismaService) {
    // Ensure upload directory exists
    if (!fs.existsSync(this.uploadDir)) {
      fs.mkdirSync(this.uploadDir, { recursive: true });
    }
  }

  /**
   * Save uploaded file
   */
  private async saveFile(file: any, userId: bigint): Promise<string> {
    const fileName = `${userId}_${Date.now()}_${file.originalname}`;
    const filePath = path.join(this.uploadDir, fileName);

    fs.writeFileSync(filePath, file.buffer);

    return filePath;
  }

  /**
   * Create document
   */
  async create(userId: bigint, createDto: CreateDocumentDto, file: any) {
    const filePath = await this.saveFile(file, userId);
    const fileType = file.mimetype || path.extname(file.originalname).substring(1);

    const document = await this.prisma.userDocument.create({
      data: {
        userId,
        documentType: createDto.type,
        title: createDto.title,
        description: createDto.description || null,
        filePath,
        fileType,
        uploadedBy: userId,
        visibility: createDto.visibility || DocumentVisibility.PRIVATE,
      },
    });

    return this.mapToResponse(document);
  }

  /**
   * Find all documents for a user
   */
  async findAll(userId: bigint, type?: DocumentType) {
    const where: any = { userId };
    if (type) {
      where.documentType = type;
    }

    const documents = await this.prisma.userDocument.findMany({
      where,
      orderBy: {
        uploadedAt: 'desc',
      },
    });

    return documents.map((doc) => this.mapToResponse(doc));
  }

  /**
   * Find one document by ID
   */
  async findOne(userId: bigint, documentId: bigint) {
    const document = await this.prisma.userDocument.findFirst({
      where: {
        documentId,
        userId,
      },
    });

    if (!document) {
      throw new NotFoundException('Document not found');
    }

    return this.mapToResponse(document);
  }

  /**
   * Get document file
   */
  async getFile(userId: bigint, documentId: bigint) {
    const document = await this.prisma.userDocument.findFirst({
      where: {
        documentId,
        userId,
      },
    });

    if (!document) {
      throw new NotFoundException('Document not found');
    }

    if (!fs.existsSync(document.filePath)) {
      throw new NotFoundException('File not found');
    }

    return {
      filePath: document.filePath,
      fileName: path.basename(document.filePath),
      fileType: document.fileType,
    };
  }

  /**
   * Update document metadata
   */
  async update(userId: bigint, documentId: bigint, updateDto: Partial<CreateDocumentDto>) {
    const document = await this.prisma.userDocument.findFirst({
      where: {
        documentId,
        userId,
      },
    });

    if (!document) {
      throw new NotFoundException('Document not found');
    }

    const updateData: any = {};
    if (updateDto.title) updateData.title = updateDto.title;
    if (updateDto.description !== undefined) updateData.description = updateDto.description;
    if (updateDto.type) updateData.documentType = updateDto.type;
    if (updateDto.visibility !== undefined) updateData.visibility = updateDto.visibility;

    const updated = await this.prisma.userDocument.update({
      where: { documentId },
      data: updateData,
    });

    return this.mapToResponse(updated);
  }

  /**
   * Update document visibility
   */
  async updateVisibility(userId: bigint, documentId: bigint, visibility: DocumentVisibility) {
    const document = await this.prisma.userDocument.findFirst({
      where: {
        documentId,
        userId,
      },
    });

    if (!document) {
      throw new NotFoundException('Document not found');
    }

    const updated = await this.prisma.userDocument.update({
      where: { documentId },
      data: { visibility },
    });

    return this.mapToResponse(updated);
  }

  /**
   * Delete document
   */
  async remove(userId: bigint, documentId: bigint) {
    const document = await this.prisma.userDocument.findFirst({
      where: {
        documentId,
        userId,
      },
    });

    if (!document) {
      throw new NotFoundException('Document not found');
    }

    // Delete file if exists
    if (fs.existsSync(document.filePath)) {
      fs.unlinkSync(document.filePath);
    }

    await this.prisma.userDocument.delete({
      where: { documentId },
    });

    return { message: 'Document deleted successfully' };
  }

  /**
   * Map database model to API response
   */
  private mapToResponse(document: any) {
    return {
      id: document.documentId.toString(),
      title: document.title,
      type: document.documentType,
      filePath: document.filePath,
      uploadDate: document.uploadedAt.toISOString(),
      visibility: document.visibility,
      description: document.description || null,
      userId: document.userId.toString(),
    };
  }
}


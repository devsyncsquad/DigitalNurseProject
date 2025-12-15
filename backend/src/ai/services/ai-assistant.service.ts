import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { VectorSearchService } from './vector-search.service';
import { EmbeddingService } from './embedding.service';
import { AppConfigService } from '../../config/config.service';
import { ChatMessageDto } from '../dto/chat-message.dto';

interface ConversationContext {
  medications: any[];
  vitals: any[];
  notes: any[];
  dietLogs: any[];
  exerciseLogs: any[];
}

@Injectable()
export class AIAssistantService {
  private readonly logger = new Logger(AIAssistantService.name);
  private geminiApiKey: string | null = null;

  constructor(
    private prisma: PrismaService,
    private vectorSearchService: VectorSearchService,
    private embeddingService: EmbeddingService,
    private appConfigService: AppConfigService,
  ) {
    this.initializeGeminiKey();
  }

  private async initializeGeminiKey() {
    try {
      this.geminiApiKey = await this.appConfigService.getGeminiApiKey();
      if (!this.geminiApiKey) {
        this.logger.warn('Gemini API key not found. AI Assistant will not work.');
      }
    } catch (error) {
      this.logger.error('Error initializing Gemini API key:', error);
    }
  }

  /**
   * Process a chat message and generate AI response
   */
  async chat(
    userId: bigint,
    dto: ChatMessageDto,
  ): Promise<{ message: string; conversationId: bigint; sources?: any[] }> {
    if (!this.geminiApiKey) {
      throw new Error('Gemini API key not configured');
    }

    // Get or create conversation
    let conversationId = dto.conversationId;
    if (!conversationId) {
      const conversation = await this.createConversation(
        userId,
        dto.elderUserId,
      );
      conversationId = conversation.conversationId;
    }

    // Retrieve relevant context using RAG
    const context = await this.retrieveContext(
      userId,
      dto.elderUserId,
      dto.message,
    );

    // Build prompt with context
    const prompt = this.buildPrompt(dto.message, context);

    // Generate response using Gemini
    const response = await this.generateResponse(prompt);

    // Store messages
    await this.storeMessage(conversationId, 'user', dto.message);
    await this.storeMessage(conversationId, 'assistant', response.message, {
      sources: response.sources,
    });

    // Update conversation
    await this.updateConversation(conversationId);

    return {
      message: response.message,
      conversationId,
      sources: response.sources,
    };
  }

  /**
   * Retrieve relevant context using vector search (RAG)
   */
  private async retrieveContext(
    userId: bigint,
    elderUserId?: bigint,
    query?: string,
  ): Promise<ConversationContext> {
    const context: ConversationContext = {
      medications: [],
      vitals: [],
      notes: [],
      dietLogs: [],
      exerciseLogs: [],
    };

    if (query) {
      // Use semantic search to find relevant information
      const searchResults = await this.vectorSearchService.searchAll({
        query,
        elderUserId,
        limit: 5,
      });

      // Group results by entity type
      searchResults.forEach((result) => {
        switch (result.entityType) {
          case 'medications':
            context.medications.push(result);
            break;
          case 'vital_measurements':
            context.vitals.push(result);
            break;
          case 'caregiver_notes':
            context.notes.push(result);
            break;
          case 'diet_logs':
            context.dietLogs.push(result);
            break;
          case 'exercise_logs':
            context.exerciseLogs.push(result);
            break;
        }
      });
    } else {
      // Get recent data if no query
      if (elderUserId) {
        const [medications, vitals, notes] = await Promise.all([
          this.prisma.medication.findMany({
            where: { elderUserId },
            take: 5,
            orderBy: { createdAt: 'desc' },
          }),
          this.prisma.vitalMeasurement.findMany({
            where: { elderUserId },
            take: 5,
            orderBy: { recordedAt: 'desc' },
          }),
          this.prisma.caregiverNote.findMany({
            where: { elderUserId },
            take: 5,
            orderBy: { createdAt: 'desc' },
          }),
        ]);

        context.medications = medications;
        context.vitals = vitals;
        context.notes = notes;
      }
    }

    return context;
  }

  /**
   * Build prompt with context for Gemini
   */
  private buildPrompt(message: string, context: ConversationContext): string {
    let prompt = `You are a helpful AI health assistant for Digital Nurse. Answer the user's question based on their health data.

User Question: ${message}

Relevant Health Data:
`;

    if (context.medications.length > 0) {
      prompt += `\nMedications:\n`;
      context.medications.forEach((med: any) => {
        prompt += `- ${med.medicationName || med.metadata?.medicationName || 'Medication'}: ${med.content || med.instructions || ''}\n`;
      });
    }

    if (context.vitals.length > 0) {
      prompt += `\nRecent Vital Measurements:\n`;
      context.vitals.forEach((vital: any) => {
        prompt += `- ${vital.metadata?.kindCode || 'Vital'}: ${vital.content || ''}\n`;
      });
    }

    if (context.notes.length > 0) {
      prompt += `\nCaregiver Notes:\n`;
      context.notes.forEach((note: any) => {
        prompt += `- ${note.content || note.noteText || ''}\n`;
      });
    }

    prompt += `\nInstructions:
- Answer based on the provided health data
- Be concise and helpful
- If you don't have enough information, say so
- Always recommend consulting healthcare providers for medical advice
- Use a friendly, supportive tone

Answer:`;

    return prompt;
  }

  /**
   * Generate response using Gemini API
   */
  private async generateResponse(prompt: string): Promise<{
    message: string;
    sources?: any[];
  }> {
    try {
      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${this.geminiApiKey}`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            contents: [
              {
                parts: [{ text: prompt }],
              },
            ],
          }),
        },
      );

      if (!response.ok) {
        const error = await response.json();
        throw new Error(
          `Gemini API error: ${error.error?.message || response.statusText}`,
        );
      }

      const data = await response.json();
      const message =
        data.candidates?.[0]?.content?.parts?.[0]?.text ||
        'I apologize, but I could not generate a response.';

      return { message };
    } catch (error: any) {
      this.logger.error('Error generating AI response:', error);
      throw new Error(`Failed to generate response: ${error.message}`);
    }
  }

  /**
   * Create a new conversation
   */
  private async createConversation(
    userId: bigint,
    elderUserId?: bigint,
  ): Promise<{ conversationId: bigint }> {
    const result = await this.prisma.$executeRawUnsafe(
      `INSERT INTO ai_conversations (user_id, elder_user_id, created_at, updated_at)
       VALUES ($1, $2, NOW(), NOW())
       RETURNING conversation_id`,
      userId.toString(),
      elderUserId?.toString() || null,
    );

    const conversations = await this.prisma.$queryRawUnsafe(
      `SELECT conversation_id FROM ai_conversations 
       WHERE user_id = ${userId} 
       ORDER BY created_at DESC LIMIT 1`,
    );

    return {
      conversationId: BigInt((conversations as any[])[0].conversation_id),
    };
  }

  /**
   * Store a message in the conversation
   */
  private async storeMessage(
    conversationId: bigint,
    role: 'user' | 'assistant',
    content: string,
    metadata?: any,
  ) {
    await this.prisma.$executeRawUnsafe(
      `INSERT INTO ai_conversation_messages 
       (conversation_id, role, content, metadata, created_at)
       VALUES ($1, $2, $3, $4, NOW())`,
      conversationId.toString(),
      role,
      content,
      JSON.stringify(metadata || {}),
    );
  }

  /**
   * Update conversation timestamp
   */
  private async updateConversation(conversationId: bigint) {
    await this.prisma.$executeRawUnsafe(
      `UPDATE ai_conversations 
       SET updated_at = NOW() 
       WHERE conversation_id = ${conversationId}`,
    );
  }

  /**
   * Get conversation history
   */
  async getConversation(conversationId: bigint, userId: bigint) {
    const conversation = await this.prisma.$queryRawUnsafe(
      `SELECT * FROM ai_conversations 
       WHERE conversation_id = ${conversationId} AND user_id = ${userId}`,
    );

    if (!conversation || (conversation as any[]).length === 0) {
      return null;
    }

    const messages = await this.prisma.$queryRawUnsafe(
      `SELECT * FROM ai_conversation_messages 
       WHERE conversation_id = ${conversationId} 
       ORDER BY created_at ASC`,
    );

    return {
      conversation: (conversation as any[])[0],
      messages: messages as any[],
    };
  }

  /**
   * Get all conversations for a user
   */
  async getConversations(userId: bigint, elderUserId?: bigint) {
    let query = `SELECT * FROM ai_conversations WHERE user_id = ${userId}`;
    if (elderUserId) {
      query += ` AND elder_user_id = ${elderUserId}`;
    }
    query += ` ORDER BY updated_at DESC`;

    const conversations = await this.prisma.$queryRawUnsafe(query);
    return conversations as any[];
  }
}


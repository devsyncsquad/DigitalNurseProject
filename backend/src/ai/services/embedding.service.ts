import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AppConfigService } from '../../config/config.service';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class EmbeddingService {
  private readonly logger = new Logger(EmbeddingService.name);
  private embeddingModel: string = 'text-embedding-3-small';
  private embeddingDimensions: number = 1536;
  private openaiApiKey: string | null = null;

  constructor(
    private configService: ConfigService,
    private appConfigService: AppConfigService,
    private prisma: PrismaService,
  ) {
    this.initializeConfig();
  }

  private async initializeConfig() {
    try {
      const modelConfig = await this.appConfigService.getConfigByKey(
        'ai_embedding_model',
      );
      if (modelConfig) {
        this.embeddingModel = modelConfig.configValue;
      }

      const dimensionsConfig = await this.appConfigService.getConfigByKey(
        'ai_embedding_dimensions',
      );
      if (dimensionsConfig) {
        this.embeddingDimensions = parseInt(dimensionsConfig.configValue, 10);
      }

      // Try to get OpenAI API key from environment or config
      this.openaiApiKey =
        this.configService.get<string>('OPENAI_API_KEY') || null;

      if (!this.openaiApiKey) {
        this.logger.warn(
          'OpenAI API key not found. Embedding generation will fail. Set OPENAI_API_KEY in environment or app_config.',
        );
      }
    } catch (error) {
      this.logger.error('Error initializing embedding config:', error);
    }
  }

  /**
   * Generate embedding for a single text
   */
  async generateEmbedding(text: string): Promise<number[]> {
    if (!text || text.trim().length === 0) {
      throw new Error('Text cannot be empty');
    }

    if (!this.openaiApiKey) {
      throw new Error('OpenAI API key not configured');
    }

    try {
      const response = await fetch('https://api.openai.com/v1/embeddings', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.openaiApiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: this.embeddingModel,
          input: text.trim(),
          dimensions: this.embeddingDimensions,
        }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(
          `OpenAI API error: ${error.error?.message || response.statusText}`,
        );
      }

      const data = await response.json();
      return data.data[0].embedding;
    } catch (error: any) {
      this.logger.error('Error generating embedding:', error);
      throw new Error(`Failed to generate embedding: ${error.message}`);
    }
  }

  /**
   * Generate embeddings for multiple texts in batch
   */
  async generateEmbeddingsBatch(texts: string[]): Promise<number[][]> {
    if (!texts || texts.length === 0) {
      return [];
    }

    if (!this.openaiApiKey) {
      throw new Error('OpenAI API key not configured');
    }

    // Filter out empty texts
    const validTexts = texts.filter((text) => text && text.trim().length > 0);
    if (validTexts.length === 0) {
      return [];
    }

    try {
      const response = await fetch('https://api.openai.com/v1/embeddings', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.openaiApiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: this.embeddingModel,
          input: validTexts.map((text) => text.trim()),
          dimensions: this.embeddingDimensions,
        }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(
          `OpenAI API error: ${error.error?.message || response.statusText}`,
        );
      }

      const data = await response.json();
      return data.data.map((item: any) => item.embedding);
    } catch (error: any) {
      this.logger.error('Error generating batch embeddings:', error);
      throw new Error(`Failed to generate embeddings: ${error.message}`);
    }
  }

  /**
   * Generate embedding and store it in a table column
   */
  async generateAndStoreEmbedding(
    tableName: string,
    recordId: bigint,
    columnName: string,
    text: string,
  ): Promise<void> {
    try {
      const embedding = await this.generateEmbedding(text);
      const embeddingArray = `[${embedding.join(',')}]`;

      await this.prisma.$executeRawUnsafe(
        `UPDATE ${tableName} SET ${columnName} = $1::vector WHERE id = $2`,
        embeddingArray,
        recordId,
      );
    } catch (error: any) {
      this.logger.error(
        `Error storing embedding for ${tableName}.${columnName}:`,
        error,
      );
      throw error;
    }
  }

  /**
   * Get embedding dimensions
   */
  getDimensions(): number {
    return this.embeddingDimensions;
  }

  /**
   * Get embedding model name
   */
  getModel(): string {
    return this.embeddingModel;
  }
}


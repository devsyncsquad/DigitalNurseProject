import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { AIHealthAnalystService } from './ai-health-analyst.service';
import { EmbeddingService } from './embedding.service';
import {
  GenerateInsightDto,
  GetInsightsDto,
  InsightType,
  InsightPriority,
} from '../dto/generate-insight.dto';

@Injectable()
export class AIInsightsService {
  private readonly logger = new Logger(AIInsightsService.name);

  constructor(
    private prisma: PrismaService,
    private healthAnalyst: AIHealthAnalystService,
    private embeddingService: EmbeddingService,
  ) {}

  /**
   * Generate and store an AI insight
   */
  async generateInsight(dto: GenerateInsightDto, userId: bigint) {
    let insight: {
      title: string;
      content: string;
      confidence: number;
      recommendations?: any[];
    };

    switch (dto.insightType) {
      case InsightType.MEDICATION_ADHERENCE:
        insight = await this.generateMedicationAdherenceInsight(
          dto.elderUserId,
        );
        break;
      case InsightType.HEALTH_TREND:
        insight = await this.generateHealthTrendInsight(dto.elderUserId);
        break;
      case InsightType.RECOMMENDATION:
        insight = await this.generateRecommendationInsight(dto.elderUserId);
        break;
      case InsightType.ALERT:
        insight = await this.generateAlertInsight(dto.elderUserId);
        break;
      case InsightType.PATTERN_DETECTION:
        insight = await this.generatePatternInsight(dto.elderUserId);
        break;
      default:
        throw new Error(`Unknown insight type: ${dto.insightType}`);
    }

    // Generate embedding for the insight
    const embeddingText = `${insight.title} ${insight.content}`;
    const embedding = await this.embeddingService.generateEmbedding(embeddingText);

    // Store the insight
    const embeddingArray = `[${embedding.join(',')}]`;
    const result = await this.prisma.$executeRawUnsafe(
      `INSERT INTO ai_insights (
        user_id, elder_user_id, insight_type, title, content,
        confidence, priority, category, recommendations, embedding,
        metadata, generated_at
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10::vector, $11, NOW()
      ) RETURNING insight_id`,
      userId.toString(),
      dto.elderUserId.toString(),
      dto.insightType,
      insight.title,
      insight.content,
      insight.confidence,
      dto.priority || InsightPriority.MEDIUM,
      dto.category || null,
      JSON.stringify(insight.recommendations || []),
      embeddingArray,
      JSON.stringify(dto.metadata || {}),
    );

    return result;
  }

  /**
   * Get insights with filters
   */
  async getInsights(userId: bigint, dto: GetInsightsDto) {
    let query = `
      SELECT 
        insight_id,
        user_id,
        elder_user_id,
        insight_type,
        title,
        content,
        confidence,
        priority,
        category,
        recommendations,
        is_read,
        is_archived,
        generated_at,
        expires_at,
        created_at
      FROM ai_insights
      WHERE user_id = ${userId}
        AND is_archived = false
    `;

    if (dto.elderUserId) {
      query += ` AND elder_user_id = ${dto.elderUserId}`;
    }

    if (dto.types && dto.types.length > 0) {
      const types = dto.types.map((t) => `'${t}'`).join(',');
      query += ` AND insight_type IN (${types})`;
    }

    if (dto.priorities && dto.priorities.length > 0) {
      const priorities = dto.priorities.map((p) => `'${p}'`).join(',');
      query += ` AND priority IN (${priorities})`;
    }

    if (dto.categories && dto.categories.length > 0) {
      const categories = dto.categories.map((c) => `'${c}'`).join(',');
      query += ` AND category IN (${categories})`;
    }

    if (dto.isRead !== undefined) {
      query += ` AND is_read = ${dto.isRead}`;
    }

    query += ` ORDER BY generated_at DESC LIMIT ${dto.limit || 20}`;

    const results = await this.prisma.$queryRawUnsafe(query);
    return (results as any[]).map((r) => ({
      id: r.insight_id.toString(),
      userId: r.user_id.toString(),
      elderUserId: r.elder_user_id?.toString(),
      type: r.insight_type,
      title: r.title,
      content: r.content,
      confidence: r.confidence ? parseFloat(r.confidence) : null,
      priority: r.priority,
      category: r.category,
      recommendations: r.recommendations ? JSON.parse(r.recommendations) : [],
      isRead: r.is_read,
      isArchived: r.is_archived,
      generatedAt: r.generated_at,
      expiresAt: r.expires_at,
      createdAt: r.created_at,
    }));
  }

  /**
   * Mark insight as read
   */
  async markAsRead(insightId: bigint, userId: bigint) {
    await this.prisma.$executeRawUnsafe(
      `UPDATE ai_insights 
       SET is_read = true, updated_at = NOW() 
       WHERE insight_id = ${insightId} AND user_id = ${userId}`,
    );
  }

  /**
   * Archive insight
   */
  async archiveInsight(insightId: bigint, userId: bigint) {
    await this.prisma.$executeRawUnsafe(
      `UPDATE ai_insights 
       SET is_archived = true, updated_at = NOW() 
       WHERE insight_id = ${insightId} AND user_id = ${userId}`,
    );
  }

  /**
   * Delete expired insights
   */
  async deleteExpiredInsights() {
    const result = await this.prisma.$executeRawUnsafe(
      `DELETE FROM ai_insights 
       WHERE expires_at IS NOT NULL AND expires_at < NOW()`,
    );
    this.logger.log(`Deleted expired insights`);
    return result;
  }

  // Private methods for generating specific insight types

  private async generateMedicationAdherenceInsight(elderUserId: bigint) {
    const analysis = await this.healthAnalyst.analyzeHealth(elderUserId);
    const adherence = analysis.medicationAdherence.overallPercentage;

    if (adherence < 70) {
      return {
        title: 'Low Medication Adherence Detected',
        content: `Your medication adherence is ${adherence.toFixed(1)}%, which is below the recommended 80%. This may impact treatment effectiveness.`,
        confidence: 85,
        recommendations: analysis.medicationAdherence.recommendations,
      };
    } else if (adherence < 80) {
      return {
        title: 'Medication Adherence Needs Improvement',
        content: `Your medication adherence is ${adherence.toFixed(1)}%. Consider setting reminders to improve consistency.`,
        confidence: 75,
        recommendations: analysis.medicationAdherence.recommendations,
      };
    }

    return {
      title: 'Good Medication Adherence',
      content: `Your medication adherence is ${adherence.toFixed(1)}%. Keep up the good work!`,
      confidence: 90,
      recommendations: [],
    };
  }

  private async generateHealthTrendInsight(elderUserId: bigint) {
    const analysis = await this.healthAnalyst.analyzeHealth(elderUserId);
    const highConcernTrends = analysis.healthTrends.vitals.filter(
      (v) => v.concernLevel === 'high',
    );

    if (highConcernTrends.length > 0) {
      return {
        title: 'Concerning Health Trends Detected',
        content: `We've detected concerning trends in ${highConcernTrends.map((v) => v.type).join(', ')}. Please consult your healthcare provider.`,
        confidence: 80,
        recommendations: analysis.healthTrends.recommendations,
      };
    }

    return {
      title: 'Health Trends Stable',
      content: 'Your health measurements are within normal ranges and showing stable trends.',
      confidence: 85,
      recommendations: [],
    };
  }

  private async generateRecommendationInsight(elderUserId: bigint) {
    const analysis = await this.healthAnalyst.analyzeHealth(elderUserId);
    const allRecommendations = [
      ...analysis.medicationAdherence.recommendations,
      ...analysis.healthTrends.recommendations,
      ...analysis.lifestyleCorrelation.recommendations,
    ];

    if (allRecommendations.length === 0) {
      return {
        title: 'No Recommendations at This Time',
        content: 'Your health data looks good. Continue maintaining your current routine.',
        confidence: 70,
        recommendations: [],
      };
    }

    return {
      title: 'Personalized Health Recommendations',
      content: `Based on your recent health data, we have ${allRecommendations.length} recommendations to help improve your health outcomes.`,
      confidence: 75,
      recommendations: allRecommendations,
    };
  }

  private async generateAlertInsight(elderUserId: bigint) {
    const analysis = await this.healthAnalyst.analyzeHealth(elderUserId);
    const highRiskFactors = analysis.riskFactors.filter(
      (r) => r.severity === 'high',
    );

    if (highRiskFactors.length > 0) {
      return {
        title: 'Health Alert: Action Required',
        content: `We've identified ${highRiskFactors.length} high-priority risk factor(s) that require attention.`,
        confidence: 90,
        recommendations: highRiskFactors.map((r) => r.recommendation),
      };
    }

    return null; // No alert needed
  }

  private async generatePatternInsight(elderUserId: bigint) {
    // This would use more advanced pattern detection
    // For now, return a simple pattern insight
    return {
      title: 'Health Pattern Analysis',
      content: 'We are analyzing your health patterns. Check back soon for personalized insights.',
      confidence: 60,
      recommendations: [],
    };
  }
}


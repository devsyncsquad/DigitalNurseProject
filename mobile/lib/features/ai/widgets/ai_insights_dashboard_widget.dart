import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/ai_service.dart';
import 'ai_insight_card.dart';

class AIInsightsDashboardWidget extends StatefulWidget {
  final int? elderUserId;
  final int limit;

  const AIInsightsDashboardWidget({
    super.key,
    this.elderUserId,
    this.limit = 3,
  });

  @override
  State<AIInsightsDashboardWidget> createState() =>
      _AIInsightsDashboardWidgetState();
}

class _AIInsightsDashboardWidgetState
    extends State<AIInsightsDashboardWidget> {
  final AIService _aiService = AIService();
  List<dynamic> _insights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    try {
      final insights = await _aiService.getInsights(
        elderUserId: widget.elderUserId,
        limit: widget.limit,
        isRead: false,
      );

      if (mounted) {
        setState(() {
          _insights = insights;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Insights',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.push('/ai/insights'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._insights.take(widget.limit).map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AIInsightCard(
                    id: insight['id']?.toString() ?? '',
                    title: insight['title'] ?? 'Insight',
                    content: insight['content'] ?? '',
                    priority: insight['priority'] ?? 'medium',
                    category: insight['category'],
                    isRead: insight['isRead'] ?? false,
                    generatedAt: insight['generatedAt'] != null
                        ? DateTime.parse(insight['generatedAt'])
                        : DateTime.now(),
                    onTap: () => context.push('/ai/insights'),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}


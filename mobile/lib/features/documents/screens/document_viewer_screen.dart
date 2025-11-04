import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/models/document_model.dart';
import '../../../core/theme/app_theme.dart';

class DocumentViewerScreen extends StatelessWidget {
  final String documentId;

  const DocumentViewerScreen({super.key, required this.documentId});

  Future<void> _handleDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: context.theme.colors.destructive,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await context.read<DocumentProvider>().deleteDocument(
        documentId,
      );
      if (context.mounted && success) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = context.watch<DocumentProvider>();
    final document = documentProvider.documents.firstWhere(
      (d) => d.id == documentId,
    );

    return FScaffold(
      header: FHeader.nested(
        title: const Text('Document Details'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        suffixes: [
          FHeaderAction(
            icon: Icon(FIcons.trash, color: context.theme.colors.destructive),
            onPress: () => _handleDelete(context),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Document preview (mock)
            FCard(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: context.theme.colors.muted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FIcons.fileText, size: 64, color: context.theme.colors.mutedForeground),
                    const SizedBox(height: 16),
                    Text(
                      'Document Preview (Mock)',
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Document details
            FCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: context.theme.typography.xl.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(label: 'Type', value: document.type.displayName),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Upload Date',
                      value: DateFormat(
                        'MMM d, yyyy - h:mm a',
                      ).format(document.uploadDate),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Visibility',
                      value: _getVisibilityText(document.visibility),
                    ),
                    if (document.description != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Description',
                        value: document.description!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            FButton(
              onPress: () {
                // Mock download
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Download started (mock)'),
                    backgroundColor: AppTheme.getSuccessColor(context),
                  ),
                );
              },
              prefix: const Icon(FIcons.download),
              child: const Text('Download'),
            ),
            const SizedBox(height: 12),

            FButton(
              onPress: () {
                // Mock share
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Share functionality (mock)'),
                    backgroundColor: context.theme.colors.primary,
                  ),
                );
              },
              prefix: const Icon(FIcons.share),
              child: const Text('Share'),
            ),
          ],
        ),
      ),
    );
  }

  String _getVisibilityText(DocumentVisibility visibility) {
    switch (visibility) {
      case DocumentVisibility.private:
        return 'Private';
      case DocumentVisibility.sharedWithCaregiver:
        return 'Shared with Caregivers';
      case DocumentVisibility.public:
        return 'Public';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: context.theme.typography.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

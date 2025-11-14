import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/models/document_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/modern_surface_theme.dart';
import '../../../core/widgets/modern_scaffold.dart';

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

    return ModernScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Document Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () => _handleDelete(context),
            icon: const Icon(Icons.delete_outline, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: ModernSurfaceTheme.screenPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 220,
              decoration: ModernSurfaceTheme.glassCard(
                context,
                accent: AppTheme.getDocumentColor(context, document.type.name),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FIcons.fileText,
                    size: 64,
                    color: ModernSurfaceTheme.primaryTeal,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Document Preview (Mock)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ModernSurfaceTheme.deepTeal.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              decoration: ModernSurfaceTheme.glassCard(context),
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: ModernSurfaceTheme.deepTeal,
                        ),
                  ),
                  SizedBox(height: 16.h),
                  _InfoRow(label: 'Type', value: document.type.displayName),
                  SizedBox(height: 8.h),
                  _InfoRow(
                    label: 'Upload Date',
                    value: DateFormat('MMM d, yyyy - h:mm a')
                        .format(document.uploadDate),
                  ),
                  SizedBox(height: 8.h),
                  _InfoRow(
                    label: 'Visibility',
                    value: _getVisibilityText(document.visibility),
                  ),
                  if (document.description != null) ...[
                    SizedBox(height: 8.h),
                    _InfoRow(
                      label: 'Description',
                      value: document.description!,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Download started (mock)'),
                    backgroundColor: AppTheme.getSuccessColor(context),
                  ),
                );
              },
              icon: const Icon(FIcons.download),
              label: const Text('Download'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                backgroundColor: ModernSurfaceTheme.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Share functionality (mock)'),
                    backgroundColor: AppTheme.getSuccessColor(context),
                  ),
                );
              },
              icon: const Icon(FIcons.share),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                side: BorderSide(
                  color: ModernSurfaceTheme.deepTeal.withOpacity(0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
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
          width: 120.w,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ModernSurfaceTheme.deepTeal.withOpacity(0.6),
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ModernSurfaceTheme.deepTeal,
                ),
          ),
        ),
      ],
    );
  }
}

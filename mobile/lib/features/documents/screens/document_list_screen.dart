import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/document_model.dart';
import '../../../core/theme/app_theme.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  @override
  void initState() {
    super.initState();
    // Defer data loading until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId != null) {
      final documentProvider = context.read<DocumentProvider>();
      // Initialize mock data first, then load documents
      await documentProvider.initializeMockData(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = context.watch<DocumentProvider>();
    final documents = documentProvider.documents;
    final isLoading = documentProvider.isLoading;

    return FScaffold(
      header: FHeader(
        title: const Text('My Documents'),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FIcons.plus),
            onPress: () => context.push('/documents/upload'),
          ),
        ],
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : documents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FIcons.fileText,
                    size: 64,
                    color: context.theme.colors.mutedForeground,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No documents uploaded yet',
                    style: context.theme.typography.lg,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Keep your medical records organized',
                    style: context.theme.typography.sm,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  FButton(
                    onPress: () => context.push('/documents/upload'),
                    child: const Text('Upload Document'),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65, // Provides more vertical space
              ),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                return FCard(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.push('/documents/${document.id}'),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _getDocumentColor(
                                  context,
                                  document.type,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getDocumentIcon(document.type),
                                size: 40,
                                color: _getDocumentColor(
                                  context,
                                  document.type,
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              document.title,
                              style: context.theme.typography.sm.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                FBadge(child: Text(document.type.name)),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              DateFormat(
                                'MMM d, yyyy',
                              ).format(document.uploadDate),
                              style: context.theme.typography.xs.copyWith(
                                color: context.theme.colors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.prescription:
        return FIcons.pill;
      case DocumentType.labReport:
        return FIcons.activity;
      case DocumentType.xray:
      case DocumentType.scan:
        return FIcons.image;
      case DocumentType.discharge:
        return FIcons.fileText;
      case DocumentType.insurance:
        return FIcons.shield;
      case DocumentType.other:
        return FIcons.file;
    }
  }

  Color _getDocumentColor(BuildContext context, DocumentType type) {
    switch (type) {
      case DocumentType.prescription:
        return AppTheme.getDocumentColor(context, 'prescription');
      case DocumentType.labReport:
        return AppTheme.getDocumentColor(context, 'labreport');
      case DocumentType.xray:
      case DocumentType.scan:
        return AppTheme.getDocumentColor(context, 'xray');
      case DocumentType.discharge:
        return AppTheme.getDocumentColor(context, 'discharge');
      case DocumentType.insurance:
        return AppTheme.getDocumentColor(context, 'insurance');
      case DocumentType.other:
        return AppTheme.getDocumentColor(context, 'other');
    }
  }
}

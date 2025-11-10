import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/care_context_provider.dart';
import '../../../core/models/document_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  String? _lastContextKey;

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
    final documentProvider = context.read<DocumentProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return;
    }

    final isCaregiver = user.role == UserRole.caregiver;
    String? targetUserId = user.id;
    String? elderUserId;

    if (isCaregiver) {
      final careContext = context.read<CareContextProvider>();
      await careContext.ensureLoaded();
      targetUserId = careContext.selectedElderId;
      elderUserId = targetUserId;
      if (targetUserId == null) {
        return;
      }
    }

    await documentProvider.loadDocuments(
      targetUserId,
      elderUserId: elderUserId,
    );
  }

  void _ensureContextSync({
    required bool isCaregiver,
    required String? selectedElderId,
    required String? userId,
  }) {
    final key = isCaregiver
        ? 'caregiver-${selectedElderId ?? 'none'}'
        : 'patient-${userId ?? 'unknown'}';

    if (_lastContextKey == key) {
      return;
    }

    _lastContextKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final isCaregiver = currentUser?.role == UserRole.caregiver;
    final careContext = isCaregiver
        ? context.watch<CareContextProvider>()
        : null;
    final selectedElderId = careContext?.selectedElderId;
    final hasAssignments =
        !isCaregiver || (careContext?.careRecipients.isNotEmpty ?? false);
    final isCareContextLoading = careContext?.isLoading ?? false;
    final careContextError = careContext?.error;

    _ensureContextSync(
      isCaregiver: isCaregiver,
      selectedElderId: selectedElderId,
      userId: currentUser?.id,
    );

    final documentProvider = context.watch<DocumentProvider>();
    final documents = documentProvider.documents;
    final isLoading = documentProvider.isLoading;
    final error = documentProvider.error;

    return FScaffold(
      header: FHeader(
        title: const Text('My Documents'),
        suffixes: [
          if (!isCaregiver)
            FHeaderAction(
              icon: const Icon(FIcons.plus),
              onPress: () => context.push('/documents/upload'),
            ),
        ],
      ),
      child: _buildBody(
        context,
        isCaregiver: isCaregiver,
        hasAssignments: hasAssignments,
        hasSelectedRecipient: selectedElderId != null,
        isCareContextLoading: isCareContextLoading,
        careContextError: careContextError,
        isLoading: isLoading,
        error: error,
        documents: documents,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required bool isCaregiver,
    required bool hasAssignments,
    required bool hasSelectedRecipient,
    required bool isCareContextLoading,
    required String? careContextError,
    required bool isLoading,
    required String? error,
    required List<DocumentModel> documents,
  }) {
    if (isCaregiver) {
      if (isCareContextLoading && !hasAssignments) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!hasAssignments) {
        return _buildCaregiverNotice(
          context,
          icon: FIcons.users,
          title: 'No patients assigned yet',
          message:
              'When a patient shares their records with you, their documents will be visible here.',
        );
      }

      if (careContextError != null && !hasSelectedRecipient) {
        return _buildCaregiverNotice(
          context,
          icon: FIcons.info,
          title: 'Unable to load patients',
          message: careContextError,
          onRetry: _loadData,
        );
      }

      if (!hasSelectedRecipient) {
        return _buildCaregiverNotice(
          context,
          icon: FIcons.userSearch,
          title: 'Select a patient to continue',
          message:
              'Choose a patient from the dashboard to review their shared documents.',
        );
      }
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (error != null)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.getErrorColor(context).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.getErrorColor(context).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(FIcons.info, color: AppTheme.getErrorColor(context)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      error,
                      style: context.theme.typography.sm.copyWith(
                        color: AppTheme.getErrorColor(context),
                      ),
                    ),
                  ),
                  TextButton(onPressed: _loadData, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        Expanded(
          child: documents.isEmpty
              ? _buildEmptyState(context, isCaregiver: isCaregiver)
              : GridView.builder(
                  padding: EdgeInsets.all(16.w),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    return FCard(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              context.push('/documents/${document.id}'),
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
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isCaregiver}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FIcons.fileText,
            size: 64,
            color: context.theme.colors.mutedForeground,
          ),
          SizedBox(height: 16),
          Text('No documents uploaded yet', style: context.theme.typography.lg),
          SizedBox(height: 8),
          Text(
            isCaregiver
                ? 'This patient has not shared any documents yet.'
                : 'Keep your medical records organized',
            style: context.theme.typography.sm,
            textAlign: TextAlign.center,
          ),
          if (!isCaregiver) ...[
            SizedBox(height: 24),
            FButton(
              onPress: () => context.push('/documents/upload'),
              child: const Text('Upload Document'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCaregiverNotice(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: context.theme.colors.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: context.theme.typography.lg.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: context.theme.typography.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FButton(onPress: onRetry, child: const Text('Retry')),
              ],
            ],
          ),
        ),
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

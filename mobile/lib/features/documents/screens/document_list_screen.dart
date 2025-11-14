import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/care_context_provider.dart';
import '../../../core/models/document_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/modern_surface_theme.dart';
import '../../../core/widgets/modern_scaffold.dart';

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

    return ModernScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Health Documents',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (!isCaregiver)
            IconButton(
              icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
              onPressed: () => context.push('/documents/upload'),
            ),
        ],
      ),
      body: Padding(
        padding: ModernSurfaceTheme.screenPadding(),
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
        _DocumentsHero(
          documentCount: documents.length,
          isCaregiver: isCaregiver,
        ),
        if (error != null) ...[
          SizedBox(height: 16.h),
          _ErrorBanner(message: error, onRetry: _loadData),
        ],
        SizedBox(height: 16.h),
        Expanded(
          child: documents.isEmpty
              ? _buildEmptyState(context, isCaregiver: isCaregiver)
              : GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ScreenUtil().screenWidth > 600 ? 3 : 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final accent = _getDocumentColor(context, document.type);
                final chipForeground =
                    ModernSurfaceTheme.chipForegroundColor(accent);
                    return Container(
                      decoration: ModernSurfaceTheme.glassCard(accent: accent),
                      padding: EdgeInsets.all(16.w),
                      child: InkWell(
                        onTap: () => context.push('/documents/${document.id}'),
                        borderRadius: ModernSurfaceTheme.cardRadius(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 90,
                              decoration: ModernSurfaceTheme.tintedCard(accent),
                              child: Icon(
                                _getDocumentIcon(document.type),
                                size: 36,
                                color: accent,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              document.title,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: ModernSurfaceTheme.deepTeal,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: ModernSurfaceTheme.frostedChip(
                                baseColor: accent,
                              ),
                              child: Text(
                                document.type.name,
                              style: TextStyle(
                                color: chipForeground,
                                fontWeight: FontWeight.w600,
                              ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('MMM d, yyyy')
                                  .format(document.uploadDate),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: ModernSurfaceTheme.deepTeal
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                          ],
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
    return Container(
      decoration: ModernSurfaceTheme.glassCard(),
      padding: ModernSurfaceTheme.cardPadding(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FIcons.fileText,
            size: 56,
            color: ModernSurfaceTheme.primaryTeal,
          ),
          SizedBox(height: 12.h),
          Text(
            'No documents uploaded yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ModernSurfaceTheme.deepTeal,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            isCaregiver
                ? 'This patient has not shared any records.'
                : 'Upload prescriptions, lab reports, and more.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ModernSurfaceTheme.deepTeal.withValues(alpha: 0.65),
                ),
          ),
          if (!isCaregiver) ...[
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () => context.push('/documents/upload'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernSurfaceTheme.primaryTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
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
    return Container(
      decoration: ModernSurfaceTheme.glassCard(),
      padding: ModernSurfaceTheme.cardPadding(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: ModernSurfaceTheme.primaryTeal),
          SizedBox(height: 16.h),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ModernSurfaceTheme.deepTeal,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ModernSurfaceTheme.deepTeal.withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: 16.h),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: ModernSurfaceTheme.primaryTeal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
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

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getErrorColor(context);
    return Container(
      decoration: ModernSurfaceTheme.glassCard(accent: color),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: color),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: color),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _DocumentsHero extends StatelessWidget {
  final int documentCount;
  final bool isCaregiver;

  const _DocumentsHero({
    required this.documentCount,
    required this.isCaregiver,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ModernSurfaceTheme.heroDecoration(),
      padding: ModernSurfaceTheme.heroPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCaregiver ? 'Shared records' : 'Your health vault',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            '$documentCount documents stored',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: const [
              _HeroChip(icon: Icons.verified, label: 'Secure & encrypted'),
              _HeroChip(icon: Icons.folder_special, label: 'Smart categories'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final chipForeground =
        ModernSurfaceTheme.chipForegroundColor(Colors.white);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: ModernSurfaceTheme.frostedChip(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipForeground),
          SizedBox(width: 6.w),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: chipForeground,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

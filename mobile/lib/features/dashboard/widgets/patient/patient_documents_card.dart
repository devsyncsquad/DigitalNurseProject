import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/document_model.dart';
import '../../../../core/providers/document_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../dashboard_theme.dart';

class PatientDocumentsCard extends StatelessWidget {
  const PatientDocumentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final documentProvider = context.watch<DocumentProvider>();
    final documents = documentProvider.documents;
    final recentDocuments = documents.take(4).toList();

    return Container(
      padding: CaregiverDashboardTheme.cardPadding(),
      decoration: CaregiverDashboardTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: CaregiverDashboardTheme.iconBadge(
                  CaregiverDashboardTheme.accentYellow,
                ),
                child: const Icon(
                  Icons.article_outlined,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent documents',
                      style: CaregiverDashboardTheme.sectionTitleStyle(
                        context,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Your latest medical records and documents.',
                      style: CaregiverDashboardTheme.sectionSubtitleStyle(
                        context,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (documents.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 18.h,
              ),
              decoration: CaregiverDashboardTheme.tintedCard(
                CaregiverDashboardTheme.primaryTeal,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: CaregiverDashboardTheme.iconBadge(
                      CaregiverDashboardTheme.primaryTeal,
                    ),
                    child: const Icon(
                      Icons.folder_outlined,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'No documents uploaded yet.',
                      style: context.theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: CaregiverDashboardTheme.deepTeal,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...recentDocuments.asMap().entries.map((entry) {
              final index = entry.key;
              final document = entry.value;
              final isLast = index == recentDocuments.length - 1;
              final docColor = _getDocumentColor(context, document.type);
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
                child: _DocumentRow(
                  document: document,
                  accent: docColor,
                  onTap: () => context.push('/documents'),
                ),
              );
            }).toList(),
          if (documents.length > 4) ...[
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.push('/documents'),
                style: TextButton.styleFrom(
                  foregroundColor: CaregiverDashboardTheme.accentYellow,
                  textStyle: context.theme.typography.xs.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('View all documents'),
              ),
            ),
          ],
        ],
      ),
    );
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

class _DocumentRow extends StatelessWidget {
  final DocumentModel document;
  final Color accent;
  final VoidCallback onTap;

  const _DocumentRow({
    required this.document,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: CaregiverDashboardTheme.tintedCard(accent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: CaregiverDashboardTheme.iconBadge(accent),
                child: Icon(
                  _getDocumentIcon(document.type),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: CaregiverDashboardTheme.deepTeal,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      document.type.displayName,
                      style: context.theme.typography.xs.copyWith(
                        color: CaregiverDashboardTheme.deepTeal.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  textStyle: context.theme.typography.xs.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Open'),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            DateFormat('MMM d, yyyy').format(document.uploadDate),
            style: context.theme.typography.xs.copyWith(
              color: CaregiverDashboardTheme.deepTeal.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(DocumentType documentType) {
    switch (documentType) {
      case DocumentType.prescription:
        return Icons.medication;
      case DocumentType.labReport:
        return Icons.science;
      case DocumentType.xray:
      case DocumentType.scan:
        return Icons.medical_services;
      case DocumentType.discharge:
        return Icons.description;
      case DocumentType.insurance:
        return Icons.account_balance;
      case DocumentType.other:
        return Icons.description;
    }
  }
}


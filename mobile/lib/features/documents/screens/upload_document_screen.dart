import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/document_model.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/care_context_provider.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/document_picker_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/upload_options_bottom_sheet.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DocumentType _documentType = DocumentType.prescription;
  DocumentVisibility _visibility = DocumentVisibility.private;
  DocumentPickerResult? _selectedFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;
      if (user?.role == UserRole.caregiver) {
        context.read<CareContextProvider>().ensureLoaded();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _showFilePicker() async {
    UploadOptionsBottomSheet.show(context, (option) async {
      DocumentPickerResult? result;

      switch (option) {
        case UploadOption.camera:
          result = await DocumentPickerService.pickImageFromCamera(context);
          break;
        case UploadOption.gallery:
          result = await DocumentPickerService.pickImageFromGallery(context);
          break;
        case UploadOption.document:
          result = await DocumentPickerService.pickDocument(context);
          break;
      }

      if (result != null && mounted) {
        setState(() {
          _selectedFile = result;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.fileName} selected'),
            backgroundColor: AppTheme.getSuccessColor(context),
          ),
        );
      }
    });
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a file or photo'),
          backgroundColor: AppTheme.getWarningColor(context),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) {
      return;
    }

    String? elderUserId;
    if (user.role == UserRole.caregiver) {
      final careContext = context.read<CareContextProvider>();
      elderUserId = careContext.selectedElderId;
      if (elderUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Select a patient before uploading documents.'),
            backgroundColor: AppTheme.getWarningColor(context),
          ),
        );
        return;
      }
    }

    final documentProvider = context.read<DocumentProvider>();

    final success = await documentProvider.uploadDocument(
      filePath: _selectedFile!.filePath,
      title: _titleController.text.trim(),
      type: _documentType,
      visibility: _visibility,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      elderUserId: elderUserId,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Document uploaded successfully'),
            backgroundColor: AppTheme.getSuccessColor(context),
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to upload document'),
            backgroundColor: AppTheme.getErrorColor(context),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isCaregiver = user?.role == UserRole.caregiver;
    final careContext = isCaregiver
        ? context.watch<CareContextProvider>()
        : null;
    final hasAssignments =
        !isCaregiver || (careContext?.careRecipients.isNotEmpty ?? false);
    final isCareContextLoading = careContext?.isLoading ?? false;
    final careContextError = careContext?.error;
    final hasSelectedRecipient =
        !isCaregiver || careContext?.selectedElderId != null;

    final documentProvider = context.watch<DocumentProvider>();
    final isUploading = documentProvider.isLoading;

    Widget? caregiverNotice;
    if (isCaregiver) {
      if (isCareContextLoading && !hasAssignments) {
        caregiverNotice = const Center(child: CircularProgressIndicator());
      } else if (!hasAssignments) {
        caregiverNotice = _buildCaregiverNotice(
          context,
          icon: FIcons.users,
          title: 'No patients assigned yet',
          message:
              'You can upload documents once a patient has granted you access to their records.',
        );
      } else if (careContextError != null && !hasSelectedRecipient) {
        caregiverNotice = _buildCaregiverNotice(
          context,
          icon: FIcons.info,
          title: 'Unable to load patients',
          message: careContextError,
          onRetry: () => context.read<CareContextProvider>().ensureLoaded(),
        );
      } else if (!hasSelectedRecipient) {
        caregiverNotice = _buildCaregiverNotice(
          context,
          icon: FIcons.userSearch,
          title: 'Select a patient to continue',
          message:
              'Choose a patient from the dashboard to upload documents on their behalf.',
        );
      }
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.pop();
        }
      },
      child: FScaffold(
        header: FHeader.nested(
          title: const Text('Upload Document'),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: SafeArea(
          child: caregiverNotice != null
              ? caregiverNotice
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_selectedFile == null) ...[
                          FButton(
                            style: FButtonStyle.outline(),
                            onPress: isUploading ? null : _showFilePicker,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(FIcons.upload),
                                const SizedBox(width: 8),
                                const Text('Select Document or Photo'),
                              ],
                            ),
                          ),
                        ] else ...[
                          FCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: _selectedFile!.isImage
                                              ? context.theme.colors.primary
                                                    .withOpacity(0.1)
                                              : AppTheme.getWarningColor(
                                                  context,
                                                ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          _selectedFile!.isImage
                                              ? FIcons.image
                                              : DocumentPickerService.getFileIcon(
                                                  _selectedFile!.fileExtension,
                                                ),
                                          color: _selectedFile!.isImage
                                              ? context.theme.colors.primary
                                              : AppTheme.getWarningColor(
                                                  context,
                                                ),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedFile!.fileName,
                                              style: context.theme.typography.sm
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              DocumentPickerService.formatFileSize(
                                                _selectedFile!.fileSize,
                                              ),
                                              style: context.theme.typography.xs
                                                  .copyWith(
                                                    color: context
                                                        .theme
                                                        .colors
                                                        .mutedForeground,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: isUploading
                                            ? null
                                            : () {
                                                setState(() {
                                                  _selectedFile = null;
                                                });
                                              },
                                        icon: const Icon(FIcons.x, size: 16),
                                        style: IconButton.styleFrom(
                                          backgroundColor: context
                                              .theme
                                              .colors
                                              .destructive
                                              .withOpacity(0.1),
                                          foregroundColor:
                                              context.theme.colors.destructive,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FButton(
                            style: FButtonStyle.outline(),
                            onPress: isUploading ? null : _showFilePicker,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(FIcons.upload),
                                const SizedBox(width: 8),
                                const Text('Change File'),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FTextField(
                          controller: _titleController,
                          label: const Text('Document Title'),
                          hint: 'e.g., Blood Test Results',
                        ),
                        const SizedBox(height: 16),
                        FCard(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Document Type',
                                  style: context.theme.typography.sm.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Material(
                                  child: DropdownButton<DocumentType>(
                                    value: _documentType,
                                    isExpanded: true,
                                    items: DocumentType.values.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(type.displayName),
                                      );
                                    }).toList(),
                                    onChanged: isUploading
                                        ? null
                                        : (value) {
                                            if (value != null) {
                                              setState(() {
                                                _documentType = value;
                                              });
                                            }
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FTextField(
                          controller: _descriptionController,
                          label: const Text('Description (Optional)'),
                          hint: 'Additional details',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        FCard(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Visibility',
                                  style: context.theme.typography.sm.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Material(
                                  child: Column(
                                    children: [
                                      RadioListTile<DocumentVisibility>(
                                        title: const Text('Private (Only me)'),
                                        value: DocumentVisibility.private,
                                        groupValue: _visibility,
                                        onChanged: isUploading
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  _visibility = value!;
                                                });
                                              },
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      RadioListTile<DocumentVisibility>(
                                        title: const Text(
                                          'Shared with caregivers',
                                        ),
                                        value: DocumentVisibility
                                            .sharedWithCaregiver,
                                        groupValue: _visibility,
                                        onChanged: isUploading
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  _visibility = value!;
                                                });
                                              },
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      RadioListTile<DocumentVisibility>(
                                        title: const Text(
                                          'Public (Admin visible)',
                                        ),
                                        value: DocumentVisibility.public,
                                        groupValue: _visibility,
                                        onChanged: isUploading
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  _visibility = value!;
                                                });
                                              },
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FButton(
                          onPress: isUploading ? null : _handleUpload,
                          child: isUploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Upload Document'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
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
}

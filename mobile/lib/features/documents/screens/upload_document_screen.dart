import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/document_model.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/providers/auth_provider.dart';
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
    final userId = authProvider.currentUser!.id;

    final document = DocumentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      type: _documentType,
      filePath: _selectedFile!.filePath,
      uploadDate: DateTime.now(),
      visibility: _visibility,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      userId: userId,
    );

    final success = await context.read<DocumentProvider>().uploadDocument(
      document,
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // File picker section
                  if (_selectedFile == null) ...[
                    FButton(
                      style: FButtonStyle.outline(),
                      onPress: _showFilePicker,
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
                    // Selected file preview
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
                                        ? context.theme.colors.primary.withOpacity(0.1)
                                        : AppTheme.getWarningColor(context).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _selectedFile!.isImage
                                        ? FIcons.image
                                        : DocumentPickerService.getFileIcon(
                                            _selectedFile!.fileExtension,
                                          ),
                                    color: _selectedFile!.isImage
                                        ? context.theme.colors.primary
                                        : AppTheme.getWarningColor(context),
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
                                  onPressed: () {
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
                      onPress: _showFilePicker,
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

                  // Document type dropdown
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
                              onChanged: (value) {
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

                  // Visibility options
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
                                  onChanged: (value) {
                                    setState(() {
                                      _visibility = value!;
                                    });
                                  },
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                RadioListTile<DocumentVisibility>(
                                  title: const Text('Shared with caregivers'),
                                  value: DocumentVisibility.sharedWithCaregiver,
                                  groupValue: _visibility,
                                  onChanged: (value) {
                                    setState(() {
                                      _visibility = value!;
                                    });
                                  },
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                RadioListTile<DocumentVisibility>(
                                  title: const Text('Public (Admin visible)'),
                                  value: DocumentVisibility.public,
                                  groupValue: _visibility,
                                  onChanged: (value) {
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
                    onPress: _handleUpload,
                    child: const Text('Upload Document'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

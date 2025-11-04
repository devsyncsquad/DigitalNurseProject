import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

enum UploadOption { camera, gallery, document }

class UploadOptionsBottomSheet extends StatelessWidget {
  final Function(UploadOption) onOptionSelected;

  const UploadOptionsBottomSheet({super.key, required this.onOptionSelected});

  static void show(
    BuildContext context,
    Function(UploadOption) onOptionSelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          UploadOptionsBottomSheet(onOptionSelected: onOptionSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.theme.colors.mutedForeground,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Select Document or Photo',
                style: context.theme.typography.lg.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to add your medical document',
                style: context.theme.typography.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Options
              FCard(
                child: Column(
                  children: [
                    _buildOptionTile(
                      context,
                      icon: FIcons.camera,
                      title: 'Take Photo',
                      subtitle: 'Use camera to capture document',
                      onTap: () {
                        Navigator.of(context).pop();
                        onOptionSelected(UploadOption.camera);
                      },
                    ),
                    const Divider(height: 1),
                    _buildOptionTile(
                      context,
                      icon: FIcons.image,
                      title: 'Choose from Gallery',
                      subtitle: 'Select photo from your gallery',
                      onTap: () {
                        Navigator.of(context).pop();
                        onOptionSelected(UploadOption.gallery);
                      },
                    ),
                    const Divider(height: 1),
                    _buildOptionTile(
                      context,
                      icon: FIcons.fileText,
                      title: 'Select File (PDF/Documents)',
                      subtitle: 'Choose PDF or document files',
                      onTap: () {
                        Navigator.of(context).pop();
                        onOptionSelected(UploadOption.document);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.theme.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: context.theme.colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.theme.typography.sm.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.theme.typography.xs.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FIcons.chevronRight,
                color: context.theme.colors.mutedForeground,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

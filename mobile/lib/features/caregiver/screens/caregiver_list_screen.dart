import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/caregiver_provider.dart';
import '../../../core/models/caregiver_model.dart';

class CaregiverListScreen extends StatelessWidget {
  const CaregiverListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caregiverProvider = context.watch<CaregiverProvider>();
    final caregivers = caregiverProvider.caregivers;

    return FScaffold(
      header: FHeader(
        title: const Text('My Caregivers'),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FIcons.plus),
            onPress: () => context.push('/caregiver/add'),
          ),
        ],
      ),
      child: caregivers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FIcons.users,
                    size: 64,
                    color: context.theme.colors.mutedForeground,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No caregivers added yet',
                    style: context.theme.typography.lg,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a caregiver to help manage your care',
                    style: context.theme.typography.sm,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FButton(
                    onPress: () => context.push('/caregiver/add'),
                    child: const Text('Add Caregiver'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: caregivers.length,
              itemBuilder: (context, index) {
                final caregiver = caregivers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: context.theme.colors.primary
                                .withValues(alpha: 0.2),
                            child: Text(
                              caregiver.name[0].toUpperCase(),
                              style: context.theme.typography.lg.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.theme.colors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  caregiver.name,
                                  style: context.theme.typography.base.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  caregiver.phone,
                                  style: context.theme.typography.sm,
                                ),
                                if (caregiver.relationship != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    caregiver.relationship!,
                                    style: context.theme.typography.xs.copyWith(
                                      color:
                                          context.theme.colors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          FBadge(child: Text(_getStatusText(caregiver.status))),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _getStatusText(CaregiverStatus status) {
    switch (status) {
      case CaregiverStatus.pending:
        return 'Pending';
      case CaregiverStatus.accepted:
        return 'Active';
      case CaregiverStatus.declined:
        return 'Declined';
    }
  }
}

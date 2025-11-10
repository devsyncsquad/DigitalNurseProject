import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/models/notification_model.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<NotificationProvider>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications;

    return FScaffold(
      header: FHeader.nested(
        title: const Text('Notifications'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: notificationProvider.isLoading && notifications.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FIcons.bellOff,
                          size: 64,
                          color: context.theme.colors.mutedForeground,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'You’re all caught up!',
                          style: context.theme.typography.lg,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'We’ll let you know when there’s something new to review.',
                            style: context.theme.typography.sm.copyWith(
                              color: context.theme.colors.mutedForeground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (_, index) {
                    final notification = notifications[index];
                    final timestamp = DateFormat(
                      'MMM d, y • h:mm a',
                    ).format(notification.timestamp);
                    final isUnread = !notification.isRead;

                    return Dismissible(
                      key: Key(notification.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        notificationProvider.deleteNotification(
                          notification.id,
                        );
                      },
                      background: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.getErrorColor(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(FIcons.trash, color: Colors.white),
                      ),
                      child: FCard(
                        child: ListTile(
                          onTap: () {
                            if (isUnread) {
                              notificationProvider.markAsRead(notification.id);
                            }
                          },
                          leading: Icon(
                            _resolveIcon(notification.type),
                            color: isUnread
                                ? context.theme.colors.primary
                                : context.theme.colors.mutedForeground,
                          ),
                          title: Text(
                            notification.title,
                            style: context.theme.typography.sm.copyWith(
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                notification.body,
                                style: context.theme.typography.xs.copyWith(
                                  color: context.theme.colors.mutedForeground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timestamp,
                                style: context.theme.typography.xs.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: context.theme.colors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                          trailing: isUnread
                              ? Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: context.theme.colors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: notifications.length,
                ),
        ),
      ),
    );
  }

  IconData _resolveIcon(NotificationType type) {
    switch (type) {
      case NotificationType.medicineReminder:
      case NotificationType.missedDose:
        return FIcons.pill;
      case NotificationType.healthAlert:
        return FIcons.activity;
      case NotificationType.caregiverInvitation:
        return FIcons.users;
      case NotificationType.general:
        return FIcons.bell;
    }
  }
}

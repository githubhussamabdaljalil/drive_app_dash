import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/constants/app_routes.dart';

import 'package:driver_app_dash/features/manager_notifications/data/models/manager_notification_model.dart';
import 'package:driver_app_dash/features/manager_notifications/presentation/cubit/manager_notification_cubit.dart';

class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: AppRoutes.notifications,
      pageTitle: 'الإشعارات',
      body: const _NotificationsBody(),
    );
  }
}

class _NotificationsBody extends StatefulWidget {
  const _NotificationsBody();

  @override
  State<_NotificationsBody> createState() => _NotificationsBodyState();
}

class _NotificationsBodyState extends State<_NotificationsBody> {
  @override
  void initState() {
    super.initState();
    context.read<ManagerNotificationCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManagerNotificationCubit, ManagerNotificationState>(
      listener: (ctx, state) {
        if (state is ManagerNotificationError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      builder: (ctx, state) {
        final notifications = switch (state) {
          ManagerNotificationLoaded() => state.notifications,
          ManagerNotificationError() => state.notifications ?? [],
          _ => <ManagerNotificationModel>[],
        };
        final unreadCount = notifications.where((n) => !n.isRead).length;
        final isLoading = state is ManagerNotificationLoading;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('الإشعارات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 3),
                        Text(unreadCount > 0 ? '$unreadCount إشعار غير مقروء' : 'كل الإشعارات مقروءة',
                            style: TextStyle(fontSize: 13, color: unreadCount > 0 ? AppColors.primary : AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.read<ManagerNotificationCubit>().load(),
                    icon: const Icon(Icons.refresh, color: AppColors.primary),
                    tooltip: 'تحديث',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : notifications.isEmpty
                        ? const _EmptyState()
                        : ListView.separated(
                            itemCount: notifications.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final n = notifications[i];
                              return _NotificationCard(
                                notification: n,
                                onTap: n.isRead ? null : () => ctx.read<ManagerNotificationCubit>().markRead(n.id),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final ManagerNotificationModel notification;
  final VoidCallback? onTap;
  const _NotificationCard({required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isExpired = notification.event == 'expired';
    final (title, icon, color) = switch (notification.event) {
      'expiring_soon' => ('اقتراب انتهاء اشتراك الشركة', Icons.event_busy_outlined, AppColors.warning),
      'expired' => ('انتهى اشتراك الشركة', Icons.cancel_outlined, AppColors.danger),
      _ => (notification.type, Icons.notifications_outlined, AppColors.textHint),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.surface : (isExpired ? AppColors.dangerSurface : AppColors.warningSurface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: notification.isRead ? AppColors.border : color.withOpacity(.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(title,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ),
                    if (!notification.isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  ]),
                  if (notification.createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(notification.createdAt!, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.notifications_none_outlined, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('لا توجد إشعارات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ]),
      );
}

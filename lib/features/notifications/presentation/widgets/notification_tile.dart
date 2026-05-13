import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_type.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismissed,
  });

  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;

  IconData get _icon => switch (notification.type) {
        AppNotificationType.budgetAlert => Icons.warning_amber_rounded,
        AppNotificationType.budgetExceeded => Icons.error_outline,
        AppNotificationType.info => Icons.info_outline,
      };

  Color get _color => switch (notification.type) {
        AppNotificationType.budgetAlert => AppColors.warning,
        AppNotificationType.budgetExceeded => AppColors.expense,
        AppNotificationType.info => AppColors.info,
      };

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.expense.withValues(alpha: 0.15),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: const Icon(Icons.delete_outline, color: AppColors.expense),
      ),
      onDismissed: (_) => onDismissed?.call(),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(_icon, color: _color, size: 22),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(notification.title,
                              style: context.text.titleSmall),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(notification.body, style: context.text.bodyMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      Formatters.relative(notification.createdAt),
                      style: context.text.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

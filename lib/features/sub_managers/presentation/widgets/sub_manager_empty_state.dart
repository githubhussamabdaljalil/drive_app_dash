import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

class SubManagerEmptyState extends StatelessWidget {
  final VoidCallback? onAdd;
  const SubManagerEmptyState({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.manage_accounts_outlined, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('لا يوجد مدراء فرعيون بعد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('فوّض جزءاً من الصلاحيات لمدير فرعي', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          if (onAdd != null) AppButton(label: 'إضافة مدير فرعي', icon: Icons.add, width: 190, height: 40, onPressed: onAdd),
        ]),
      );
}

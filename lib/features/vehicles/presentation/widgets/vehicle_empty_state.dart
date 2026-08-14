import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

class VehicleEmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const VehicleEmptyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.local_shipping_outlined, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('لا توجد مركبات بعد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('ابدأ بإضافة أول مركبة في الأسطول', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          AppButton(label: 'إضافة مركبة', icon: Icons.add, width: 160, height: 40, onPressed: onAdd),
        ]),
      );
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// One-time temporary password reveal, used after creating a driver or
/// resetting one's password. Shown once — the API never returns it again.
void showTempPasswordDialog(BuildContext context, {required String driverName, required String tempPassword}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Row(children: [
        Icon(Icons.vpn_key_outlined, color: AppColors.success, size: 22),
        SizedBox(width: 8),
        Text('كلمة المرور المؤقتة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('سلّم كلمة المرور هذه لـ "$driverName" — لن تظهر مرة أخرى:',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
            child: SelectableText(
              tempPassword.isEmpty ? '(فارغة — راجع استجابة الخادم)' : tempPassword,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 1),
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('تم')),
      ],
    ),
  );
}

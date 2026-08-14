import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Shown when the permission catalog failed to load — this is the state
/// that used to leave the "Add sub-manager" button permanently disabled
/// with no way to recover except restarting the app. Now it explains why
/// and offers a one-tap retry.
class SubManagerRetryBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const SubManagerRetryBanner({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withOpacity(.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'تعذر تحميل قائمة الصلاحيات، لذلك زر "إضافة مدير فرعي" غير متاح مؤقتاً. ($message)',
            style: const TextStyle(fontSize: 12, color: AppColors.danger),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          child: const Text('إعادة المحاولة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

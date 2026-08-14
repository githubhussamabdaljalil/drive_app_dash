import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Shows the ready-to-use, filter-aware export URL (GET
/// /admin/manager/reports/export) for the manager to open or copy.
///
/// There's no confirmed URL-launcher / file-download package wired into
/// this project, so rather than fake a "downloading..." spinner that does
/// nothing, this gives the real authenticated-download link honestly.
/// Once url_launcher (or similar) is added, swap the "نسخ الرابط" button
/// for a direct launchUrl call — everything else here stays the same.
void showExportLinkDialog(BuildContext context, {required String url, required String format}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text('تصدير التقرير (${format.toUpperCase()})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('انسخ الرابط وافتحه بالمتصفح لتنزيل الملف (يستخدم نفس جلسة الدخول الحالية):',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
            child: SelectableText(url, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ElevatedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: url));
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('تم نسخ الرابط'), backgroundColor: AppColors.success),
            );
          },
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('نسخ الرابط'),
        ),
      ],
    ),
  );
}

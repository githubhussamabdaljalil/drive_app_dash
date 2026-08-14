import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/manager_reports_model.dart';

/// Renders a "total + per-status counts" card for SOS events or
/// destinations — the by_status map comes straight from the API, so any
/// status key the backend sends shows up automatically (nothing hardcoded).
class ReportStatusBreakdownCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final ReportStatusBreakdown data;

  const ReportStatusBreakdownCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Spacer(),
            Text(data.total.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          ]),
          const SizedBox(height: 12),
          if (data.byStatus.isEmpty)
            const Text('لا توجد بيانات لعرضها ضمن الفترة المحددة', style: TextStyle(fontSize: 12, color: AppColors.textHint))
          else
            ...data.byStatus.entries.map((e) => _StatusRow(status: e.key, count: e.value, total: data.total, color: color)),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String status;
  final int count;
  final int total;
  final Color color;
  const _StatusRow({required this.status, required this.count, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(status, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
            Text(count.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

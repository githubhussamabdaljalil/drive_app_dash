import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/manager_reports_model.dart';

/// Overview stat cards — every number here comes straight from
/// ManagerReportsModel (GET /admin/manager/reports), nothing hardcoded.
class ManagerReportsOverviewRow extends StatelessWidget {
  final ManagerReportsModel reports;
  const ManagerReportsOverviewRow({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _StatCard(
          icon: Icons.directions_car_outlined,
          label: 'إجمالي المركبات',
          value: reports.vehiclesCount.toString(),
          color: AppColors.primary,
        ),
        _StatCard(
          icon: Icons.check_circle_outline,
          label: 'مركبات نشطة',
          value: reports.activeVehiclesCount.toString(),
          color: AppColors.success,
        ),
        _StatCard(
          icon: Icons.people_outline,
          label: 'السائقون',
          value: reports.driversCount.toString(),
          color: const Color(0xFF7B1FA2),
        ),
        _StatCard(
          icon: Icons.group_outlined,
          label: 'المدراء الفرعيون',
          value: reports.managersCount.toString(),
          color: AppColors.warning,
        ),
        _StatCard(
          icon: Icons.access_time_outlined,
          label: 'سجلات الحضور',
          value: reports.attendanceCount.toString(),
          color: AppColors.primary,
        ),
        _StatCard(
          icon: Icons.card_giftcard_outlined,
          label: 'رموز الضيوف الصادرة',
          value: reports.guestCodesIssuedCount.toString(),
          color: const Color(0xFF7B1FA2),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

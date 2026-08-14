import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/vehicle_model.dart';

class VehicleTable extends StatelessWidget {
  final List<VehicleModel> vehicles;
  final bool isSubmitting;
  final void Function(VehicleModel) onEdit;
  final void Function(VehicleModel) onDelete;

  const VehicleTable({
    super.key,
    required this.vehicles,
    required this.isSubmitting,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          const _TableHeader(),
          Expanded(
            child: ListView.separated(
              itemCount: vehicles.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (_, i) {
                final v = vehicles[i];
                return Opacity(
                  opacity: isSubmitting ? .6 : 1,
                  child: _VehicleRow(vehicle: v, onEdit: () => onEdit(v), onDelete: () => onDelete(v)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: const Row(children: [
        Expanded(flex: 3, child: _HeaderCell('رقم اللوحة')),
        Expanded(flex: 2, child: _HeaderCell('النوع')),
        Expanded(flex: 2, child: _HeaderCell('الموديل')),
        Expanded(flex: 2, child: _HeaderCell('السائق المسند', centered: true)),
        Expanded(flex: 2, child: _HeaderCell('الحالة', centered: true)),
        SizedBox(width: 90, child: _HeaderCell('إجراءات', centered: true)),
      ]),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _VehicleRow({required this.vehicle, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final v = vehicle;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        Expanded(flex: 3, child: Text(v.plateNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
        Expanded(flex: 2, child: Text(v.type ?? '—', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        Expanded(flex: 2, child: Text(v.model ?? '—', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        Expanded(
          flex: 2,
          child: Text(v.assignedDriverName ?? '—',
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ),
        Expanded(flex: 2, child: Center(child: _StatusChip(status: v.status))),
        SizedBox(
          width: 90,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _ActionBtn(icon: Icons.edit_outlined, color: AppColors.primary, tooltip: 'تعديل', onTap: onEdit),
            const SizedBox(width: 6),
            _ActionBtn(icon: Icons.delete_outline, color: AppColors.danger, tooltip: 'حذف', onTap: onDelete),
          ]),
        ),
      ]),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final bool centered;
  const _HeaderCell(this.label, {this.centered = false});

  @override
  Widget build(BuildContext context) => Text(
        label,
        textAlign: centered ? TextAlign.center : TextAlign.start,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      );
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'active' => ('نشطة', AppColors.success),
      'maintenance' => ('صيانة', AppColors.warning),
      'out_of_service' => ('خارج الخدمة', AppColors.danger),
      _ => ('غير نشطة', AppColors.textHint),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(.08), borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      );
}

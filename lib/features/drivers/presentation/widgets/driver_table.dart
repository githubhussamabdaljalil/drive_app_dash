import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/driver_model.dart';

class DriverTable extends StatelessWidget {
  final List<DriverModel> drivers;
  final bool isSubmitting;
  final void Function(DriverModel) onEdit;
  final void Function(DriverModel) onDelete;
  final void Function(DriverModel) onResetPassword;

  const DriverTable({
    super.key,
    required this.drivers,
    required this.isSubmitting,
    required this.onEdit,
    required this.onDelete,
    required this.onResetPassword,
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
              itemCount: drivers.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (_, i) {
                final d = drivers[i];
                return Opacity(
                  opacity: isSubmitting ? .6 : 1,
                  child: _DriverRow(
                    driver: d,
                    onEdit: () => onEdit(d),
                    onDelete: () => onDelete(d),
                    onResetPassword: () => onResetPassword(d),
                  ),
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
        Expanded(flex: 3, child: _HeaderCell('السائق')),
        Expanded(flex: 2, child: _HeaderCell('الهاتف')),
        Expanded(flex: 2, child: _HeaderCell('المركبة المرتبطة', centered: true)),
        Expanded(flex: 2, child: _HeaderCell('الحالة', centered: true)),
        SizedBox(width: 130, child: _HeaderCell('إجراءات', centered: true)),
      ]),
    );
  }
}

class _DriverRow extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onResetPassword;

  const _DriverRow({required this.driver, required this.onEdit, required this.onDelete, required this.onResetPassword});

  @override
  Widget build(BuildContext context) {
    final d = driver;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              if (d.email != null && d.email!.isNotEmpty)
                Text(d.email!, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
            ],
          ),
        ),
        Expanded(flex: 2, child: Text(d.phone, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        Expanded(
          flex: 2,
          child: Text(d.assignedVehiclePlate ?? '—',
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ),
        Expanded(flex: 2, child: Center(child: _StatusChip(active: d.isActive))),
        SizedBox(
          width: 130,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _ActionBtn(icon: Icons.edit_outlined, color: AppColors.primary, tooltip: 'تعديل', onTap: onEdit),
            const SizedBox(width: 6),
            _ActionBtn(icon: Icons.vpn_key_outlined, color: AppColors.warning, tooltip: 'إعادة تعيين كلمة المرور', onTap: onResetPassword),
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
  final bool active;
  const _StatusChip({required this.active});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.successSurface : AppColors.dangerSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? AppColors.success : AppColors.danger)),
          const SizedBox(width: 5),
          Text(active ? 'نشط' : 'غير نشط',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? AppColors.success : AppColors.danger)),
        ]),
      );
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

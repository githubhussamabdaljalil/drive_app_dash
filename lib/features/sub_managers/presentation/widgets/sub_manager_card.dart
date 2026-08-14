import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/sub_manager_model.dart';

/// A single sub-manager row: name/contact/permission chips + actions.
class SubManagerCard extends StatelessWidget {
  final SubManagerModel subManager;
  final VoidCallback onEditInfo;
  final VoidCallback onEditPermissions;
  final VoidCallback onDelete;

  const SubManagerCard({
    super.key,
    required this.subManager,
    required this.onEditInfo,
    required this.onEditPermissions,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.manage_accounts_outlined, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: _SubManagerInfo(subManager: subManager)),
          Column(children: [
            _ActionBtn(icon: Icons.edit_outlined, color: AppColors.primary, tooltip: 'تعديل البيانات', onTap: onEditInfo),
            const SizedBox(height: 6),
            _ActionBtn(icon: Icons.vpn_key_outlined, color: AppColors.warning, tooltip: 'تعديل الصلاحيات', onTap: onEditPermissions),
            const SizedBox(height: 6),
            _ActionBtn(icon: Icons.delete_outline, color: AppColors.danger, tooltip: 'حذف', onTap: onDelete),
          ]),
        ],
      ),
    );
  }
}

class _SubManagerInfo extends StatelessWidget {
  final SubManagerModel subManager;
  const _SubManagerInfo({required this.subManager});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subManager.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(subManager.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        if (subManager.phone != null) Text(subManager.phone!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: subManager.permissions.isEmpty
              ? [const Text('لا صلاحيات', style: TextStyle(fontSize: 11, color: AppColors.textHint))]
              : subManager.permissions.map((p) => _PermissionChip(label: p)).toList(),
        ),
      ],
    );
  }
}

class _PermissionChip extends StatelessWidget {
  final String label;
  const _PermissionChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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

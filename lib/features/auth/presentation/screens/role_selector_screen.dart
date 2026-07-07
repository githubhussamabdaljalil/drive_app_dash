import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/web_auth_layout.dart';
import '../../../../core/constants/app_routes.dart';

/// Step 1: user picks their role before showing login form
class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WebAuthLayout(
      cardWidth: 460,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const Text('أهلاً بك في VTFMS',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('اختر دورك للمتابعة',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 32),

        _RoleCard(
          role: 'owner',
          icon: Icons.admin_panel_settings_outlined,
          title: 'المالك',
          subtitle: 'إدارة الشركات، التقارير، الصلاحيات الكاملة',
          color: const Color(0xFF7B1FA2),
          onTap: () => Navigator.pushNamed(context, AppRoutes.login, arguments: 'owner'),
        ),
        const SizedBox(height: 12),
        _RoleCard(
          role: 'manager',
          icon: Icons.manage_accounts_outlined,
          title: 'المدير',
          subtitle: 'إدارة المركبات، السائقين، الوجهات، التقارير',
          color: AppColors.primary,
          onTap: () => Navigator.pushNamed(context, AppRoutes.login, arguments: 'manager'),
        ),
        const SizedBox(height: 12),
        _RoleCard(
          role: 'driver',
          icon: Icons.drive_eta_outlined,
          title: 'السائق',
          subtitle: 'الوجهات، الحضور، ربط المركبة، SOS',
          color: AppColors.success,
          onTap: () => Navigator.pushNamed(context, AppRoutes.login, arguments: 'driver'),
        ),

        const SizedBox(height: 28),
        const Text('VTFMS v1.0.0',
            style: TextStyle(fontSize: 11, color: AppColors.textHint)),
      ]),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String role;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({required this.role, required this.icon, required this.title,
      required this.subtitle, required this.color, required this.onTap});

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _hovered ? widget.color.withOpacity(.05) : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? widget.color : AppColors.border,
              width: _hovered ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, color: widget.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                      color: _hovered ? widget.color : AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(widget.subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            Icon(Icons.chevron_right, color: _hovered ? widget.color : AppColors.textHint, size: 20),
          ]),
        ),
      ),
    );
  }
}

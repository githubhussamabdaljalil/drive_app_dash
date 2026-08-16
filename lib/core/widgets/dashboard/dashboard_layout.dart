import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../services/storage/local_storage_service.dart';

import '../../../features/auth/presentation/cubit/auth_cubit.dart';

/// DashboardLayout
///
/// Shared dashboard layout for:
/// - owner
/// - manager
///
/// The user's role is obtained from LocalStorage after successful login.
/// The role itself is determined by the backend.
class DashboardLayout extends StatelessWidget {
  final Widget body;
  final String activeRoute;
  final String pageTitle;

  const DashboardLayout({
    super.key,
    required this.body,
    required this.activeRoute,
    required this.pageTitle,
  });

  @override
  Widget build(BuildContext context) {
    final role =
        LocalStorageService.instance.getRole() ?? 'manager';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _Sidebar(
            role: role,
            activeRoute: activeRoute,
          ),

          Expanded(
            child: Column(
              children: [
                _TopBar(
                  title: pageTitle,
                  role: role,
                ),
                Expanded(
                  child: body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SIDEBAR
// ============================================================================

class _Sidebar extends StatefulWidget {
  final String role;
  final String activeRoute;

  const _Sidebar({
    required this.role,
    required this.activeRoute,
  });

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    final activeRoute = widget.activeRoute;

    final name =
        LocalStorageService.instance.getName() ?? '';

    final firstLetter =
        name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      width: 240,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          // ================================================================
          // LOGO
          // ================================================================

          Container(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              16,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'VTFMS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: .5,
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            color: Color(0xFF1E2D4A),
            height: 1,
          ),

          const SizedBox(height: 8),

          // ================================================================
          // USER INFO
          // ================================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.sidebarHover,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),

                        Text(
                          _roleLabel(role),
                          style: const TextStyle(
                            color: AppColors.sidebarText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ================================================================
          // NAVIGATION
          // ================================================================

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _navItems(
                role,
                context,
                activeRoute,
                _isLoggingOut,
              ),
            ),
          ),

          const Divider(
            color: Color(0xFF1E2D4A),
            height: 1,
          ),

          // ================================================================
          // LOGOUT
          // ================================================================

          _NavItem(
            icon: Icons.logout,
            label: 'تسجيل الخروج',
            isActive: false,
            isLoading: _isLoggingOut,
            color: AppColors.danger,
            onTap: _isLoggingOut
                ? () {}
                : () async {
                    setState(() => _isLoggingOut = true);

                    // نضمن إن Flutter يرسم الـ loading قبل ما نكمل
                    await Future.delayed(const Duration(milliseconds: 50));

                    await context.read<AuthCubit>().logout();

                    if (!context.mounted) return;

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ========================================================================
  // ROLE LABEL
  // ========================================================================

  String _roleLabel(String role) {
    return switch (role) {
      'owner' => 'المالك',
      'manager' => 'المدير',
      _ => 'المستخدم',
    };
  }

  // ========================================================================
  // NAVIGATION ITEMS
  // ========================================================================

  List<Widget> _navItems(
    String role,
    BuildContext context,
    String active,
    bool disabled,
  ) {
    final items = <_NavDef>[];

    // ======================================================================
    // OWNER
    // ======================================================================

    if (role == 'owner') {
      items.addAll([
        _NavDef(
          Icons.dashboard_outlined,
          'لوحة التحكم',
          AppRoutes.adminDashboard,
        ),

        _NavDef(
          Icons.business_outlined,
          'الشركات',
          AppRoutes.companies,
        ),

        _NavDef(
          Icons.bar_chart_outlined,
          'التقارير',
          AppRoutes.reports,
        ),

        _NavDef(
          Icons.person_outline,
          'الملف الشخصي',
          AppRoutes.profile,
        ),
      ]);
    }

    // ======================================================================
    // MANAGER
    // ======================================================================

    else if (role == 'manager') {
      items.addAll([
        _NavDef(
          Icons.dashboard_outlined,
          'لوحة التحكم',
          AppRoutes.adminDashboard,
        ),

        _NavDef(
          Icons.directions_car_outlined,
          'المركبات',
          AppRoutes.vehicles,
        ),

        _NavDef(
          Icons.people_outline,
          'السائقون',
          AppRoutes.drivers,
        ),

        _NavDef(
          Icons.navigation_outlined,
          'الوجهات',
          AppRoutes.destinations,
        ),

        _NavDef(
          Icons.map_outlined,
          'التتبع المباشر',
          AppRoutes.tracking,
        ),

        _NavDef(
          Icons.warning_amber_outlined,
          'أحداث SOS',
          AppRoutes.sosEvents,
        ),

        _NavDef(
          Icons.history_outlined,
          'سجل المسارات',
          AppRoutes.routeHistory,
        ),

        _NavDef(
          Icons.qr_code_outlined,
          'رموز QR',
          AppRoutes.qrCodes,
        ),

        _NavDef(
          Icons.group_outlined,
          'المدراء الفرعيون',
          AppRoutes.subManagers,
        ),

        _NavDef(
          Icons.card_giftcard_outlined,
          'رموز الضيوف',
          AppRoutes.guestCodes,
        ),

        _NavDef(
          Icons.notifications_outlined,
          'الإشعارات',
          AppRoutes.notifications,
        ),

        _NavDef(
          Icons.bar_chart_outlined,
          'التقارير',
          AppRoutes.reports,
        ),

        _NavDef(
          Icons.person_outline,
          'الملف الشخصي',
          AppRoutes.profile,
        ),
      ]);
    }

    final sectionLabel =
        role == 'owner'
            ? 'إدارة المنصة'
            : 'إدارة الأسطول';

    return [
      _SectionLabel(sectionLabel),

      ...items.map(
        (item) => _NavItem(
          icon: item.icon,
          label: item.label,
          isActive: active == item.route,
          onTap: () {
            if (disabled || active == item.route) return;

            Navigator.pushNamedAndRemoveUntil(
              context,
              item.route,
              (route) => false,
            );
          },
        ),
      ),
    ];
  }
}

// ============================================================================
// NAVIGATION DEFINITION
// ============================================================================

class _NavDef {
  final IconData icon;
  final String label;
  final String route;

  const _NavDef(
    this.icon,
    this.label,
    this.route,
  );
}

// ============================================================================
// SECTION LABEL
// ============================================================================

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        4,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.sidebarText,
          letterSpacing: .8,
        ),
      ),
    );
  }
}

// ============================================================================
// NAV ITEM
// ============================================================================

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isLoading;
  final Color? color;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.isLoading = false,
    this.color,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor =
        widget.color ??
        AppColors.sidebarTextActive;

    final bg = widget.isActive
        ? AppColors.sidebarActive
        : _hovered
            ? AppColors.sidebarHover
            : Colors.transparent;

    final fg = widget.isActive || _hovered
        ? activeColor
        : AppColors.sidebarText;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 120,
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: fg,
                size: 19,
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: fg,
                    fontWeight: widget.isActive
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),

              if (widget.isLoading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: widget.color ?? AppColors.sidebarTextActive,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TOP BAR
// ============================================================================

class _TopBar extends StatelessWidget {
  final String title;
  final String role;

  const _TopBar({
    required this.title,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        LocalStorageService.instance.getName() ?? '';

    final firstLetter =
        name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const Spacer(),

          if (role != 'owner')
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: () {},
            ),

          const SizedBox(width: 4),

          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Text(
              firstLetter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
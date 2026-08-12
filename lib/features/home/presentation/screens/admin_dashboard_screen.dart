import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/services/storage/local_storage_service.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../owner/presentation/cubit/owner_statistics_cubit.dart';
import '../../../owner/data/models/owner_statistics_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OwnerStatisticsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: AppRoutes.adminDashboard,
      pageTitle: 'لوحة التحكم',
      body: const _DashboardBody(),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final name = LocalStorageService.instance.getName() ?? 'المالك';
    final role = LocalStorageService.instance.getRole() ?? 'owner';
    final isOwner = role == 'owner';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome banner ───────────────────────────────────────────
          _WelcomeBanner(name: name, role: role, isOwner: isOwner),
          const SizedBox(height: 28),

          // ── Stats ────────────────────────────────────────────────────
          if (isOwner) ...[
            const _SectionTitle('نظرة عامة على المنصة'),
            const SizedBox(height: 14),
            BlocBuilder<OwnerStatisticsCubit, OwnerStatisticsState>(
              builder: (context, state) {
                if (state is OwnerStatisticsLoading) {
                  return const _LoadingStatsRow();
                } else if (state is OwnerStatisticsError) {
                  return _ErrorCard(message: state.message);
                } else if (state is OwnerStatisticsLoaded) {
                  return _OwnerStatsRow(statistics: state.statistics);
                }
                return const _OwnerStatsRow();
              },
            ),
            const SizedBox(height: 28),
          ],

          // ── Quick actions ────────────────────────────────────────────
          const _SectionTitle('الإجراءات السريعة'),
          const SizedBox(height: 14),
          _QuickActionsGrid(isOwner: isOwner),
        ],
      ),
    );
  }
}

// ── Welcome Banner ─────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  final String name;
  final String role;
  final bool isOwner;
  const _WelcomeBanner({
    required this.name,
    required this.role,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً، $name 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isOwner
                      ? 'لديك صلاحيات كاملة على المنصة — إدارة الشركات والتقارير'
                      : 'مرحباً بك في لوحة تحكم المدير',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _RoleBadge(role: role),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Mini stats in banner
          if (isOwner)
            BlocBuilder<OwnerStatisticsCubit, OwnerStatisticsState>(
              builder: (context, state) {
                final isLoaded = state is OwnerStatisticsLoaded;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _BannerStat(
                      label: 'شركة نشطة',
                      value: isLoaded ? '${state.statistics.activeCompanies}' : '--',
                    ),
                    const SizedBox(width: 16),
                    _BannerStat(
                      label: 'مركبة',
                      value: isLoaded ? '${state.statistics.totalVehicles}' : '--',
                    ),
                    const SizedBox(width: 16),
                    _BannerStat(
                      label: 'سائق',
                      value: isLoaded ? '${state.statistics.totalDrivers}' : '--',
                    ),
                  ],
                );
              },
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  const _BannerStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(.2)),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    ),
  );
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (role) {
      'owner' => ('مالك المنصة', Icons.verified_outlined),
      'manager' => ('مدير الأسطول', Icons.manage_accounts_outlined),
      _ => ('مستخدم', Icons.person_outline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section title ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 3,
        height: 18,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );
}

// ── Owner stats row ────────────────────────────────────────────────────────

class _OwnerStatsRow extends StatelessWidget {
  final OwnerStatisticsModel? statistics;
  const _OwnerStatsRow({this.statistics});

  @override
  Widget build(BuildContext context) {
    final stats = statistics;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.business_outlined,
            label: 'الشركات',
            value: stats != null ? '${stats.totalCompanies}' : '--',
            sub: stats != null ? '${stats.activeCompanies} نشطة' : '--',
            color: AppColors.primary,
            trend: stats != null && stats.companiesGrowthCount > 0
                ? '+${stats.companiesGrowthCount} هذا الشهر'
                : 'لا يوجد نمو هذا الشهر',
            trendUp: stats != null && stats.companiesGrowthCount > 0,
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.companies,
              (r) => false,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            icon: Icons.directions_car_outlined,
            label: 'المركبات',
            value: stats != null ? '${stats.totalVehicles}' : '--',
            sub: stats != null ? '${stats.activeVehicles} في الخدمة' : '--',
            color: const Color(0xFF7B1FA2),
            trend: stats != null && stats.vehiclesGrowthCount > 0
                ? '+${stats.vehiclesGrowthCount} هذا الشهر'
                : 'لا يوجد نمو هذا الشهر',
            trendUp: stats != null && stats.vehiclesGrowthCount > 0,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            icon: Icons.people_outline,
            label: 'السائقون',
            value: stats != null ? '${stats.totalDrivers}' : '--',
            sub: stats != null ? '${stats.activeDrivers} نشط' : '--',
            color: AppColors.success,
            trend: stats != null && stats.driversGrowthCount > 0
                ? '+${stats.driversGrowthCount} هذا الشهر'
                : 'لا يوجد نمو هذا الشهر',
            trendUp: stats != null && stats.driversGrowthCount > 0,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            icon: Icons.bar_chart_outlined,
            label: 'التقارير',
            value: '36',
            sub: 'هذا الشهر',
            color: AppColors.warning,
            trend: 'آخر تحديث اليوم',
            trendUp: null,
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.reports,
              (r) => false,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;
  final String trend;
  final bool? trendUp; // null = neutral
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.trend,
    this.trendUp,
    this.onTap,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final trendColor = widget.trendUp == null
        ? AppColors.textHint
        : widget.trendUp!
        ? AppColors.success
        : AppColors.danger;
    final trendIcon = widget.trendUp == null
        ? Icons.remove
        : widget.trendUp!
        ? Icons.trending_up
        : Icons.trending_down;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? widget.color.withOpacity(.4) : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? widget.color.withOpacity(.12)
                    : Colors.black.withOpacity(.04),
                blurRadius: _hovered ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 20),
                  ),
                  if (widget.onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: _hovered ? widget.color : AppColors.textHint,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _hovered ? widget.color : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(trendIcon, size: 13, color: trendColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.trend,
                      style: TextStyle(
                        fontSize: 11,
                        color: trendColor,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick actions grid ─────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  final bool isOwner;
  const _QuickActionsGrid({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final actions = isOwner
        ? [
            _ActionDef(
              Icons.business_outlined,
              'إدارة الشركات',
              'عرض وإضافة وتعديل الشركات',
              AppColors.primary,
              AppRoutes.companies,
            ),
            _ActionDef(
              Icons.bar_chart_outlined,
              'التقارير',
              'تقارير المنصة والإحصائيات',
              AppColors.warning,
              AppRoutes.reports,
            ),
            _ActionDef(
              Icons.person_outline,
              'الملف الشخصي',
              'إعدادات الحساب وكلمة المرور',
              AppColors.success,
              AppRoutes.profile,
            ),
          ]
        : [
            _ActionDef(
              Icons.directions_car_outlined,
              'المركبات',
              'إدارة أسطول المركبات',
              AppColors.primary,
              AppRoutes.vehicles,
            ),
            _ActionDef(
              Icons.people_outline,
              'السائقون',
              'إدارة السائقين والحسابات',
              const Color(0xFF7B1FA2),
              AppRoutes.drivers,
            ),
            _ActionDef(
              Icons.map_outlined,
              'التتبع المباشر',
              'مراقبة المركبات لحظياً',
              AppColors.success,
              AppRoutes.tracking,
            ),
          ];

    return Row(
      children: actions
          .map(
            (a) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: a == actions.last ? 0 : 14),
                child: _QuickActionCard(def: a),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ActionDef {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;
  const _ActionDef(
    this.icon,
    this.title,
    this.subtitle,
    this.color,
    this.route,
  );
}

class _QuickActionCard extends StatefulWidget {
  final _ActionDef def;
  const _QuickActionCard({required this.def});

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.def;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () =>
            Navigator.pushNamedAndRemoveUntil(context, d.route, (r) => false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _hovered ? d.color.withOpacity(.06) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? d.color.withOpacity(.5) : AppColors.border,
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? d.color.withOpacity(.1)
                    : Colors.black.withOpacity(.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: d.color.withOpacity(.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(d.icon, color: d.color, size: 22),
              ),
              const SizedBox(height: 14),
              Text(
                d.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _hovered ? d.color : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                d.subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'الانتقال',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _hovered ? d.color : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 12,
                    color: _hovered ? d.color : AppColors.textHint,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Loading Stats Row ──────────────────────────────────────────────────────

class _LoadingStatsRow extends StatelessWidget {
  const _LoadingStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _LoadingStatCard()),
        const SizedBox(width: 14),
        Expanded(child: _LoadingStatCard()),
        const SizedBox(width: 14),
        Expanded(child: _LoadingStatCard()),
        const SizedBox(width: 14),
        Expanded(child: _LoadingStatCard()),
      ],
    );
  }
}

class _LoadingStatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 28,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 80,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 8),
          Container(
            height: 11,
            width: 100,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error Card ─────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withOpacity(.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.error_outline,
              color: AppColors.danger,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'فشل تحميل الإحصائيات',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<OwnerStatisticsCubit>().load();
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

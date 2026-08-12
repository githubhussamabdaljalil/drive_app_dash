import 'package:flutter/material.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/theme/app_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: '/admin/reports',
      pageTitle: 'التقارير',
      body: const _ReportsBody(),
    );
  }
}

class _ReportsBody extends StatefulWidget {
  const _ReportsBody();

  @override
  State<_ReportsBody> createState() => _ReportsBodyState();
}

class _ReportsBodyState extends State<_ReportsBody> {
  String _selectedPeriod = 'month'; // day, week, month, year, custom

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header with filters ─────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تقارير المنصة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'نظرة شاملة على أداء المنصة والإحصائيات',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Period selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _PeriodBtn(
                      label: 'يوم',
                      value: 'day',
                      selected: _selectedPeriod,
                      onTap: (v) => setState(() => _selectedPeriod = v),
                    ),
                    _PeriodBtn(
                      label: 'أسبوع',
                      value: 'week',
                      selected: _selectedPeriod,
                      onTap: (v) => setState(() => _selectedPeriod = v),
                    ),
                    _PeriodBtn(
                      label: 'شهر',
                      value: 'month',
                      selected: _selectedPeriod,
                      onTap: (v) => setState(() => _selectedPeriod = v),
                    ),
                    _PeriodBtn(
                      label: 'سنة',
                      value: 'year',
                      selected: _selectedPeriod,
                      onTap: (v) => setState(() => _selectedPeriod = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Export button
              _IconBtn(
                icon: Icons.download_outlined,
                label: 'تصدير PDF',
                color: AppColors.primary,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('سيتم إضافة ميزة التصدير قريباً'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Overview Stats ──────────────────────────────────────────
          const _SectionTitle('نظرة عامة'),
          const SizedBox(height: 14),
          const _OverviewStatsRow(),
          const SizedBox(height: 28),

          // ── Charts Row ──────────────────────────────────────────────
          const _SectionTitle('الرسوم البيانية'),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _ChartCard(
                  title: 'نمو الشركات',
                  subtitle: 'عدد الشركات المسجلة خلال ${_periodLabel()}',
                  icon: Icons.trending_up,
                  color: AppColors.primary,
                  chart: _LineChartWidget(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ChartCard(
                  title: 'توزيع المركبات',
                  subtitle: 'حسب الحالة',
                  icon: Icons.pie_chart_outline,
                  color: const Color(0xFF7B1FA2),
                  chart: _PieChartWidget(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Tables ──────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const _SectionTitle('أفضل الشركات أداءً'),
                    const SizedBox(height: 14),
                    _TopCompaniesTable(),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    const _SectionTitle('أفضل السائقين'),
                    const SizedBox(height: 14),
                    _TopDriversTable(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Recent Activities ───────────────────────────────────────
          const _SectionTitle('النشاطات الأخيرة'),
          const SizedBox(height: 14),
          _RecentActivitiesTable(),
        ],
      ),
    );
  }

  String _periodLabel() => switch (_selectedPeriod) {
    'day' => 'اليوم',
    'week' => 'الأسبوع',
    'month' => 'الشهر',
    'year' => 'السنة',
    _ => 'الفترة المحددة',
  };
}

// ── Period Button ──────────────────────────────────────────────────────────

class _PeriodBtn extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final void Function(String) onTap;

  const _PeriodBtn({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        minimumSize: const Size(120, 40),
      ),
    ),
  );
}

// ── Section Title ──────────────────────────────────────────────────────────

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

// ── Overview Stats ─────────────────────────────────────────────────────────

class _OverviewStatsRow extends StatelessWidget {
  const _OverviewStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.business_outlined,
            label: 'إجمالي الشركات',
            value: '14',
            change: '+2',
            changePercent: '+16.7%',
            isPositive: true,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            icon: Icons.directions_car_outlined,
            label: 'إجمالي المركبات',
            value: '87',
            change: '+5',
            changePercent: '+6.1%',
            isPositive: true,
            color: const Color(0xFF7B1FA2),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            icon: Icons.people_outline,
            label: 'إجمالي السائقين',
            value: '143',
            change: '+11',
            changePercent: '+8.3%',
            isPositive: true,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            icon: Icons.navigation_outlined,
            label: 'الرحلات المكتملة',
            value: '2,847',
            change: '+127',
            changePercent: '+4.7%',
            isPositive: true,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String change;
  final String changePercent;
  final bool isPositive;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.change,
    required this.changePercent,
    required this.isPositive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.successSurface
                      : AppColors.dangerSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 11,
                      color: isPositive ? AppColors.success : AppColors.danger,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      changePercent,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isPositive
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$change هذا الشهر',
            style: const TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

// ── Chart Card ─────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget chart;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          chart,
        ],
      ),
    );
  }
}

// ── Line Chart (Mock) ──────────────────────────────────────────────────────

class _LineChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [2, 4, 3, 6, 5, 8, 7, 10, 9, 12, 11, 14];
    final max = data.reduce((a, b) => a > b ? a : b).toDouble();

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final height = (data[i] / max) * 160;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Pie Chart (Mock) ───────────────────────────────────────────────────────

class _PieChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: Stack(
            children: [
              // Simple pie chart representation
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      AppColors.success,
                      AppColors.success,
                      AppColors.warning,
                      AppColors.warning,
                      AppColors.danger,
                      AppColors.danger,
                      AppColors.success,
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '87',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _PieLegend(color: AppColors.success, label: 'في الخدمة', value: '74'),
        const SizedBox(height: 6),
        _PieLegend(color: AppColors.warning, label: 'صيانة', value: '8'),
        const SizedBox(height: 6),
        _PieLegend(color: AppColors.danger, label: 'معطلة', value: '5'),
      ],
    );
  }
}

class _PieLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _PieLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );
}

// ── Top Companies Table ────────────────────────────────────────────────────

class _TopCompaniesTable extends StatelessWidget {
  final _data = const [
    ('شركة النقل الحديث', '2,847', '98.5%', AppColors.success),
    ('شركة الخليج للنقل', '2,134', '96.2%', AppColors.success),
    ('شركة الأمانة', '1,923', '94.8%', AppColors.success),
    ('شركة الرياض للخدمات', '1,456', '91.3%', AppColors.warning),
    ('شركة الفجر', '1,087', '87.9%', AppColors.warning),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'الشركة',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'الرحلات',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    'الأداء',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rows
          ..._data.asMap().entries.map((e) {
            final i = e.key;
            final d = e.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          d.$1,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          d.$2,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          d.$3,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: d.$4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < _data.length - 1)
                  const Divider(height: 1, color: AppColors.divider),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Top Drivers Table ──────────────────────────────────────────────────────

class _TopDriversTable extends StatelessWidget {
  final _data = const [
    ('أحمد محمد', '327', '5.0', AppColors.success),
    ('خالد العمري', '298', '4.9', AppColors.success),
    ('محمد السعيد', '276', '4.8', AppColors.success),
    ('عبدالله الأحمد', '251', '4.7', AppColors.success),
    ('سعيد الحربي', '234', '4.6', AppColors.warning),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'السائق',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'الرحلات',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    'التقييم',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rows
          ..._data.asMap().entries.map((e) {
            final i = e.key;
            final d = e.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          d.$1,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          d.$2,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 11,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              d.$3,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < _data.length - 1)
                  const Divider(height: 1, color: AppColors.divider),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Recent Activities Table ────────────────────────────────────────────────

class _RecentActivitiesTable extends StatelessWidget {
  final _data = const [
    (
      'شركة النقل الحديث',
      'اكتملت 47 رحلة بنجاح',
      'منذ 5 دقائق',
      Icons.check_circle_outline,
      AppColors.success,
    ),
    (
      'السائق أحمد محمد',
      'بدأ رحلة جديدة - الرياض إلى جدة',
      'منذ 15 دقيقة',
      Icons.navigation_outlined,
      AppColors.primary,
    ),
    (
      'شركة الخليج',
      'تم تسجيل 3 مركبات جديدة',
      'منذ 32 دقيقة',
      Icons.directions_car_outlined,
      AppColors.success,
    ),
    (
      'السائق خالد العمري',
      'طلب صيانة للمركبة #7845',
      'منذ ساعة',
      Icons.build_outlined,
      AppColors.warning,
    ),
    (
      'شركة الأمانة',
      'تحديث بيانات 5 سائقين',
      'منذ ساعتين',
      Icons.people_outline,
      AppColors.primary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _data.asMap().entries.map((e) {
          final i = e.key;
          final d = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: d.$5.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(d.$4, color: d.$5, size: 17),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.$1,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            d.$2,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      d.$3,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < _data.length - 1)
                const Divider(height: 1, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }
}

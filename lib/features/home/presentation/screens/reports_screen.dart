import 'package:driver_app_dash/core/utils/file_download_helper.dart';
import 'package:driver_app_dash/features/owner/data/models/owner_reports_model.dart';
import 'package:driver_app_dash/features/owner/presentation/cubit/owner_reports_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';

import '../../../owner/presentation/cubit/owner_reports_state.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: AppRoutes.reports,
      pageTitle: 'التقارير',
      body: const _OwnerReportsBody(),
    );
  }
}

class _OwnerReportsBody extends StatefulWidget {
  const _OwnerReportsBody();

  @override
  State<_OwnerReportsBody> createState() => _OwnerReportsBodyState();
}

class _OwnerReportsBodyState extends State<_OwnerReportsBody> {
  int? _selectedCompanyId;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerReportsCubit>().loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OwnerReportsCubit, OwnerReportsState>(
      listener: (context, state) {
        // ================================================================
        // PDF EXPORT SUCCESS
        // ================================================================
        if (state is OwnerReportsExported) {
          final date = _fileDate();

          FileDownloadHelper.downloadPdf(
            state.bytes,
            fileName: 'owner_reports_$date.pdf',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تصدير التقرير بنجاح')),
          );
        }

        // ================================================================
        // EXPORT ERROR
        // ================================================================
        if (state is OwnerReportsFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<OwnerReportsCubit, OwnerReportsState>(
        builder: (context, state) {
          final reports = _getReports(state);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  onExport: () => _exportPdf(context),
                  exporting: state is OwnerReportsExporting,
                ),

                const SizedBox(height: 20),

                _FilterBar(
                  reports: reports,
                  selectedCompanyId: _selectedCompanyId,
                  dateFrom: _dateFrom,
                  dateTo: _dateTo,
                  onCompanyChanged: (value) {
                    setState(() {
                      _selectedCompanyId = value;
                    });

                    context.read<OwnerReportsCubit>().loadReports(
                      companyId: value,
                      dateFrom: _formatDate(_dateFrom),
                      dateTo: _formatDate(_dateTo),
                    );
                  },
                  onDateFromChanged: (date) {
                    setState(() {
                      _dateFrom = date;
                    });

                    _reload();
                  },
                  onDateToChanged: (date) {
                    setState(() {
                      _dateTo = date;
                    });

                    _reload();
                  },
                  onClear: () {
                    setState(() {
                      _selectedCompanyId = null;
                      _dateFrom = null;
                      _dateTo = null;
                    });

                    context.read<OwnerReportsCubit>().clearFilters();
                  },
                ),

                const SizedBox(height: 24),

                if (state is OwnerReportsLoading) const _LoadingBlock(),

                if (state is OwnerReportsFailure)
                  _ErrorBlock(message: state.message, onRetry: _reload),

                if (state is OwnerReportsLoaded)
                  _ReportsContent(reports: state.reports),

                if (state is OwnerReportsExporting)
                  const _LoadingBlock(message: 'جاري تجهيز التقرير...'),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // GET CURRENT REPORTS
  // =========================================================================

  List<OwnerReportModel> _getReports(OwnerReportsState state) {
    if (state is OwnerReportsLoaded) {
      return state.reports;
    }

    if (state is OwnerReportsLoading) {
      return state.previousReports;
    }

    if (state is OwnerReportsFailure) {
      return state.previousReports;
    }

    if (state is OwnerReportsExporting) {
      return state.reports;
    }

    if (state is OwnerReportsExported) {
      return state.reports;
    }

    return context.read<OwnerReportsCubit>().currentReports;
  }

  // =========================================================================
  // RELOAD
  // =========================================================================

  void _reload() {
    context.read<OwnerReportsCubit>().loadReports(
      companyId: _selectedCompanyId,
      dateFrom: _formatDate(_dateFrom),
      dateTo: _formatDate(_dateTo),
    );
  }

  // =========================================================================
  // EXPORT PDF
  // =========================================================================

  void _exportPdf(BuildContext context) {
    context.read<OwnerReportsCubit>().exportReports(
      format: 'pdf',
      companyId: _selectedCompanyId,
      dateFrom: _formatDate(_dateFrom),
      dateTo: _formatDate(_dateTo),
    );
  }

  // =========================================================================
  // FORMAT API DATE
  // =========================================================================

  String? _formatDate(DateTime? date) {
    if (date == null) return null;

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // =========================================================================
  // FILE DATE
  // =========================================================================

  String _fileDate() {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}

// ============================================================================
// HEADER
// ============================================================================

class _Header extends StatelessWidget {
  final VoidCallback onExport;
  final bool exporting;

  const _Header({required this.onExport, required this.exporting});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تقارير المنصة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'نظرة شاملة على أداء الشركات والمركبات والسائقين',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        ElevatedButton.icon(
          onPressed: exporting ? null : onExport,
          icon: exporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.picture_as_pdf_outlined, size: 17),
          label: Text(
            exporting ? 'جاري التصدير...' : 'تصدير PDF',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withOpacity(.6),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: const Size(125, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// FILTER BAR
// ============================================================================

class _FilterBar extends StatelessWidget {
  final List<OwnerReportModel> reports;

  final int? selectedCompanyId;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  final ValueChanged<int?> onCompanyChanged;
  final ValueChanged<DateTime?> onDateFromChanged;
  final ValueChanged<DateTime?> onDateToChanged;

  final VoidCallback onClear;

  const _FilterBar({
    required this.reports,
    required this.selectedCompanyId,
    required this.dateFrom,
    required this.dateTo,
    required this.onCompanyChanged,
    required this.onDateFromChanged,
    required this.onDateToChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        selectedCompanyId != null || dateFrom != null || dateTo != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // ================================================================
          // COMPANY
          // ================================================================
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: selectedCompanyId,
                hint: const Text('كل الشركات', style: TextStyle(fontSize: 12)),
                isDense: true,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('كل الشركات'),
                  ),
                  ...reports
                      .map(
                        (report) => DropdownMenuItem<int?>(
                          value: report.companyId,
                          child: Text(report.companyName),
                        ),
                      )
                      .toList(),
                ],
                onChanged: onCompanyChanged,
              ),
            ),
          ),

          // ================================================================
          // DATE FROM
          // ================================================================
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: dateFrom ?? DateTime.now(),
                firstDate: DateTime(DateTime.now().year - 3),
                lastDate: DateTime.now(),
              );

              if (picked != null) {
                onDateFromChanged(picked);
              }
            },
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(
              dateFrom == null ? 'من تاريخ' : _displayDate(dateFrom!),
              style: const TextStyle(fontSize: 12),
            ),
          ),

          // ================================================================
          // DATE TO
          // ================================================================
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: dateTo ?? DateTime.now(),
                firstDate: DateTime(DateTime.now().year - 3),
                lastDate: DateTime.now(),
              );

              if (picked != null) {
                onDateToChanged(picked);
              }
            },
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(
              dateTo == null ? 'إلى تاريخ' : _displayDate(dateTo!),
              style: const TextStyle(fontSize: 12),
            ),
          ),

          // ================================================================
          // CLEAR
          // ================================================================
          if (hasFilters)
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 15),
              label: const Text('مسح الفلاتر', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  static String _displayDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}

// ============================================================================
// REPORTS CONTENT
// ============================================================================

class _ReportsContent extends StatelessWidget {
  final List<OwnerReportModel> reports;

  const _ReportsContent({required this.reports});

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const _EmptyBlock();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlatformOverview(reports: reports),

        const SizedBox(height: 24),

        const Text(
          'تقارير الشركات',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 14),

        ...reports.map(
          (report) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _CompanyReportCard(report: report),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// PLATFORM OVERVIEW
// ============================================================================

class _PlatformOverview extends StatelessWidget {
  final List<OwnerReportModel> reports;

  const _PlatformOverview({required this.reports});

  @override
  Widget build(BuildContext context) {
    int vehicles = 0;
    int activeVehicles = 0;
    int managers = 0;
    int drivers = 0;
    int attendance = 0;
    int guestCodes = 0;

    int sosTotal = 0;
    int destinationsTotal = 0;

    for (final report in reports) {
      vehicles += report.vehiclesCount;
      activeVehicles += report.activeVehiclesCount;
      managers += report.managersCount;
      drivers += report.driversCount;
      attendance += report.attendanceCount;
      guestCodes += report.guestCodesIssuedCount;

      sosTotal += report.sos.total;
      destinationsTotal += report.destinations.total;
    }

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _StatCard(
          icon: Icons.business_outlined,
          label: 'الشركات',
          value: reports.length.toString(),
          color: AppColors.primary,
        ),

        _StatCard(
          icon: Icons.directions_car_outlined,
          label: 'إجمالي المركبات',
          value: vehicles.toString(),
          color: AppColors.primary,
        ),

        _StatCard(
          icon: Icons.check_circle_outline,
          label: 'المركبات النشطة',
          value: activeVehicles.toString(),
          color: AppColors.success,
        ),

        _StatCard(
          icon: Icons.people_outline,
          label: 'السائقون',
          value: drivers.toString(),
          color: const Color(0xFF7B1FA2),
        ),

        _StatCard(
          icon: Icons.groups_outlined,
          label: 'المدراء',
          value: managers.toString(),
          color: AppColors.warning,
        ),

        _StatCard(
          icon: Icons.access_time_outlined,
          label: 'سجلات الحضور',
          value: attendance.toString(),
          color: AppColors.primary,
        ),

        _StatCard(
          icon: Icons.card_giftcard_outlined,
          label: 'رموز الضيوف',
          value: guestCodes.toString(),
          color: const Color(0xFF7B1FA2),
        ),

        _StatCard(
          icon: Icons.warning_amber_outlined,
          label: 'أحداث SOS',
          value: sosTotal.toString(),
          color: AppColors.danger,
        ),

        _StatCard(
          icon: Icons.navigation_outlined,
          label: 'الوجهات',
          value: destinationsTotal.toString(),
          color: AppColors.primary,
        ),
      ],
    );
  }
}

// ============================================================================
// COMPANY CARD
// ============================================================================

class _CompanyReportCard extends StatelessWidget {
  final OwnerReportModel report;

  const _CompanyReportCard({required this.report});

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
          // ================================================================
          // COMPANY HEADER
          // ================================================================
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.companyName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'معرّف الشركة: ${report.companyId}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              _StatusBadge(status: report.companyStatus),
            ],
          ),

          const SizedBox(height: 20),

          // ================================================================
          // BASIC STATISTICS
          // ================================================================
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MiniStat(
                icon: Icons.directions_car_outlined,
                label: 'المركبات',
                value: report.vehiclesCount,
              ),

              _MiniStat(
                icon: Icons.check_circle_outline,
                label: 'النشطة',
                value: report.activeVehiclesCount,
              ),

              _MiniStat(
                icon: Icons.people_outline,
                label: 'السائقون',
                value: report.driversCount,
              ),

              _MiniStat(
                icon: Icons.groups_outlined,
                label: 'المدراء',
                value: report.managersCount,
              ),

              _MiniStat(
                icon: Icons.access_time_outlined,
                label: 'الحضور',
                value: report.attendanceCount,
              ),

              _MiniStat(
                icon: Icons.card_giftcard_outlined,
                label: 'رموز الضيوف',
                value: report.guestCodesIssuedCount,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ================================================================
          // SOS + DESTINATIONS
          // ================================================================
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 700;

              final sos = _BreakdownCard(
                title: 'أحداث SOS',
                icon: Icons.warning_amber_outlined,
                color: AppColors.danger,
                total: report.sos.total,
                rows: [
                  _BreakdownRow(label: 'نشطة', value: report.sos.active),
                  _BreakdownRow(
                    label: 'تمت رؤيتها',
                    value: report.sos.acknowledged,
                  ),
                  _BreakdownRow(label: 'تم حلها', value: report.sos.resolved),
                ],
              );

              final destinations = _BreakdownCard(
                title: 'الوجهات',
                icon: Icons.navigation_outlined,
                color: AppColors.primary,
                total: report.destinations.total,
                rows: [
                  _BreakdownRow(
                    label: 'مرسلة',
                    value: report.destinations.sent,
                  ),
                  _BreakdownRow(
                    label: 'مقبولة',
                    value: report.destinations.accepted,
                  ),
                  _BreakdownRow(
                    label: 'مرفوضة',
                    value: report.destinations.rejected,
                  ),
                  _BreakdownRow(
                    label: 'ملغاة',
                    value: report.destinations.cancelled,
                  ),
                ],
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: sos),
                    const SizedBox(width: 14),
                    Expanded(child: destinations),
                  ],
                );
              }

              return Column(
                children: [sos, const SizedBox(height: 14), destinations],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BREAKDOWN CARD
// ============================================================================

class _BreakdownCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int total;
  final List<_BreakdownRow> rows;

  const _BreakdownCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.total,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),

              const SizedBox(width: 8),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const Spacer(),

              Text(
                total.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (rows.every((row) => row.value == 0))
            const Text(
              'لا توجد بيانات',
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
            )
          else
            ...rows.map(
              (row) => _BreakdownItem(row: row, total: total, color: color),
            ),
        ],
      ),
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  final _BreakdownRow row;
  final int total;
  final Color color;

  const _BreakdownItem({
    required this.row,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : row.value / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              Text(
                row.value.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STAT CARD
// ============================================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(17),
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
            decoration: BoxDecoration(
              color: color.withOpacity(.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 19),
          ),

          const SizedBox(height: 11),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MINI STAT
// ============================================================================

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.primary),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
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
// STATUS BADGE
// ============================================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';

    final color = isActive ? AppColors.success : AppColors.danger;

    final text = isActive ? 'نشطة' : status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ============================================================================
// LOADING
// ============================================================================

class _LoadingBlock extends StatelessWidget {
  final String message;

  const _LoadingBlock({this.message = 'جاري تحميل التقارير...'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),

            const SizedBox(height: 14),

            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY
// ============================================================================

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.bar_chart_outlined, size: 50, color: AppColors.textHint),

            const SizedBox(height: 12),

            const Text(
              'لا توجد تقارير',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'لا توجد بيانات مطابقة للفلاتر المحددة',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ERROR
// ============================================================================

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 42, color: AppColors.danger),

            const SizedBox(height: 12),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 14),

            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DATA CLASS
// ============================================================================

class _BreakdownRow {
  final String label;
  final int value;

  const _BreakdownRow({required this.label, required this.value});
}

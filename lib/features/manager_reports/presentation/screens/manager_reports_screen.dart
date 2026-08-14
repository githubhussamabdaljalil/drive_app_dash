import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/constants/app_routes.dart';
import '../../data/models/manager_reports_model.dart';
import '../cubit/manager_reports_cubit.dart';
import '../widgets/manager_reports_filter_bar.dart';
import '../widgets/manager_reports_overview_row.dart';
import '../widgets/report_status_breakdown_card.dart';
import '../widgets/export_link_dialog.dart';

/// Manager's own reports screen — GET /admin/manager/reports, company
/// scoped. Every figure on this page comes from that response; there is
/// no placeholder/mock data.
class ManagerReportsScreen extends StatelessWidget {
  const ManagerReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: AppRoutes.reports,
      pageTitle: 'التقارير',
      body: const _ManagerReportsBody(),
    );
  }
}

class _ManagerReportsBody extends StatefulWidget {
  const _ManagerReportsBody();

  @override
  State<_ManagerReportsBody> createState() => _ManagerReportsBodyState();
}

class _ManagerReportsBodyState extends State<_ManagerReportsBody> {
  @override
  void initState() {
    super.initState();
    context.read<ManagerReportsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManagerReportsCubit, ManagerReportsState>(
      builder: (ctx, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(onExport: () => _export(ctx)),
              const SizedBox(height: 18),
              const ManagerReportsFilterBar(),
              const SizedBox(height: 24),
              if (state is ManagerReportsLoading) const _LoadingBlock(),
              if (state is ManagerReportsError)
                _ErrorBlock(message: state.message, onRetry: () => ctx.read<ManagerReportsCubit>().load()),
              if (state is ManagerReportsLoaded) _ReportsContent(reports: state.reports),
            ],
          ),
        );
      },
    );
  }

  void _export(BuildContext context) {
    final url = context.read<ManagerReportsCubit>().buildExportUrl();
    showExportLinkDialog(context, url: url, format: 'pdf');
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onExport;
  const _Header({required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تقارير الشركة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              SizedBox(height: 2),
              Text('نظرة على أداء أسطولك وسائقيك', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: onExport,
          icon: const Icon(Icons.download_outlined, size: 16),
          label: const Text('تصدير PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: const Size(120, 40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

class _ReportsContent extends StatelessWidget {
  final ManagerReportsModel reports;
  const _ReportsContent({required this.reports});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ManagerReportsOverviewRow(reports: reports),
        const SizedBox(height: 24),
        LayoutBuilder(builder: (ctx, constraints) {
          final isWide = constraints.maxWidth > 700;
          final sos = ReportStatusBreakdownCard(
            title: 'أحداث SOS', icon: Icons.warning_amber_outlined, color: AppColors.danger, data: reports.sos);
          final destinations = ReportStatusBreakdownCard(
            title: 'الوجهات', icon: Icons.navigation_outlined, color: AppColors.primary, data: reports.destinations);
          return isWide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: sos),
                  const SizedBox(width: 14),
                  Expanded(child: destinations),
                ])
              : Column(children: [sos, const SizedBox(height: 14), destinations]);
        }),
      ],
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh, size: 18), label: const Text('إعادة المحاولة')),
        ]),
      ),
    );
  }
}

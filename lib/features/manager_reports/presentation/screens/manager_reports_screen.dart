import 'package:driver_app_dash/core/utils/file_download_helper.dart';
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
    return BlocListener<ManagerReportsCubit, ManagerReportsState>(
      listener: (ctx, state) {
        if (state is ManagerReportsExported) {
          final now = DateTime.now();
          final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
          FileDownloadHelper.downloadPdf(state.bytes, fileName: 'manager_reports_$date.pdf');
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('تم تصدير التقرير بنجاح')),
          );
        }
        if (state is ManagerReportsError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<ManagerReportsCubit, ManagerReportsState>(
        builder: (ctx, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(onExport: () => ctx.read<ManagerReportsCubit>().exportReports(), exporting: state is ManagerReportsExporting),
                const SizedBox(height: 18),
                const ManagerReportsFilterBar(),
                const SizedBox(height: 24),
                if (state is ManagerReportsLoading) const _LoadingBlock(),
                if (state is ManagerReportsExporting) const _LoadingBlock(message: 'جاري تجهيز التقرير...'),
                if (state is ManagerReportsError)
                  _ErrorBlock(message: state.message, onRetry: () => ctx.read<ManagerReportsCubit>().load()),
                if (state is ManagerReportsLoaded) _ReportsContent(reports: state.reports),
                if (state is ManagerReportsExporting && state.reports != null) _ReportsContent(reports: state.reports!),
              ],
            ),
          );
        },
      ),
    );
  }
}

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
              Text('تقارير الشركة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              SizedBox(height: 2),
              Text('نظرة على أداء أسطولك وسائقيك', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: exporting ? null : onExport,
          icon: exporting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.download_outlined, size: 16),
          label: Text(exporting ? 'جاري التصدير...' : 'تصدير PDF', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withOpacity(.6),
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
  final String message;
  const _LoadingBlock({this.message = 'جاري تحميل التقارير...'});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 14),
          Text(message, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ])),
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

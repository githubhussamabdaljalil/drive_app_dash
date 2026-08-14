import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/constants/app_routes.dart';

import 'package:driver_app_dash/features/sos/data/models/sos_event_model.dart';
import 'package:driver_app_dash/features/sos/presentation/cubit/sos_cubit.dart';

class SosEventsScreen extends StatelessWidget {
  const SosEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: AppRoutes.sosEvents,
      pageTitle: 'أحداث SOS',
      body: const _SosBody(),
    );
  }
}

const _statusOptions = <String, String>{
  '': 'كل الحالات',
  'active': 'نشطة',
  'acknowledged': 'تم الاطلاع',
  'resolved': 'مغلقة',
};

class _SosBody extends StatefulWidget {
  const _SosBody();

  @override
  State<_SosBody> createState() => _SosBodyState();
}

class _SosBodyState extends State<_SosBody> {
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    context.read<SosCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SosCubit, SosState>(
      listener: (ctx, state) {
        if (state is SosError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      builder: (ctx, state) {
        final events = switch (state) {
          SosLoaded() => state.events,
          SosSubmitting() => state.events,
          SosError() => state.events ?? [],
          _ => <SosEventModel>[],
        };

        final filtered = _statusFilter.isEmpty ? events : events.where((e) => e.status == _statusFilter).toList();
        final activeCount = events.where((e) => e.isActive).length;
        final isLoading = state is SosLoading;
        final isSubmitting = state is SosSubmitting;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('أحداث SOS',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 3),
                        Text('${events.length} حدث مسجل — $activeCount نشط الآن',
                            style: TextStyle(fontSize: 13, color: activeCount > 0 ? AppColors.danger : AppColors.textSecondary,
                                fontWeight: activeCount > 0 ? FontWeight.w700 : FontWeight.w400)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.read<SosCubit>().load(status: _statusFilter.isEmpty ? null : _statusFilter),
                    icon: const Icon(Icons.refresh, color: AppColors.primary),
                    tooltip: 'تحديث',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Status filter ─────────────────────────────────────────
              Wrap(
                spacing: 8,
                children: _statusOptions.entries.map((e) {
                  final selected = _statusFilter == e.key;
                  return ChoiceChip(
                    label: Text(e.value, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.textSecondary)),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                    onSelected: (_) => setState(() => _statusFilter = e.key),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // ── List ──────────────────────────────────────────────
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? const _EmptyState()
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => Opacity(
                              opacity: isSubmitting ? .6 : 1,
                              child: _SosCard(
                                event: filtered[i],
                                onAcknowledge: () => ctx.read<SosCubit>().acknowledge(filtered[i].id),
                                onResolve: () => ctx.read<SosCubit>().resolve(filtered[i].id),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// SOS CARD
// ============================================================================

class _SosCard extends StatelessWidget {
  final SosEventModel event;
  final VoidCallback onAcknowledge;
  final VoidCallback onResolve;

  const _SosCard({required this.event, required this.onAcknowledge, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    final borderColor = event.isActive ? AppColors.sos : AppColors.border;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: event.isActive ? AppColors.sosSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: event.isActive ? 1.5 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: event.isActive ? AppColors.sos : AppColors.textHint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warning_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(event.driverName ?? 'سائق غير معروف',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ),
                  if (event.isReAlert)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.warningSurface, borderRadius: BorderRadius.circular(20)),
                      child: const Text('تنبيه متكرر', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.warning)),
                    ),
                  _StatusBadge(status: event.status),
                ]),
                const SizedBox(height: 4),
                if (event.vehiclePlate != null)
                  Text('المركبة: ${event.vehiclePlate}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                SelectableText('${event.lat}, ${event.lng}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                if (event.triggeredAt != null) ...[
                  const SizedBox(height: 2),
                  Text('وقت التنبيه: ${event.triggeredAt}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                ],
                if (!event.isActive && event.isAcknowledged && event.acknowledgedAt != null) ...[
                  const SizedBox(height: 2),
                  Text('تم الاطلاع: ${event.acknowledgedAt}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                ],
                if (event.isResolved && event.resolvedAt != null) ...[
                  const SizedBox(height: 2),
                  Text('تم الإغلاق: ${event.resolvedAt}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                ],
                const SizedBox(height: 10),
                Row(children: [
                  if (event.isActive)
                    _SmallActionButton(label: 'تأكيد الاطلاع', icon: Icons.visibility_outlined, color: AppColors.warning, onTap: onAcknowledge),
                  if (event.isActive) const SizedBox(width: 8),
                  if (!event.isResolved)
                    _SmallActionButton(label: 'إغلاق الحدث', icon: Icons.check_circle_outline, color: AppColors.success, onTap: onResolve),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'active' => ('نشطة', AppColors.sos),
      'acknowledged' => ('تم الاطلاع', AppColors.warning),
      'resolved' => ('مغلقة', AppColors.success),
      _ => (status, AppColors.textHint),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppColors.successSurface, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.shield_outlined, size: 36, color: AppColors.success),
          ),
          const SizedBox(height: 16),
          const Text('لا توجد أحداث SOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('كل شيء هادئ حالياً', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ]),
      );
}

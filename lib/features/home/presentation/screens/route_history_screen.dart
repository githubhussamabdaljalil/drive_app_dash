import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_routes.dart';

import 'package:driver_app_dash/features/vehicles/data/models/vehicle_model.dart';
import 'package:driver_app_dash/features/vehicles/presentation/cubit/vehicle_cubit.dart';
import 'package:driver_app_dash/features/tracking/data/models/route_point_model.dart';
import 'package:driver_app_dash/features/tracking/presentation/cubit/route_history_cubit.dart';

const LatLng _fallbackCenter = LatLng(33.5138, 36.2765);

class RouteHistoryScreen extends StatelessWidget {
  const RouteHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteHistoryCubit(),
      child: DashboardLayout(
        activeRoute: AppRoutes.routeHistory,
        pageTitle: 'سجل المسارات',
        body: const _RouteHistoryBody(),
      ),
    );
  }
}

class _RouteHistoryBody extends StatefulWidget {
  const _RouteHistoryBody();

  @override
  State<_RouteHistoryBody> createState() => _RouteHistoryBodyState();
}

class _RouteHistoryBodyState extends State<_RouteHistoryBody> {
  final MapController _mapController = MapController();
  VehicleModel? _vehicle;
  late DateTime _from;
  late DateTime _to;

  @override
  void initState() {
    super.initState();
    context.read<VehicleCubit>().load();
    _to = DateTime.now();
    _from = _to.subtract(const Duration(hours: 24));
  }

  Future<void> _pickDateTime({required bool isFrom}) async {
    final initial = isFrom ? _from : _to;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: isFrom ? 'من تاريخ' : 'إلى تاريخ',
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      helpText: isFrom ? 'من وقت' : 'إلى وقت',
    );
    if (time == null) return;

    final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isFrom) {
        _from = combined;
      } else {
        _to = combined;
      }
    });
  }

  void _search() {
    if (_vehicle == null) return;
    if (_to.isBefore(_from)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تاريخ النهاية يجب أن يكون بعد تاريخ البداية'), backgroundColor: AppColors.danger),
      );
      return;
    }
    context.read<RouteHistoryCubit>().load(vehicleId: _vehicle!.id, from: _from, to: _to);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('سجل المسارات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          const Text('اختر مركبة وفترة زمنية لعرض المسار المقطوع',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 18),

          _Filters(
            vehicle: _vehicle,
            from: _from,
            to: _to,
            onVehicleChanged: (v) => setState(() => _vehicle = v),
            onPickFrom: () => _pickDateTime(isFrom: true),
            onPickTo: () => _pickDateTime(isFrom: false),
            onSearch: _vehicle == null ? null : _search,
          ),
          const SizedBox(height: 18),

          Expanded(
            child: BlocBuilder<RouteHistoryCubit, RouteHistoryState>(
              builder: (ctx, state) {
                if (state is RouteHistoryInitial) {
                  return const _Placeholder(text: 'اختر مركبة وفترة زمنية ثم اضغط "بحث" لعرض المسار.');
                }
                if (state is RouteHistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is RouteHistoryError) {
                  return _Placeholder(
                    text: state.message,
                    isError: true,
                    onRetry: _search,
                  );
                }

                final points = (state as RouteHistoryLoaded).points;
                if (points.isEmpty) {
                  return const _Placeholder(text: 'لا توجد نقاط مسار مسجّلة في هذه الفترة.');
                }

                WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds(points));

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _RouteSummary(points: points),
                      const Divider(height: 1, color: AppColors.divider),
                      Expanded(
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(initialCenter: _fallbackCenter, initialZoom: 12),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.vtfms.driver_app_dash',
                            ),
                            PolylineLayer(polylines: [
                              Polyline(
                                points: [for (final p in points) LatLng(p.lat, p.lng)],
                                strokeWidth: 4,
                                color: AppColors.primary,
                              ),
                            ]),
                            MarkerLayer(markers: [
                              _endpointMarker(points.first, AppColors.success, Icons.trip_origin),
                              if (points.length > 1) _endpointMarker(points.last, AppColors.danger, Icons.flag),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Marker _endpointMarker(RoutePointModel p, Color color, IconData icon) {
    return Marker(
      point: LatLng(p.lat, p.lng),
      width: 34,
      height: 34,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  void _fitBounds(List<RoutePointModel> points) {
    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(LatLng(points.first.lat, points.first.lng), 15);
      return;
    }
    final bounds = LatLngBounds.fromPoints([for (final p in points) LatLng(p.lat, p.lng)]);
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)));
  }
}

// ── Filters row ──────────────────────────────────────────────────────────

class _Filters extends StatelessWidget {
  final VehicleModel? vehicle;
  final DateTime from;
  final DateTime to;
  final ValueChanged<VehicleModel?> onVehicleChanged;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback? onSearch;

  const _Filters({
    required this.vehicle,
    required this.from,
    required this.to,
    required this.onVehicleChanged,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleCubit, VehicleState>(
      builder: (ctx, vState) {
        final vehicles = switch (vState) {
          VehicleLoaded() => vState.vehicles,
          VehicleSubmitting() => vState.vehicles,
          VehicleError() => vState.vehicles ?? [],
          _ => <VehicleModel>[],
        };

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 220,
                child: _FieldLabel(
                  label: 'المركبة',
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceInput,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<VehicleModel>(
                        value: vehicle,
                        isExpanded: true,
                        hint: const Text('اختر مركبة', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                        items: vehicles
                            .map((v) => DropdownMenuItem(value: v, child: Text(v.plateNo, style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: onVehicleChanged,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: _FieldLabel(label: 'من', child: _DateButton(value: from, onTap: onPickFrom)),
              ),
              SizedBox(
                width: 200,
                child: _FieldLabel(label: 'إلى', child: _DateButton(value: to, onTap: onPickTo)),
              ),
              SizedBox(
                width: 140,
                child: AppButton(label: 'بحث', icon: Icons.search, onPressed: onSearch),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldLabel({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _DateButton extends StatelessWidget {
  final DateTime value;
  final VoidCallback onTap;
  const _DateButton({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_outlined, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(child: Text(_fmt(value), style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}  ${two(d.hour)}:${two(d.minute)}';
  }
}

// ── Summary bar ──────────────────────────────────────────────────────────

class _RouteSummary extends StatelessWidget {
  final List<RoutePointModel> points;
  const _RouteSummary({required this.points});

  @override
  Widget build(BuildContext context) {
    final distanceKm = _totalDistanceKm(points);
    final duration = points.first.at != null && points.last.at != null
        ? points.last.at!.difference(points.first.at!)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _StatChip(icon: Icons.route_outlined, label: '${points.length} نقطة'),
          const SizedBox(width: 10),
          _StatChip(icon: Icons.straighten_outlined, label: '${distanceKm.toStringAsFixed(1)} كم تقريباً'),
          if (duration != null) ...[
            const SizedBox(width: 10),
            _StatChip(icon: Icons.schedule_outlined, label: _fmtDuration(duration)),
          ],
        ],
      ),
    );
  }

  double _totalDistanceKm(List<RoutePointModel> pts) {
    const earthRadiusKm = 6371.0;
    double total = 0;
    for (var i = 1; i < pts.length; i++) {
      final a = pts[i - 1];
      final b = pts[i];
      final dLat = _rad(b.lat - a.lat);
      final dLng = _rad(b.lng - a.lng);
      final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(_rad(a.lat)) * math.cos(_rad(b.lat)) * math.sin(dLng / 2) * math.sin(dLng / 2);
      total += 2 * earthRadiusKm * math.asin(math.sqrt(h));
    }
    return total;
  }

  double _rad(double deg) => deg * math.pi / 180;

  String _fmtDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours} س ${d.inMinutes % 60} د';
    return '${d.inMinutes} د';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    );
  }
}

// ── Placeholder / error states ─────────────────────────────────────────

class _Placeholder extends StatelessWidget {
  final String text;
  final bool isError;
  final VoidCallback? onRetry;
  const _Placeholder({required this.text, this.isError = false, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isError ? Icons.error_outline : Icons.map_outlined, size: 40, color: AppColors.textHint),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          if (isError && onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh, size: 18), label: const Text('إعادة المحاولة')),
          ],
        ],
      ),
    );
  }
}

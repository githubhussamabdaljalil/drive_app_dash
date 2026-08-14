import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/realtime/reverb_socket_service.dart';

import 'package:driver_app_dash/features/vehicles/data/models/vehicle_model.dart';
import 'package:driver_app_dash/features/vehicles/presentation/cubit/vehicle_cubit.dart';
import 'package:driver_app_dash/features/tracking/data/models/live_sos_alert_model.dart';
import 'package:driver_app_dash/features/tracking/data/models/vehicle_location_model.dart';
import 'package:driver_app_dash/features/tracking/presentation/cubit/tracking_cubit.dart';

// Damascus — fallback center until the first live point arrives.
const LatLng _fallbackCenter = LatLng(33.5138, 36.2765);

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrackingCubit()..start(),
      child: DashboardLayout(
        activeRoute: AppRoutes.tracking,
        pageTitle: 'التتبع المباشر',
        body: const _TrackingBody(),
      ),
    );
  }
}

class _TrackingBody extends StatefulWidget {
  const _TrackingBody();

  @override
  State<_TrackingBody> createState() => _TrackingBodyState();
}

class _TrackingBodyState extends State<_TrackingBody> {
  final MapController _mapController = MapController();
  int? _focusedVehicleId;
  bool _hasAutoCentered = false;
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    context.read<VehicleCubit>().load();
    // Repaints "قبل Xث" staleness labels + marker colors every few seconds
    // without needing a new event from the server.
    _tickTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  void _focusVehicle(int vehicleId, LatLng point) {
    setState(() => _focusedVehicleId = vehicleId);
    _mapController.move(point, 15);
  }

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
        final vehiclesById = {for (final v in vehicles) v.id: v};

        return BlocConsumer<TrackingCubit, TrackingState>(
          listener: (ctx, state) {
            if (state is TrackingReady && !_hasAutoCentered && state.locations.isNotEmpty) {
              _hasAutoCentered = true;
              final first = state.locations.values.first;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _mapController.move(LatLng(first.lat, first.lng), 13);
              });
            }
          },
          builder: (ctx, state) {
            final locations = state is TrackingReady ? state.locations : <int, VehicleLocationModel>{};
            final alerts = state is TrackingReady ? state.activeAlerts : <LiveSosAlertModel>[];
            final connection = state is TrackingReady ? state.connection : RealtimeStatus.connecting;

            return Column(
              children: [
                if (alerts.isNotEmpty) _SosBanner(alerts: alerts, vehiclesById: vehiclesById),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Vehicle list ─────────────────────────────
                      SizedBox(
                        width: 280,
                        child: _VehicleList(
                          vehicles: vehicles,
                          locations: locations,
                          focusedVehicleId: _focusedVehicleId,
                          onSelect: (v) {
                            final loc = locations[v.id];
                            if (loc != null) _focusVehicle(v.id, LatLng(loc.lat, loc.lng));
                          },
                        ),
                      ),
                      const VerticalDivider(width: 1, color: AppColors.border),

                      // ── Map ──────────────────────────────────────
                      Expanded(
                        child: Stack(
                          children: [
                            if (state is TrackingError)
                              _ErrorState(message: state.message, onRetry: () => ctx.read<TrackingCubit>().start())
                            else
                              FlutterMap(
                                mapController: _mapController,
                                options: const MapOptions(
                                  initialCenter: _fallbackCenter,
                                  initialZoom: 12,
                                  minZoom: 3,
                                  maxZoom: 18,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.vtfms.driver_app_dash',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      for (final entry in locations.entries)
                                        _vehicleMarker(
                                          vehicleId: entry.key,
                                          loc: entry.value,
                                          plate: vehiclesById[entry.key]?.plateNo,
                                          isFocused: _focusedVehicleId == entry.key,
                                          onTap: () => _focusVehicle(entry.key, LatLng(entry.value.lat, entry.value.lng)),
                                        ),
                                      for (final alert in alerts)
                                        if (alert.vehicleId != null) _sosMarker(alert, vehiclesById[alert.vehicleId]?.plateNo),
                                    ],
                                  ),
                                ],
                              ),

                            // Connection status chip
                            Positioned(top: 12, left: 12, child: _ConnectionChip(status: connection)),

                            if (state is TrackingReady && locations.isEmpty)
                              const _EmptyOverlay(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Marker _vehicleMarker({
    required int vehicleId,
    required VehicleLocationModel loc,
    required String? plate,
    required bool isFocused,
    required VoidCallback onTap,
  }) {
    final isStale = loc.at != null && DateTime.now().difference(loc.at!).inSeconds > 90;
    final color = isStale ? AppColors.textHint : AppColors.primary;

    return Marker(
      point: LatLng(loc.lat, loc.lng),
      width: 120,
      height: 62,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isFocused ? AppColors.primary : AppColors.border, width: isFocused ? 1.5 : 1),
                boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 1))],
              ),
              child: Text(
                plate ?? '#$vehicleId',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 2),
            Icon(Icons.directions_car, color: color, size: 26),
          ],
        ),
      ),
    );
  }

  Marker _sosMarker(LiveSosAlertModel alert, String? plate) {
    return Marker(
      point: LatLng(alert.lat, alert.lng),
      width: 100,
      height: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.sos, borderRadius: BorderRadius.circular(6)),
            child: Text(plate ?? 'SOS', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const Icon(Icons.warning_rounded, color: AppColors.sos, size: 28),
        ],
      ),
    );
  }
}

// ── Vehicle list panel ──────────────────────────────────────────────────

class _VehicleList extends StatelessWidget {
  final List<VehicleModel> vehicles;
  final Map<int, VehicleLocationModel> locations;
  final int? focusedVehicleId;
  final void Function(VehicleModel) onSelect;

  const _VehicleList({
    required this.vehicles,
    required this.locations,
    required this.focusedVehicleId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('المركبات (${vehicles.length})',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ),
          if (vehicles.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('لا توجد مركبات مسجلة', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: vehicles.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (_, i) {
                  final v = vehicles[i];
                  final loc = locations[v.id];
                  final isFocused = focusedVehicleId == v.id;
                  final isStale = loc?.at != null && DateTime.now().difference(loc!.at!).inSeconds > 90;

                  return InkWell(
                    onTap: loc == null ? null : () => onSelect(v),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: isFocused ? AppColors.primarySurface : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: loc == null ? AppColors.border : (isStale ? AppColors.warning : AppColors.success),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v.plateNo,
                                    style: TextStyle(
                                        fontSize: 13, fontWeight: FontWeight.w700,
                                        color: isFocused ? AppColors.primary : AppColors.textPrimary)),
                                Text(
                                  loc == null ? 'لا يوجد بث بعد' : _timeAgo(loc.at),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

String _timeAgo(DateTime? at) {
  if (at == null) return 'محدّث الآن';
  final diff = DateTime.now().difference(at);
  if (diff.inSeconds < 60) return 'قبل ${diff.inSeconds} ث';
  if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} د';
  return 'قبل ${diff.inHours} س';
}

// ── SOS banner ───────────────────────────────────────────────────────────

class _SosBanner extends StatelessWidget {
  final List<LiveSosAlertModel> alerts;
  final Map<int, VehicleModel> vehiclesById;
  const _SosBanner({required this.alerts, required this.vehiclesById});

  @override
  Widget build(BuildContext context) {
    final latest = alerts.first;
    final plate = latest.vehicleId != null ? vehiclesById[latest.vehicleId]?.plateNo : null;

    return Container(
      width: double.infinity,
      color: AppColors.sosSurface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: AppColors.sos, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              alerts.length == 1
                  ? 'استغاثة SOS من المركبة ${plate ?? "#${latest.vehicleId}"}'
                  : 'استغاثة SOS من ${alerts.length} مركبات — الأحدث: ${plate ?? "#${latest.vehicleId}"}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.sos),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.sosEvents, (route) => false),
            child: const Text('فتح صفحة SOS', style: TextStyle(fontSize: 12, color: AppColors.sos)),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.sos),
            tooltip: 'إخفاء',
            onPressed: () => context.read<TrackingCubit>().dismissAlert(latest.id),
          ),
        ],
      ),
    );
  }
}

// ── Small overlays ─────────────────────────────────────────────────────

class _ConnectionChip extends StatelessWidget {
  final RealtimeStatus status;
  const _ConnectionChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      RealtimeStatus.connected => ('مباشر', AppColors.success),
      RealtimeStatus.connecting => ('جاري الاتصال...', AppColors.warning),
      RealtimeStatus.reconnecting => ('إعادة الاتصال...', AppColors.warning),
      RealtimeStatus.disconnected => ('غير متصل', AppColors.textHint),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

class _EmptyOverlay extends StatelessWidget {
  const _EmptyOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20, left: 0, right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: const Text(
            'بانتظار بث الموقع من السائقين — تظهر المركبة فور بدء المناوبة والبث المباشر.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.textHint),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 14),
          TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh, size: 18), label: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}

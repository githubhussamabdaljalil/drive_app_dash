import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/realtime/reverb_socket_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/guest_tracking_model.dart';
import '../cubit/guest_tracking_cubit.dart';

const LatLng _fallbackCenter = LatLng(33.5138, 36.2765);

class GuestEntryScreen extends StatefulWidget {
  const GuestEntryScreen({super.key});

  @override
  State<GuestEntryScreen> createState() => _GuestEntryScreenState();
}

class _GuestEntryScreenState extends State<GuestEntryScreen> {
  final _controller = TextEditingController();
  String? _error;

  void _track() {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'الرجاء إدخال كود التتبع');
      return;
    }
    Navigator.pushNamed(context, '${AppRoutes.guestTrack}/$code');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 32),
                ),
                const SizedBox(height: 20),
                const Text(
                  'تتبع المركبة',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'أدخل كود التتبع لمعرفة موقع المركبة',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _controller,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: 'مثال: KHALED-GUEST',
                    errorText: _error,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.qr_code_outlined),
                  ),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (_) => _track(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _track,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('تتبع المركبة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tracking Screen ───────────────────────────────────────────────────────────

class GuestTrackingScreen extends StatefulWidget {
  final String guestCode;

  const GuestTrackingScreen({super.key, required this.guestCode});

  @override
  State<GuestTrackingScreen> createState() => _GuestTrackingScreenState();
}

class _GuestTrackingScreenState extends State<GuestTrackingScreen> {
  final MapController _mapController = MapController();
  bool _hasAutoCentered = false;

  @override
  void initState() {
    super.initState();
    context.read<GuestTrackingCubit>().load(widget.guestCode);
  }

  void _centerOn(GuestLocationModel loc) {
    _mapController.move(LatLng(loc.lat, loc.lng), 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'تتبع المركبة',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: BlocConsumer<GuestTrackingCubit, GuestTrackingState>(
        listener: (ctx, state) {
          if (state is GuestTrackingLoaded) {
            final loc = state.data.location;
            if (loc != null && (!_hasAutoCentered || state.hasNewLocation)) {
              _hasAutoCentered = true;
              WidgetsBinding.instance.addPostFrameCallback((_) => _centerOn(loc));
            }
          }
        },
        builder: (ctx, state) {
          if (state is GuestTrackingLoading) {
            return const _LoadingView();
          }

          if (state is GuestTrackingError) {
            return _ErrorView(
              message: state.message,
              isExpired: state.isExpired,
              onRetry: state.isExpired
                  ? () => Navigator.pushReplacementNamed(ctx, AppRoutes.guest)
                  : () => ctx.read<GuestTrackingCubit>().load(widget.guestCode),
            );
          }

          if (state is GuestTrackingLoaded) {
            return _TrackingBody(
              data: state.data,
              connection: state.connection,
              mapController: _mapController,
              onCenter: () {
                final loc = state.data.location;
                if (loc != null) _centerOn(loc);
              },
            );
          }

          return const _LoadingView();
        },
      ),
    );
  }
}

// ── Tracking Body ─────────────────────────────────────────────────────────────

class _TrackingBody extends StatelessWidget {
  final GuestTrackingModel data;
  final RealtimeStatus connection;
  final MapController mapController;
  final VoidCallback onCenter;

  const _TrackingBody({
    required this.data,
    required this.connection,
    required this.mapController,
    required this.onCenter,
  });

  @override
  Widget build(BuildContext context) {
    final loc = data.location;

    return Column(
      children: [
        _VehicleCard(vehicle: data.vehicle, expiresAt: data.expiresAt, onCenter: loc != null ? onCenter : null),
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: loc != null ? LatLng(loc.lat, loc.lng) : _fallbackCenter,
                  initialZoom: loc != null ? 15 : 12,
                  minZoom: 3,
                  maxZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.vtfms.driver_app_dash',
                  ),
                  if (loc != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(loc.lat, loc.lng),
                          width: 120,
                          height: 62,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.primary, width: 1.5),
                                  boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 1))],
                                ),
                                child: Text(
                                  data.vehicle.plateNo,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Icon(Icons.directions_car, color: AppColors.primary, size: 26),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Connection chip
              Positioned(
                top: 12,
                left: 12,
                child: _ConnectionChip(status: connection),
              ),

              // No location overlay
              if (loc == null)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
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
                        'لا يوجد موقع حالي للمركبة — بانتظار وصول الموقع...',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),

              // Last update time
              if (loc?.at != null)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'آخر تحديث: ${_formatTime(loc!.at!)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

// ── Vehicle Card ──────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  final GuestVehicleModel vehicle;
  final String? expiresAt;
  final VoidCallback? onCenter;

  const _VehicleCard({required this.vehicle, this.expiresAt, this.onCenter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.directions_car_outlined, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.plateNo,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(
                  '${vehicle.type} — ${vehicle.model}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (expiresAt != null)
            Text(
              'ينتهي: ${_formatExpiry(expiresAt!)}',
              style: const TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          if (onCenter != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.my_location, size: 20, color: AppColors.primary),
              tooltip: 'تحديد الموقع',
              onPressed: onCenter,
            ),
          ],
        ],
      ),
    );
  }

  static String _formatExpiry(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final local = dt.toLocal();
    return '${local.year}/${local.month}/${local.day}';
  }
}

// ── Connection Chip ───────────────────────────────────────────────────────────

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

// ── Loading View ──────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('جار تحميل بيانات المركبة...', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final bool isExpired;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.isExpired, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isExpired ? Icons.link_off_rounded : Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(isExpired ? Icons.keyboard_outlined : Icons.refresh, size: 18),
              label: Text(isExpired ? 'إدخال كود آخر' : 'إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

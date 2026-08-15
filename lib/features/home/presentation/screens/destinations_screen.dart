import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/constants/app_routes.dart';

import 'package:driver_app_dash/features/destinations/data/models/destination_model.dart';
import 'package:driver_app_dash/features/destinations/presentation/cubit/destination_cubit.dart';
import 'package:driver_app_dash/features/drivers/data/models/driver_model.dart';
import 'package:driver_app_dash/features/drivers/presentation/cubit/driver_cubit.dart';

class DestinationsScreen extends StatelessWidget {
  const DestinationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: AppRoutes.destinations,
      pageTitle: 'الوجهات',
      body: const _DestinationsBody(),
    );
  }
}

const _statusOptions = <String, String>{
  '': 'كل الحالات',
  'sent': 'مرسلة',
  'accepted': 'مقبولة',
  'rejected': 'مرفوضة',
  'cancelled': 'ملغاة',
  'completed': 'مكتملة',
};

class _DestinationsBody extends StatefulWidget {
  const _DestinationsBody();

  @override
  State<_DestinationsBody> createState() => _DestinationsBodyState();
}

class _DestinationsBodyState extends State<_DestinationsBody> {
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    context.read<DestinationCubit>().load();
    // Needed for driver picker in the assignment dialog.
    context.read<DriverCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DestinationCubit, DestinationState>(
      listener: (ctx, state) {
        if (state is DestinationError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      builder: (ctx, state) {
        final destinations = switch (state) {
          DestinationLoaded() => state.destinations,
          DestinationSubmitting() => state.destinations,
          DestinationError() => state.destinations ?? [],
          _ => <DestinationModel>[],
        };

        final filtered = _statusFilter.isEmpty
            ? destinations
            : destinations.where((d) => d.status == _statusFilter).toList();

        final isLoading = state is DestinationLoading;
        final isSubmitting = state is DestinationSubmitting;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('إدارة الوجهات',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 3),
                        Text('${destinations.length} وجهة مسجلة', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  AppButton(label: 'إرسال وجهة', icon: Icons.add_location_alt_outlined, width: 160, height: 40, onPressed: () => _showForm(ctx)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('تصفية:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(width: 10),
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _statusFilter,
                        items: _statusOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (v) => setState(() => _statusFilter = v ?? ''),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? _EmptyState(onAdd: () => _showForm(ctx))
                        : _DestinationTable(
                            destinations: filtered,
                            isSubmitting: isSubmitting,
                            onEdit: (d) => _showForm(ctx, destination: d),
                            onCancel: (d) => _confirmCancel(ctx, d),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showForm(BuildContext context, {DestinationModel? destination}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<DestinationCubit>()),
          BlocProvider.value(value: context.read<DriverCubit>()),
        ],
        child: _DestinationFormDialog(destination: destination),
      ),
    );
  }

  void _confirmCancel(BuildContext context, DestinationModel destination) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 22),
          SizedBox(width: 8),
          Text('إلغاء الوجهة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        content: const Text(
          'سيتم إلغاء هذه الوجهة وإشعار السائق بذلك. هل تريد المتابعة؟',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('تراجع', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DestinationCubit>().cancel(destination.id);
            },
            child: const Text('إلغاء الوجهة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _DestinationTable extends StatelessWidget {
  final List<DestinationModel> destinations;
  final bool isSubmitting;
  final void Function(DestinationModel) onEdit;
  final void Function(DestinationModel) onCancel;

  const _DestinationTable({required this.destinations, required this.isSubmitting, required this.onEdit, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(12)), border: Border(bottom: BorderSide(color: AppColors.border))),
            child: const Row(children: [
              Expanded(flex: 2, child: _HeaderCell('السائق')),
              Expanded(flex: 2, child: _HeaderCell('المركبة')),
              Expanded(flex: 3, child: _HeaderCell('الإحداثيات')),
              Expanded(flex: 2, child: _HeaderCell('الحالة', centered: true)),
              SizedBox(width: 90, child: _HeaderCell('إجراءات', centered: true)),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: destinations.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (_, i) {
                final d = destinations[i];
                return Opacity(
                  opacity: isSubmitting ? .6 : 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(children: [
                      Expanded(flex: 2, child: Text(d.driverName ?? (d.driverId?.toString() ?? '—'), style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text(d.vehiclePlate ?? '—', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                      Expanded(flex: 3, child: Text('${d.targetLat.toStringAsFixed(5)}, ${d.targetLng.toStringAsFixed(5)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                      Expanded(flex: 2, child: Center(child: _StatusChip(status: d.status))),
                      SizedBox(
                        width: 90,
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          if (d.isOpen) _ActionBtn(icon: Icons.edit_outlined, color: AppColors.primary, tooltip: 'تعديل', onTap: () => onEdit(d)),
                          if (d.isOpen) const SizedBox(width: 6),
                          if (d.isOpen) _ActionBtn(icon: Icons.close, color: AppColors.danger, tooltip: 'إلغاء', onTap: () => onCancel(d)),
                        ]),
                      ),
                    ]),
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

class _HeaderCell extends StatelessWidget {
  final String label;
  final bool centered;
  const _HeaderCell(this.label, {this.centered = false});
  @override
  Widget build(BuildContext context) => Text(label, textAlign: centered ? TextAlign.center : TextAlign.start, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary));
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'accepted' => ('مقبولة', AppColors.success),
      'rejected' => ('مرفوضة', AppColors.danger),
      'cancelled' => ('ملغاة', AppColors.textHint),
      'completed' => ('مكتملة', AppColors.primary),
      _ => ('مرسلة', AppColors.warning),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.tooltip, required this.onTap});
  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(.08), borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 16, color: color)),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 72, height: 72, decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.add_location_alt_outlined, size: 36, color: AppColors.primary)),
          const SizedBox(height: 16),
          const Text('لا توجد وجهات بعد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('أرسل أول وجهة لأحد السائقين', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          AppButton(label: 'إرسال وجهة', icon: Icons.add, width: 160, height: 40, onPressed: onAdd),
        ]),
      );
}

class _DestinationFormDialog extends StatefulWidget {
  final DestinationModel? destination;
  const _DestinationFormDialog({this.destination});

  @override
  State<_DestinationFormDialog> createState() => _DestinationFormDialogState();
}

class _DestinationFormDialogState extends State<_DestinationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  int? _driverId;

  bool _isSubmitting = false;
  String? _errorText;

  bool get _isEdit => widget.destination != null;

  @override
  void initState() {
    super.initState();
    final d = widget.destination;
    _lat = TextEditingController(text: d?.targetLat.toString() ?? '');
    _lng = TextEditingController(text: d?.targetLng.toString() ?? '');
    _driverId = d?.driverId;
  }

  @override
  void dispose() {
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEdit && _driverId == null) {
      setState(() => _errorText = 'اختر السائق');
      return;
    }
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final cubit = context.read<DestinationCubit>();
    final lat = double.tryParse(_lat.text.trim()) ?? 0;
    final lng = double.tryParse(_lng.text.trim()) ?? 0;

    final success = _isEdit
        ? await cubit.update(widget.destination!.id, targetLat: lat, targetLng: lng)
        : await cubit.create(driverId: _driverId, targetLat: lat, targetLng: lng);

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      final state = cubit.state;
      setState(() {
        _isSubmitting = false;
        _errorText = state is DestinationError ? state.message : 'حدث خطأ، حاول مرة أخرى';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isEdit ? 'تعديل الوجهة' : 'إرسال وجهة لسائق', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 18),

                if (!_isEdit) ...[
                  const Text('السائق', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  BlocBuilder<DriverCubit, DriverState>(
                    builder: (ctx, state) {
                      final drivers = switch (state) {
                        DriverLoaded() => state.drivers,
                        DriverSubmitting() => state.drivers,
                        DriverError() => state.drivers ?? [],
                        _ => <DriverModel>[],
                      };
                      return Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: AppColors.surfaceInput, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _driverId,
                            isExpanded: true,
                            hint: const Text('اختر السائق', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                            items: drivers.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (v) => setState(() => _driverId = v),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Map picker button ──────────────────────────────
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDialog<LatLng>(
                      context: context,
                      builder: (_) => _MapPickerDialog(
                        initial: (_lat.text.isNotEmpty && _lng.text.isNotEmpty)
                            ? LatLng(
                                double.tryParse(_lat.text) ?? 33.5138,
                                double.tryParse(_lng.text) ?? 36.2765,
                              )
                            : null,
                      ),
                    );
                    if (picked != null) {
                      setState(() {
                        _lat.text = picked.latitude.toStringAsFixed(6);
                        _lng.text = picked.longitude.toStringAsFixed(6);
                      });
                    }
                  },
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text('اختر من الخريطة', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 42)),
                ),
                const SizedBox(height: 14),

                AppTextField(
                  label: 'خط العرض (Latitude)',
                  hint: '33.5138',
                  controller: _lat,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  validator: (v) => (double.tryParse(v?.trim() ?? '') == null) ? 'قيمة غير صالحة' : null,
                ),
                const SizedBox(height: 14),

                AppTextField(
                  label: 'خط الطول (Longitude)',
                  hint: '36.2765',
                  controller: _lng,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  validator: (v) => (double.tryParse(v?.trim() ?? '') == null) ? 'قيمة غير صالحة' : null,
                ),
                const SizedBox(height: 14),

                if (_errorText != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.dangerSurface, borderRadius: BorderRadius.circular(8)),
                    child: Text(_errorText!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
                  ),
                  const SizedBox(height: 14),
                ],

                Row(children: [
                  Expanded(child: TextButton(onPressed: _isSubmitting ? null : () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)))),
                  const SizedBox(width: 10),
                  Expanded(child: AppButton(label: _isEdit ? 'حفظ' : 'إرسال', isLoading: _isSubmitting, onPressed: _submit)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MAP PICKER DIALOG
// ============================================================================

class _MapPickerDialog extends StatefulWidget {
  final LatLng? initial;
  const _MapPickerDialog({this.initial});

  @override
  State<_MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<_MapPickerDialog> {
  static const _defaultCenter = LatLng(33.5138, 36.2765);

  late LatLng? _picked;

  @override
  void initState() {
    super.initState();
    _picked = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final center = _picked ?? widget.initial ?? _defaultCenter;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 560),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('اختر الوجهة من الخريطة',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        Text('اضغط على أي نقطة لتحديدها',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: AppColors.textHint),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ── Map ─────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: _picked != null ? 14 : 11,
                      minZoom: 3,
                      maxZoom: 18,
                      onTap: (_, point) => setState(() => _picked = point),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.vtfms.driver_app_dash',
                      ),
                      if (_picked != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _picked!,
                              width: 40,
                              height: 48,
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on, color: AppColors.danger, size: 36),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Coordinates overlay
                  if (_picked != null)
                    Positioned(
                      top: 12,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2))],
                          ),
                          child: Text(
                            '${_picked!.latitude.toStringAsFixed(6)},  ${_picked!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            textDirection: TextDirection.ltr,
                          ),
                        ),
                      ),
                    ),

                  // Hint when nothing picked
                  if (_picked == null)
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
                          ),
                          child: const Text(
                            'اضغط على الخريطة لتحديد الوجهة',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Footer ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _picked == null ? null : () => Navigator.pop(context, _picked),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('تأكيد الموقع', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.border,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 42),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

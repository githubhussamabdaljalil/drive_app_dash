import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_routes.dart';

import 'package:driver_app_dash/features/guest_codes/data/models/guest_code_model.dart';
import 'package:driver_app_dash/features/guest_codes/presentation/cubit/guest_code_cubit.dart';
import 'package:driver_app_dash/features/vehicles/data/models/vehicle_model.dart';
import 'package:driver_app_dash/features/vehicles/presentation/cubit/vehicle_cubit.dart';

// Builds the tracking URL for a given guest code.
String _buildTrackingUrl(String code) {
  final origin = Uri.base.origin;
  return '$origin/#${AppRoutes.guestTrack}/$code';
}

class GuestCodesScreen extends StatelessWidget {
  const GuestCodesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: AppRoutes.guestCodes,
      pageTitle: 'رموز الضيوف',
      body: const _GuestCodesBody(),
    );
  }
}

class _GuestCodesBody extends StatefulWidget {
  const _GuestCodesBody();

  @override
  State<_GuestCodesBody> createState() => _GuestCodesBodyState();
}

class _GuestCodesBodyState extends State<_GuestCodesBody> {
  @override
  void initState() {
    super.initState();
    context.read<GuestCodeCubit>().load();
    context.read<VehicleCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GuestCodeCubit, GuestCodeState>(
      listener: (ctx, state) {
        if (state is GuestCodeError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      builder: (ctx, state) {
        final codes = switch (state) {
          GuestCodeLoaded() => state.codes,
          GuestCodeSubmitting() => state.codes,
          GuestCodeError() => state.codes ?? [],
          _ => <GuestCodeModel>[],
        };

        final isLoading = state is GuestCodeLoading;
        final isSubmitting = state is GuestCodeSubmitting;

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
                        const Text('رموز تتبع الضيوف',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 3),
                        Text('${codes.length} رمز', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  AppButton(
                    label: 'إنشاء رمز',
                    icon: Icons.add,
                    width: 150,
                    height: 40,
                    onPressed: () => _showCreateDialog(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : codes.isEmpty
                        ? const _EmptyState()
                        : ListView.separated(
                            itemCount: codes.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => Opacity(
                              opacity: isSubmitting ? .6 : 1,
                              child: _GuestCodeCard(
                                code: codes[i],
                                onShare: () => _showShareDialog(ctx, codes[i]),
                                onRevoke: codes[i].isActive ? () => _confirmRevoke(ctx, codes[i]) : null,
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

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<GuestCodeCubit>()),
          BlocProvider.value(value: context.read<VehicleCubit>()),
        ],
        child: const _GuestCodeFormDialog(),
      ),
    );
  }

  void _showShareDialog(BuildContext context, GuestCodeModel code) {
    showDialog(
      context: context,
      builder: (_) => _ShareLinkDialog(code: code),
    );
  }

  void _confirmRevoke(BuildContext context, GuestCodeModel code) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('إلغاء رمز الضيف', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(
          'هل تريد إلغاء رمز الضيف الخاص بالمركبة "${code.vehiclePlate ?? code.vehicleId}"؟',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء الأمر')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GuestCodeCubit>().revoke(code.id);
            },
            child: const Text('إلغاء الرمز', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// GUEST CODE CARD
// ============================================================================

class _GuestCodeCard extends StatelessWidget {
  final GuestCodeModel code;
  final VoidCallback onShare;
  final VoidCallback? onRevoke;

  const _GuestCodeCard({required this.code, required this.onShare, this.onRevoke});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (code.status) {
      'active' => ('نشط', AppColors.success),
      'expired' => ('منتهي', AppColors.textHint),
      'revoked' => ('ملغى', AppColors.danger),
      _ => (code.status, AppColors.textHint),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.qr_code_outlined, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  SelectableText(code.code, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text('المركبة: ${code.vehiclePlate ?? '#${code.vehicleId}'}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                if (code.expiresAt != null)
                  Text('ينتهي: ${code.expiresAt}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ],
            ),
          ),
          // Share button — always visible for active codes
          if (code.isActive)
            IconButton(
              onPressed: onShare,
              icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.primary),
              tooltip: 'مشاركة الرابط والـ QR',
            ),
          if (onRevoke != null)
            TextButton.icon(
              onPressed: onRevoke,
              icon: const Icon(Icons.block_outlined, size: 16, color: AppColors.danger),
              label: const Text('إلغاء', style: TextStyle(color: AppColors.danger, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.qr_code_outlined, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('لا توجد رموز ضيوف بعد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('أنشئ رمزاً لمشاركة موقع مركبة مع ضيف دون تسجيل دخول', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ]),
      );
}

// ============================================================================
// CREATE FORM
// ============================================================================

class _GuestCodeFormDialog extends StatefulWidget {
  const _GuestCodeFormDialog();

  @override
  State<_GuestCodeFormDialog> createState() => _GuestCodeFormDialogState();
}

class _GuestCodeFormDialogState extends State<_GuestCodeFormDialog> {
  VehicleModel? _vehicle;
  int _minutes = 60;
  bool _isSubmitting = false;
  String? _errorText;

  static const _presets = [15, 30, 60, 120, 360, 1440];

  Future<void> _submit() async {
    if (_vehicle == null) {
      setState(() => _errorText = 'اختر مركبة أولاً');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final created = await context.read<GuestCodeCubit>().create(
      vehicleId: _vehicle!.id,
      expiresInMinutes: _minutes,
    );

    if (!mounted) return;

    if (created != null) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => _ShareLinkDialog(code: created),
      );
    } else {
      final state = context.read<GuestCodeCubit>().state;
      setState(() {
        _isSubmitting = false;
        _errorText = state is GuestCodeError ? state.message : 'حدث خطأ، حاول مرة أخرى';
      });
    }
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

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إنشاء رمز ضيف', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 18),

                  const Text('المركبة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceInput,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<VehicleModel>(
                        value: _vehicle,
                        isExpanded: true,
                        hint: const Text('اختر مركبة', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                        items: vehicles
                            .map((v) => DropdownMenuItem(value: v, child: Text(v.plateNo, style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (v) => setState(() => _vehicle = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('مدة الصلاحية', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presets.map((m) {
                      final selected = _minutes == m;
                      return ChoiceChip(
                        label: Text(_formatMinutes(m), style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.textSecondary)),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                        onSelected: (_) => setState(() => _minutes = m),
                      );
                    }).toList(),
                  ),

                  if (_errorText != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.dangerSurface, borderRadius: BorderRadius.circular(8)),
                      child: Text(_errorText!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
                    ),
                  ],

                  const SizedBox(height: 18),
                  Row(children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                        child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: AppButton(label: 'إنشاء', isLoading: _isSubmitting, onPressed: _submit)),
                  ]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatMinutes(int m) {
    if (m < 60) return '$m دقيقة';
    if (m < 1440) return '${m ~/ 60} ساعة';
    return '${m ~/ 1440} يوم';
  }
}

// ============================================================================
// SHARE LINK DIALOG  —  رابط + QR
// ============================================================================

class _ShareLinkDialog extends StatelessWidget {
  final GuestCodeModel code;

  const _ShareLinkDialog({required this.code});

  @override
  Widget build(BuildContext context) {
    final url = _buildTrackingUrl(code.code);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.share_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('مشاركة رمز التتبع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        Text(code.code, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: AppColors.textHint),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── QR Code ───────────────────────────────────────────
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: QrImageView(
                    data: url,
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Center(
                child: Text('امسح الـ QR لفتح صفحة التتبع مباشرة',
                    style: TextStyle(fontSize: 11, color: AppColors.textHint)),
              ),

              const SizedBox(height: 20),

              // ── Link ──────────────────────────────────────────────
              const Text('رابط التتبع', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: SelectableText(
                  url,
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  textDirection: TextDirection.ltr,
                ),
              ),

              if (code.expiresAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined, size: 13, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text('ينتهي: ${code.expiresAt}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // ── Copy button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ الرابط'),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  label: const Text('نسخ الرابط', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

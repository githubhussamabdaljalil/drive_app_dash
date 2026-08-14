import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_routes.dart';
import 'package:driver_app_dash/features/vehicles/data/models/vehicle_model.dart';
import 'package:driver_app_dash/features/vehicles/presentation/cubit/vehicle_cubit.dart';
import 'package:driver_app_dash/features/qr_codes/presentation/cubit/qr_code_cubit.dart';

class QrCodesScreen extends StatelessWidget {
  const QrCodesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: AppRoutes.qrCodes,
      pageTitle: 'رموز QR',
      body: const _QrCodesBody(),
    );
  }
}

class _QrCodesBody extends StatefulWidget {
  const _QrCodesBody();

  @override
  State<_QrCodesBody> createState() => _QrCodesBodyState();
}

class _QrCodesBodyState extends State<_QrCodesBody> {
  VehicleModel? _selected;

  @override
  void initState() {
    super.initState();

    context.read<VehicleCubit>().load();
  }

  void _selectVehicle(VehicleModel vehicle) {
    setState(() {
      _selected = vehicle;
    });

    context.read<QrCodeCubit>().load(vehicle.id);
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

        final isLoadingVehicles = vState is VehicleLoading;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =============================================================
              // Page Title
              // =============================================================
              const Text(
                'رموز QR للمركبات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 3),

              const Text(
                'اختر مركبة لعرض أو توليد أو إلغاء رمز الربط الخاص بها',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 20),

              // =============================================================
              // Loading Vehicles
              // =============================================================
              if (isLoadingVehicles)
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              // =============================================================
              // Empty Vehicles
              // =============================================================
              else if (vehicles.isEmpty)
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'لا توجد مركبات مسجلة بعد — أضف مركبة أولاً من صفحة المركبات.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
              // =============================================================
              // Main Content
              // =============================================================
              else
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =======================================================
                      // Vehicle List
                      // =======================================================
                      SizedBox(
                        width: 260,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(6),
                            itemCount: vehicles.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              color: AppColors.divider,
                            ),
                            itemBuilder: (_, i) {
                              final vehicle = vehicles[i];

                              final isSelected = _selected?.id == vehicle.id;

                              return InkWell(
                                onTap: () => _selectVehicle(vehicle),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primarySurface
                                        : null,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicle.plateNo,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                      ),

                                      if (vehicle.model != null)
                                        Text(
                                          vehicle.model!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // =======================================================
                      // QR Panel
                      // =======================================================
                      Expanded(
                        child: _selected == null
                            ? const _NoSelection()
                            : _QrPanel(vehicle: _selected!),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ===========================================================================
// No Vehicle Selected
// ===========================================================================

class _NoSelection extends StatelessWidget {
  const _NoSelection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'اختر مركبة من القائمة',
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }
}

// ===========================================================================
// QR Panel
// ===========================================================================

class _QrPanel extends StatelessWidget {
  final VehicleModel vehicle;

  const _QrPanel({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QrCodeCubit, QrCodeState>(
      listener: (ctx, state) {
        if (state is QrCodeError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },

      builder: (ctx, state) {
        final isLoading = state is QrCodeLoading;
        final isSubmitting = state is QrCodeSubmitting;

        final code = switch (state) {
          QrCodeLoaded() => state.code,
          QrCodeSubmitting() => state.code,
          QrCodeError() => state.code,
          _ => null,
        };

        // ================================================================
        // IMPORTANT:
        // SingleChildScrollView prevents Bottom Overflow when the
        // available height is smaller than the QR content.
        // ================================================================

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================================
                // Vehicle Information
                // ==========================================================
                Text(
                  vehicle.plateNo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                if (vehicle.model != null) ...[
                  const SizedBox(height: 4),

                  Text(
                    vehicle.model!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // ==========================================================
                // Loading
                // ==========================================================
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(),
                    ),
                  )
                // ==========================================================
                // No QR Code
                // ==========================================================
                else if (code == null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'لا يوجد رمز نشط لهذه المركبة بعد.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      AppButton(
                        label: 'توليد رمز جديد',
                        icon: Icons.qr_code_2_outlined,
                        width: 220,
                        isLoading: isSubmitting,
                        onPressed: () {
                          ctx.read<QrCodeCubit>().generate(vehicle.id);
                        },
                      ),
                    ],
                  )
                // ==========================================================
                // QR Code Exists
                // ==========================================================
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ======================================================
                      // QR Code
                      // ======================================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            QrImageView(
                              data: code.code,
                              version: QrVersions.auto,
                              size: 250,
                              backgroundColor: Colors.white,
                              errorCorrectionLevel: QrErrorCorrectLevel.M,
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              'امسح رمز QR لربط المركبة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Actual QR code text
                            SelectableText(
                              code.code,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ======================================================
                      // Created At
                      // ======================================================
                      if (code.createdAt != null)
                        Text(
                          'أُنشئ: ${code.createdAt}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),

                      const SizedBox(height: 16),

                      // ======================================================
                      // Actions
                      // ======================================================
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'إعادة توليد',
                              icon: Icons.refresh,
                              backgroundColor: AppColors.primary,
                              isLoading: isSubmitting,
                              onPressed: () {
                                ctx.read<QrCodeCubit>().generate(vehicle.id);
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: AppButton(
                              label: 'إلغاء الرمز',
                              icon: Icons.block_outlined,
                              backgroundColor: AppColors.danger,
                              isLoading: isSubmitting,
                              onPressed: () {
                                ctx.read<QrCodeCubit>().revoke(vehicle.id);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'إعادة التوليد تُبطل الرمز الحالي فوراً ولا يعود يعمل بعدها.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_routes.dart';
import '../../data/models/vehicle_model.dart';
import '../cubit/vehicle_cubit.dart';
import '../widgets/vehicle_table.dart';
import '../widgets/vehicle_empty_state.dart';
import '../widgets/vehicle_form_dialog.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: AppRoutes.vehicles,
      pageTitle: 'المركبات',
      body: const _VehiclesBody(),
    );
  }
}

const _statusOptions = <String, String>{
  '': 'كل الحالات',
  'active': 'نشطة',
  'inactive': 'غير نشطة',
  'maintenance': 'صيانة',
  'out_of_service': 'خارج الخدمة',
};

class _VehiclesBody extends StatefulWidget {
  const _VehiclesBody();

  @override
  State<_VehiclesBody> createState() => _VehiclesBodyState();
}

class _VehiclesBodyState extends State<_VehiclesBody> {
  String _search = '';
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    context.read<VehicleCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VehicleCubit, VehicleState>(
      listener: (ctx, state) {
        if (state is VehicleError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      builder: (ctx, state) {
        final vehicles = _vehiclesOf(state);
        final filtered = _applyFilters(vehicles, _search, _statusFilter);
        final isLoading = state is VehicleLoading;
        final isSubmitting = state is VehicleSubmitting;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(count: vehicles.length, onAdd: () => _showForm(ctx)),
              const SizedBox(height: 20),
              _FiltersRow(
                statusFilter: _statusFilter,
                onSearchChanged: (v) => setState(() => _search = v),
                onStatusChanged: (v) => setState(() => _statusFilter = v),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? VehicleEmptyState(onAdd: () => _showForm(ctx))
                        : VehicleTable(
                            vehicles: filtered,
                            isSubmitting: isSubmitting,
                            onEdit: (v) => _showForm(ctx, vehicle: v),
                            onDelete: (v) => _confirmDelete(ctx, v),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  static List<VehicleModel> _vehiclesOf(VehicleState state) => switch (state) {
        VehicleLoaded() => state.vehicles,
        VehicleSubmitting() => state.vehicles,
        VehicleError() => state.vehicles ?? const [],
        _ => const <VehicleModel>[],
      };

  static List<VehicleModel> _applyFilters(List<VehicleModel> vehicles, String search, String status) {
    final query = search.trim().toLowerCase();
    return vehicles.where((v) {
      final matchesSearch = query.isEmpty ||
          v.plateNo.toLowerCase().contains(query) ||
          (v.model?.toLowerCase().contains(query) ?? false) ||
          (v.type?.toLowerCase().contains(query) ?? false);
      final matchesStatus = status.isEmpty || v.status == status;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showForm(BuildContext context, {VehicleModel? vehicle}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<VehicleCubit>(),
        child: VehicleFormDialog(vehicle: vehicle),
      ),
    );
  }

  void _confirmDelete(BuildContext context, VehicleModel vehicle) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 22),
          SizedBox(width: 8),
          Text('تأكيد الحذف', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        content: Text(
          'هل أنت متأكد من حذف المركبة "${vehicle.plateNo}"؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<VehicleCubit>().delete(vehicle.id);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int count;
  final VoidCallback onAdd;
  const _Header({required this.count, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إدارة المركبات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 3),
              Text('$count مركبة مسجلة', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
        AppButton(label: 'إضافة مركبة', icon: Icons.add, width: 150, height: 40, onPressed: onAdd),
      ],
    );
  }
}

class _FiltersRow extends StatelessWidget {
  final String statusFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusChanged;

  const _FiltersRow({required this.statusFilter, required this.onSearchChanged, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'بحث برقم اللوحة أو الموديل أو النوع...',
                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textHint),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: statusFilter,
              items: _statusOptions.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (v) => onStatusChanged(v ?? ''),
            ),
          ),
        ),
      ],
    );
  }
}

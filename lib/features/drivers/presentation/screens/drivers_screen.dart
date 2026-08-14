import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_routes.dart';
import '../../data/models/driver_model.dart';
import '../cubit/driver_cubit.dart';
import '../widgets/driver_table.dart';
import '../widgets/driver_empty_state.dart';
import '../widgets/driver_form_dialog.dart';
import '../widgets/temp_password_dialog.dart';

class DriversScreen extends StatelessWidget {
  const DriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: AppRoutes.drivers,
      pageTitle: 'السائقون',
      body: const _DriversBody(),
    );
  }
}

const _statusOptions = <String, String>{
  '': 'كل الحالات',
  'active': 'نشط',
  'inactive': 'غير نشط',
};

class _DriversBody extends StatefulWidget {
  const _DriversBody();

  @override
  State<_DriversBody> createState() => _DriversBodyState();
}

class _DriversBodyState extends State<_DriversBody> {
  String _search = '';
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    context.read<DriverCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverCubit, DriverState>(
      listener: (ctx, state) {
        if (state is DriverError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      builder: (ctx, state) {
        final drivers = _driversOf(state);
        final filtered = _applyFilters(drivers, _search, _statusFilter);
        final isLoading = state is DriverLoading;
        final isSubmitting = state is DriverSubmitting;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(count: drivers.length, onAdd: () => _showForm(ctx)),
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
                        ? DriverEmptyState(onAdd: () => _showForm(ctx))
                        : DriverTable(
                            drivers: filtered,
                            isSubmitting: isSubmitting,
                            onEdit: (d) => _showForm(ctx, driver: d),
                            onDelete: (d) => _confirmDelete(ctx, d),
                            onResetPassword: (d) => _resetPassword(ctx, d),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  static List<DriverModel> _driversOf(DriverState state) => switch (state) {
        DriverLoaded() => state.drivers,
        DriverSubmitting() => state.drivers,
        DriverError() => state.drivers ?? const [],
        _ => const <DriverModel>[],
      };

  static List<DriverModel> _applyFilters(List<DriverModel> drivers, String search, String status) {
    final query = search.trim().toLowerCase();
    return drivers.where((d) {
      final matchesSearch = query.isEmpty ||
          d.name.toLowerCase().contains(query) ||
          d.phone.toLowerCase().contains(query) ||
          (d.email?.toLowerCase().contains(query) ?? false);
      final matchesStatus = status.isEmpty || d.status == status;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> _showForm(BuildContext context, {DriverModel? driver}) async {
    // A non-null result only comes back from a successful "create" —
    // (driver name, one-time temporary password).
    final result = await showDialog<(String, String)>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<DriverCubit>(),
        child: DriverFormDialog(driver: driver),
      ),
    );

    if (result != null && context.mounted) {
      showTempPasswordDialog(context, driverName: result.$1, tempPassword: result.$2);
    }
  }

  void _confirmDelete(BuildContext context, DriverModel driver) {
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
          'هل أنت متأكد من حذف السائق "${driver.name}"؟\nسيتم إنهاء ربطه بأي مركبة وإلغاء جلساته الحالية. لا يمكن التراجع عن هذا الإجراء.',
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
              context.read<DriverCubit>().delete(driver.id);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _resetPassword(BuildContext context, DriverModel driver) async {
    final cubit = context.read<DriverCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('إعادة تعيين كلمة المرور', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(
          'سيتم إنشاء كلمة مرور مؤقتة جديدة لـ "${driver.name}" وإلغاء كل جلساته الحالية. هل تريد المتابعة؟',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('متابعة')),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final tempPassword = await cubit.resetPassword(driver.id);
    if (!context.mounted || tempPassword == null) return;

    showTempPasswordDialog(context, driverName: driver.name, tempPassword: tempPassword);
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
              const Text('إدارة السائقين', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 3),
              Text('$count سائق مسجل', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
        AppButton(label: 'إضافة سائق', icon: Icons.add, width: 150, height: 40, onPressed: onAdd),
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
                hintText: 'بحث بالاسم أو رقم الهاتف أو البريد...',
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

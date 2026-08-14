import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../drivers/presentation/cubit/driver_cubit.dart';
import '../../../vehicles/presentation/cubit/vehicle_cubit.dart';
import '../cubit/manager_reports_cubit.dart';

/// Vehicle / driver / date-range filters — every change re-fetches the
/// report from GET /admin/manager/reports with the matching query params.
class ManagerReportsFilterBar extends StatefulWidget {
  const ManagerReportsFilterBar({super.key});

  @override
  State<ManagerReportsFilterBar> createState() => _ManagerReportsFilterBarState();
}

class _ManagerReportsFilterBarState extends State<ManagerReportsFilterBar> {
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    // Vehicles/drivers are almost certainly already loaded elsewhere in the
    // dashboard, but load() is cheap/idempotent and this screen shouldn't
    // assume load order.
    context.read<VehicleCubit>().load();
    context.read<DriverCubit>().load();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: _range,
    );
    if (picked == null) return;
    setState(() => _range = picked);
    final fmt = (DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (!mounted) return;
    context.read<ManagerReportsCubit>().load(dateFrom: fmt(picked.start), dateTo: fmt(picked.end));
  }

  @override
  Widget build(BuildContext context) {
    final vehicleState = context.watch<VehicleCubit>().state;
    final driverState = context.watch<DriverCubit>().state;
    final vehicles = vehicleState is VehicleLoaded ? vehicleState.vehicles : const [];
    final drivers = driverState is DriverLoaded ? driverState.drivers : const [];
    final cubit = context.watch<ManagerReportsCubit>();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _FilterDropdown<int?>(
          hint: 'كل المركبات',
          value: cubit.vehicleId,
          items: [
            const DropdownMenuItem(value: null, child: Text('كل المركبات')),
            ...vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text(v.plateNo))),
          ],
          onChanged: (v) => context.read<ManagerReportsCubit>().load(vehicleId: v),
        ),
        _FilterDropdown<int?>(
          hint: 'كل السائقين',
          value: cubit.driverId,
          items: [
            const DropdownMenuItem(value: null, child: Text('كل السائقين')),
            ...drivers.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
          ],
          onChanged: (v) => context.read<ManagerReportsCubit>().load(driverId: v),
        ),
        OutlinedButton.icon(
          onPressed: _pickRange,
          icon: const Icon(Icons.date_range_outlined, size: 16),
          label: Text(
            _range == null ? 'الفترة الزمنية' : '${_range!.start.year}/${_range!.start.month}/${_range!.start.day} → ${_range!.end.year}/${_range!.end.month}/${_range!.end.day}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        if (cubit.vehicleId != null || cubit.driverId != null || _range != null)
          TextButton.icon(
            onPressed: () {
              setState(() => _range = null);
              context.read<ManagerReportsCubit>().clearFilters();
            },
            icon: const Icon(Icons.close, size: 15),
            label: const Text('مسح الفلاتر', style: TextStyle(fontSize: 12)),
          ),
      ],
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final String hint;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;

  const _FilterDropdown({required this.hint, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 12)),
          isDense: true,
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          items: items,
          onChanged: (v) => onChanged(v as T),
        ),
      ),
    );
  }
}

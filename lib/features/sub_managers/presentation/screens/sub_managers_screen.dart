import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_routes.dart';
import '../../data/models/sub_manager_model.dart';
import '../cubit/sub_manager_cubit.dart';
import '../widgets/sub_manager_card.dart';
import '../widgets/sub_manager_empty_state.dart';
import '../widgets/sub_manager_retry_banner.dart';
import '../widgets/sub_manager_form_dialog.dart';
import '../widgets/sub_manager_permissions_dialog.dart';

class SubManagersScreen extends StatelessWidget {
  const SubManagersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: AppRoutes.subManagers,
      pageTitle: 'المدراء الفرعيون',
      body: const _SubManagersBody(),
    );
  }
}

class _SubManagersBody extends StatefulWidget {
  const _SubManagersBody();

  @override
  State<_SubManagersBody> createState() => _SubManagersBodyState();
}

class _SubManagersBodyState extends State<_SubManagersBody> {
  @override
  void initState() {
    super.initState();
    context.read<SubManagerCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubManagerCubit, SubManagerState>(
      listener: (ctx, state) {
        if (state is SubManagerError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      builder: (ctx, state) {
        final subManagers = _listOf(state);
        final catalog = _catalogOf(state);
        final isLoading = state is SubManagerLoading;
        final isSubmitting = state is SubManagerSubmitting;
        final canAdd = catalog.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                count: subManagers.length,
                canAdd: canAdd,
                onAdd: () => _showForm(ctx, catalog: catalog),
              ),
              const SizedBox(height: 16),
              if (state is SubManagerError && catalog.isEmpty)
                SubManagerRetryBanner(
                  message: state.message,
                  onRetry: () => ctx.read<SubManagerCubit>().load(),
                ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : subManagers.isEmpty
                    ? SubManagerEmptyState(
                        onAdd: canAdd
                            ? () => _showForm(ctx, catalog: catalog)
                            : null,
                      )
                    : _SubManagerList(
                        subManagers: subManagers,
                        catalog: catalog,
                        isSubmitting: isSubmitting,
                        onEditInfo: (sm) =>
                            _showForm(ctx, catalog: catalog, subManager: sm),
                        onEditPermissions: (sm) => _showPermissions(
                          ctx,
                          catalog: catalog,
                          subManager: sm,
                        ),
                        onResetTotp: (sm) => _confirmResetTotp(ctx, sm),
                        onDelete: (sm) => _confirmDelete(ctx, sm),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  static List<SubManagerModel> _listOf(SubManagerState state) =>
      switch (state) {
        SubManagerLoaded() => state.subManagers,
        SubManagerSubmitting() => state.subManagers,
        SubManagerError() => state.subManagers,
        _ => const <SubManagerModel>[],
      };

  static List<PermissionOption> _catalogOf(SubManagerState state) =>
      switch (state) {
        SubManagerLoaded() => state.permissionCatalog,
        SubManagerSubmitting() => state.permissionCatalog,
        SubManagerError() => state.permissionCatalog,
        _ => const <PermissionOption>[],
      };

  void _showForm(
    BuildContext context, {
    required List<PermissionOption> catalog,
    SubManagerModel? subManager,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<SubManagerCubit>(),
        child: SubManagerFormDialog(catalog: catalog, subManager: subManager),
      ),
    );
  }

  void _showPermissions(
    BuildContext context, {
    required List<PermissionOption> catalog,
    required SubManagerModel subManager,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<SubManagerCubit>(),
        child: SubManagerPermissionsDialog(
          catalog: catalog,
          subManager: subManager,
        ),
      ),
    );
  }

  void _confirmResetTotp(BuildContext context, SubManagerModel subManager) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.lock_reset, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'إعادة تعيين TOTP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'هل تريد إعادة تعيين رمز TOTP لـ "${subManager.name}"؟',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await context.read<SubManagerCubit>().resetTotp(
                subManager.id,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'تم إعادة تعيين TOTP بنجاح'
                        : 'فشل إعادة تعيين TOTP',
                  ),
                  backgroundColor: success
                      ? AppColors.success
                      : AppColors.danger,
                ),
              );
            },
            child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, SubManagerModel subManager) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.danger,
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'تأكيد الحذف',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف "${subManager.name}"؟',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SubManagerCubit>().delete(subManager.id);
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
  final bool canAdd;
  final VoidCallback onAdd;
  const _Header({
    required this.count,
    required this.canAdd,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'المدراء الفرعيون',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$count مدير فرعي',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        AppButton(
          label: 'إضافة مدير فرعي',
          icon: Icons.add,
          width: 170,
          height: 40,
          onPressed: canAdd ? onAdd : null,
        ),
      ],
    );
  }
}

class _SubManagerList extends StatelessWidget {
  final List<SubManagerModel> subManagers;
  final List<PermissionOption> catalog;
  final bool isSubmitting;
  final ValueChanged<SubManagerModel> onEditInfo;
  final ValueChanged<SubManagerModel> onEditPermissions;
  final ValueChanged<SubManagerModel> onResetTotp;
  final ValueChanged<SubManagerModel> onDelete;

  const _SubManagerList({
    required this.subManagers,
    required this.catalog,
    required this.isSubmitting,
    required this.onEditInfo,
    required this.onEditPermissions,
    required this.onResetTotp,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: subManagers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final sm = subManagers[i];
        return Opacity(
          opacity: isSubmitting ? .6 : 1,
          child: SubManagerCard(
            subManager: sm,
            onEditInfo: () => onEditInfo(sm),
            onEditPermissions: () => onEditPermissions(sm),
            onResetTotp: () => onResetTotp(sm),
            onDelete: () => onDelete(sm),
          ),
        );
      },
    );
  }
}

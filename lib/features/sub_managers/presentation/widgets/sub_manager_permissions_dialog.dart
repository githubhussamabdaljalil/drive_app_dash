import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/sub_manager_model.dart';
import '../cubit/sub_manager_cubit.dart';
import 'sub_manager_form_dialog.dart' show PermissionCheckboxList;

/// Replaces a sub-manager's full permission set (PATCH .../permissions).
class SubManagerPermissionsDialog extends StatefulWidget {
  final List<PermissionOption> catalog;
  final SubManagerModel subManager;
  const SubManagerPermissionsDialog({super.key, required this.catalog, required this.subManager});

  @override
  State<SubManagerPermissionsDialog> createState() => _SubManagerPermissionsDialogState();
}

class _SubManagerPermissionsDialogState extends State<SubManagerPermissionsDialog> {
  late Set<String> _selected;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.subManager.permissions};
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    final success = await context.read<SubManagerCubit>().updatePermissions(widget.subManager.id, _selected.toList());
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      final state = context.read<SubManagerCubit>().state;
      setState(() {
        _isSubmitting = false;
        _errorText = state is SubManagerError ? state.message : 'حدث خطأ، حاول مرة أخرى';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('صلاحيات — ${widget.subManager.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: PermissionCheckboxList(
                    catalog: widget.catalog,
                    selected: _selected,
                    onChanged: (v) => setState(() => _selected = v),
                    maxHeight: 400,
                  ),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.dangerSurface, borderRadius: BorderRadius.circular(8)),
                  child: Text(_errorText!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
                ),
              ],
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: AppButton(label: 'حفظ الصلاحيات', isLoading: _isSubmitting, onPressed: _submit)),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

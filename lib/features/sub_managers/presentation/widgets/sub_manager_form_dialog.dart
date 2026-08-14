import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/sub_manager_model.dart';
import '../cubit/sub_manager_cubit.dart';

/// Create (or edit basic info of) a sub-manager.
/// On create, also lets the manager grant a subset of their own permissions.
class SubManagerFormDialog extends StatefulWidget {
  final List<PermissionOption> catalog;
  final SubManagerModel? subManager;
  const SubManagerFormDialog({super.key, required this.catalog, this.subManager});

  @override
  State<SubManagerFormDialog> createState() => _SubManagerFormDialogState();
}

class _SubManagerFormDialogState extends State<SubManagerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late Set<String> _selectedPermissions;

  bool _isSubmitting = false;
  String? _errorText;

  bool get _isEdit => widget.subManager != null;

  @override
  void initState() {
    super.initState();
    final sm = widget.subManager;
    _name = TextEditingController(text: sm?.name ?? '');
    _email = TextEditingController(text: sm?.email ?? '');
    _phone = TextEditingController(text: sm?.phone ?? '');
    _selectedPermissions = {...(sm?.permissions ?? [])};
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final cubit = context.read<SubManagerCubit>();

    if (_isEdit) {
      await _submitEdit(cubit);
    } else {
      await _submitCreate(cubit);
    }
  }

  Future<void> _submitEdit(SubManagerCubit cubit) async {
    final body = <String, dynamic>{
      'name': _name.text.trim(),
      if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
    };
    final success = await cubit.update(widget.subManager!.id, body);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      _showError(cubit);
    }
  }

  Future<void> _submitCreate(SubManagerCubit cubit) async {
    final body = <String, dynamic>{
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'permissions': _selectedPermissions.toList(),
    };
    final tempPassword = await cubit.create(body);
    if (!mounted) return;
    if (tempPassword != null) {
      Navigator.pop(context);
      _showTempPasswordDialog(context, name: _name.text.trim(), tempPassword: tempPassword);
    } else {
      _showError(cubit);
    }
  }

  void _showError(SubManagerCubit cubit) {
    final state = cubit.state;
    setState(() {
      _isSubmitting = false;
      _errorText = state is SubManagerError ? state.message : 'حدث خطأ، حاول مرة أخرى';
    });
  }

  void _showTempPasswordDialog(BuildContext context, {required String name, required String tempPassword}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('كلمة المرور المؤقتة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('سلّم كلمة المرور هذه لـ "$name" — لن تظهر مرة أخرى:', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              child: SelectableText(tempPassword, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1)),
            ),
          ],
        ),
        actions: [ElevatedButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('تم'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isEdit ? 'تعديل مدير فرعي' : 'إضافة مدير فرعي',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 18),
                Flexible(child: SingleChildScrollView(child: _FormFields(
                  isEdit: _isEdit,
                  nameCtrl: _name,
                  emailCtrl: _email,
                  phoneCtrl: _phone,
                  catalog: widget.catalog,
                  selectedPermissions: _selectedPermissions,
                  onPermissionsChanged: (v) => setState(() => _selectedPermissions = v),
                ))),
                if (_errorText != null) ...[
                  const SizedBox(height: 12),
                  _InlineError(_errorText!),
                ],
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: AppButton(label: _isEdit ? 'حفظ' : 'إضافة', isLoading: _isSubmitting, onPressed: _submit)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormFields extends StatelessWidget {
  final bool isEdit;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final List<PermissionOption> catalog;
  final Set<String> selectedPermissions;
  final ValueChanged<Set<String>> onPermissionsChanged;

  const _FormFields({
    required this.isEdit,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.catalog,
    required this.selectedPermissions,
    required this.onPermissionsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(label: 'الاسم', controller: nameCtrl, validator: (v) => (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null),
        const SizedBox(height: 14),
        AppTextField(
          label: 'البريد الإلكتروني',
          controller: emailCtrl,
          enabled: !isEdit,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => (!isEdit && (v == null || v.trim().isEmpty)) ? 'البريد الإلكتروني مطلوب' : null,
        ),
        const SizedBox(height: 14),
        AppTextField(label: 'رقم الهاتف', controller: phoneCtrl, keyboardType: TextInputType.phone),
        if (!isEdit) ...[
          const SizedBox(height: 16),
          const Text('الصلاحيات', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('يمكن منح صلاحيات من ضمن صلاحياتك الحالية فقط.', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
          const SizedBox(height: 8),
          PermissionCheckboxList(
            catalog: catalog,
            selected: selectedPermissions,
            onChanged: onPermissionsChanged,
          ),
        ],
      ],
    );
  }
}

/// Shared checkbox matrix used by both the create form and the
/// permissions-only dialog.
class PermissionCheckboxList extends StatelessWidget {
  final List<PermissionOption> catalog;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final double maxHeight;

  const PermissionCheckboxList({
    super.key,
    required this.catalog,
    required this.selected,
    required this.onChanged,
    this.maxHeight = 220,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        child: Column(
          children: catalog
              .map((perm) => CheckboxListTile(
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: selected.contains(perm.value),
                    title: Text(perm.labelAr, style: const TextStyle(fontSize: 12)),
                    subtitle: Text(perm.value, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                    onChanged: (checked) {
                      final next = {...selected};
                      if (checked == true) {
                        next.add(perm.value);
                      } else {
                        next.remove(perm.value);
                      }
                      onChanged(next);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  const _InlineError(this.message);

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.dangerSurface, borderRadius: BorderRadius.circular(8)),
        child: Text(message, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/driver_model.dart';
import '../cubit/driver_cubit.dart';

class DriverFormDialog extends StatefulWidget {
  final DriverModel? driver;
  const DriverFormDialog({super.key, this.driver});

  @override
  State<DriverFormDialog> createState() => _DriverFormDialogState();
}

class _DriverFormDialogState extends State<DriverFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;

  String? _status; // edit-only

  bool _isSubmitting = false;
  String? _errorText;

  bool get _isEdit => widget.driver != null;

  @override
  void initState() {
    super.initState();
    final d = widget.driver;
    _name = TextEditingController(text: d?.name ?? '');
    _phone = TextEditingController(text: d?.phone ?? '');
    _email = TextEditingController(text: d?.email ?? '');
    _status = d?.status;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final cubit = context.read<DriverCubit>();
    if (_isEdit) {
      await _submitEdit(cubit);
    } else {
      await _submitCreate(cubit);
    }
  }

  Future<void> _submitEdit(DriverCubit cubit) async {
    final body = <String, dynamic>{
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
      // 'status': _status, // commented out — status field hidden from UI
    };
    final success = await cubit.update(widget.driver!.id, body);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      _showError(cubit);
    }
  }

  Future<void> _submitCreate(DriverCubit cubit) async {
    final body = <String, dynamic>{
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'email': _email.text.trim().isEmpty ? null : _email.text.trim(),
    };
    final tempPassword = await cubit.create(body);
    if (!mounted) return;
    if (tempPassword != null) {
      Navigator.pop(context, (_name.text.trim(), tempPassword));
    } else {
      _showError(cubit);
    }
  }

  void _showError(DriverCubit cubit) {
    final state = cubit.state;
    setState(() {
      _isSubmitting = false;
      _errorText = state is DriverError ? state.message : 'حدث خطأ، حاول مرة أخرى';
    });
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
                Text(_isEdit ? 'تعديل سائق' : 'إضافة سائق',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 18),
                _DriverFormFields(
                  isEdit: _isEdit,
                  nameCtrl: _name,
                  phoneCtrl: _phone,
                  emailCtrl: _email,
                  status: _status,
                  onStatusChanged: (v) => setState(() => _status = v),
                ),
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
                  Expanded(
                    child: TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(label: _isEdit ? 'حفظ' : 'إضافة', isLoading: _isSubmitting, onPressed: _submit),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DriverFormFields extends StatelessWidget {
  final bool isEdit;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final String? status;
  final ValueChanged<String?> onStatusChanged;

  const _DriverFormFields({
    required this.isEdit,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'الاسم',
          hint: 'اسم السائق',
          controller: nameCtrl,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'رقم الهاتف',
          hint: '0555111222',
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'رقم الهاتف مطلوب' : null,
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'البريد الإلكتروني (اختياري)',
          hint: 'driver@example.com',
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        if (isEdit) ...[
          // -- Status field (commented out, uncomment to re-enable) --
          // const Text('الحالة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          // const SizedBox(height: 6),
          // Container(
          //   height: 46,
          //   padding: const EdgeInsets.symmetric(horizontal: 12),
          //   decoration: BoxDecoration(
          //     color: AppColors.surfaceInput,
          //     borderRadius: BorderRadius.circular(8),
          //     border: Border.all(color: AppColors.border),
          //   ),
          //   child: DropdownButtonHideUnderline(
          //     child: DropdownButton<String?>(
          //       value: status,
          //       isExpanded: true,
          //       items: const [
          //         DropdownMenuItem(value: 'active', child: Text('نشط', style: TextStyle(fontSize: 13))),
          //         DropdownMenuItem(value: 'inactive', child: Text('غير نشط', style: TextStyle(fontSize: 13))),
          //       ],
          //       onChanged: onStatusChanged,
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 14),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)),
            child: const Text(
              'سيتم إنشاء كلمة مرور مؤقتة تلقائياً — سلّمها للسائق يدوياً بعد الإضافة.',
              style: TextStyle(fontSize: 11, color: AppColors.primaryDark, height: 1.5),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

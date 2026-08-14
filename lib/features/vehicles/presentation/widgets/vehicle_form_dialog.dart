import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/vehicle_model.dart';
import '../cubit/vehicle_cubit.dart';

class VehicleFormDialog extends StatefulWidget {
  final VehicleModel? vehicle;
  const VehicleFormDialog({super.key, this.vehicle});

  @override
  State<VehicleFormDialog> createState() => _VehicleFormDialogState();
}

class _VehicleFormDialogState extends State<VehicleFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _plateNo;
  late final TextEditingController _type;
  late final TextEditingController _model;
  late final TextEditingController _description;

  String? _status; // null = leave untouched (no server-side change)

  bool _isSubmitting = false;
  String? _errorText;

  bool get _isEdit => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _plateNo = TextEditingController(text: v?.plateNo ?? '');
    _type = TextEditingController(text: v?.type ?? '');
    _model = TextEditingController(text: v?.model ?? '');
    _description = TextEditingController(text: v?.description ?? '');
    _status = (v?.status == 'maintenance' || v?.status == 'out_of_service') ? v!.status : null;
  }

  @override
  void dispose() {
    _plateNo.dispose();
    _type.dispose();
    _model.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final body = <String, dynamic>{
      if (_type.text.trim().isNotEmpty) 'type': _type.text.trim(),
      if (_model.text.trim().isNotEmpty) 'model': _model.text.trim(),
      if (_description.text.trim().isNotEmpty) 'description': _description.text.trim(),
      if (_status != null) 'status': _status,
    };
    if (!_isEdit) {
      body['plate_no'] = _plateNo.text.trim();
    }

    final cubit = context.read<VehicleCubit>();
    final success = _isEdit ? await cubit.update(widget.vehicle!.id, body) : await cubit.create(body);

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      final state = cubit.state;
      setState(() {
        _isSubmitting = false;
        _errorText = state is VehicleError ? state.message : 'حدث خطأ، حاول مرة أخرى';
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
                Text(_isEdit ? 'تعديل مركبة' : 'إضافة مركبة',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 18),
                _VehicleFormFields(
                  isEdit: _isEdit,
                  plateNoCtrl: _plateNo,
                  typeCtrl: _type,
                  modelCtrl: _model,
                  descriptionCtrl: _description,
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

class _VehicleFormFields extends StatelessWidget {
  final bool isEdit;
  final TextEditingController plateNoCtrl;
  final TextEditingController typeCtrl;
  final TextEditingController modelCtrl;
  final TextEditingController descriptionCtrl;
  final String? status;
  final ValueChanged<String?> onStatusChanged;

  const _VehicleFormFields({
    required this.isEdit,
    required this.plateNoCtrl,
    required this.typeCtrl,
    required this.modelCtrl,
    required this.descriptionCtrl,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'رقم اللوحة',
          hint: 'DXB-12345',
          controller: plateNoCtrl,
          enabled: !isEdit,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'رقم اللوحة مطلوب' : null,
        ),
        const SizedBox(height: 14),
        AppTextField(label: 'النوع', hint: 'Truck / Van / Bus...', controller: typeCtrl),
        const SizedBox(height: 14),
        AppTextField(label: 'الموديل', hint: 'Hino 300', controller: modelCtrl),
        const SizedBox(height: 14),
        AppTextField(label: 'الوصف', hint: 'ملاحظات إضافية...', controller: descriptionCtrl),
        const SizedBox(height: 14),
        if (isEdit) ...[
          const Text('الحالة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
              child: DropdownButton<String?>(
                value: status,
                isExpanded: true,
                hint: const Text('بدون تغيير', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                items: const [
                  DropdownMenuItem(value: null, child: Text('بدون تغيير', style: TextStyle(fontSize: 13))),
                  DropdownMenuItem(value: 'maintenance', child: Text('صيانة', style: TextStyle(fontSize: 13))),
                  DropdownMenuItem(value: 'out_of_service', child: Text('خارج الخدمة', style: TextStyle(fontSize: 13))),
                ],
                onChanged: onStatusChanged,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'الحالتان "نشطة" و"غير نشطة" تُحسبان تلقائياً من ربط السائق وتسجيل الحضور، ولا يمكن تعيينهما يدوياً.',
            style: TextStyle(fontSize: 11, color: AppColors.textHint, height: 1.5),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

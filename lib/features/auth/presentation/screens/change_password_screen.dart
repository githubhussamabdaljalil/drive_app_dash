import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/web_auth_layout.dart';
import '../../../../core/widgets/dashboard/auth_button.dart';
import '../../../../core/widgets/dashboard/error_banner.dart';
import '../../../../core/widgets/dashboard/password_strength.dart';
import '../../../../core/constants/app_routes.dart';

class ChangePasswordScreen extends StatefulWidget {
  final bool isDriver;
  const ChangePasswordScreen({super.key, this.isDriver = false});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey     = GlobalKey<FormState>();

  bool get _hasMin8    => _newCtrl.text.length >= 8;
  bool get _hasNumber  => _newCtrl.text.contains(RegExp(r'\d'));
  bool get _hasSpecial => _newCtrl.text.contains(RegExp(r'[!@#\$%^&*]'));

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
        ChangePasswordEvent(_currentCtrl.text, _newCtrl.text,
            isDriver: widget.isDriver));
  }

  @override
  void dispose() {
    _currentCtrl.dispose(); _newCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is PasswordChanged) {
          final route = widget.isDriver ? AppRoutes.driverHome : AppRoutes.adminDashboard;
          Navigator.pushReplacementNamed(ctx, route);
        }
      },
      builder: (ctx, state) {
        final loading = state is AuthLoading;
        final error   = state is AuthFailure ? state.message : null;

        return WebAuthLayout(cardWidth: 440, child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('تغيير كلمة المرور',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('يجب تغيير كلمة المرور المؤقتة قبل المتابعة',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 20),

            // Warning box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(.4)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                const SizedBox(width: 8),
                const Expanded(child: Text(
                    'لأسباب أمنية، يجب تعيين كلمة مرور جديدة قبل استخدام النظام.',
                    style: TextStyle(fontSize: 12, color: AppColors.warning))),
              ]),
            ),
            const SizedBox(height: 20),

            if (error != null) ...[ErrorBanner(error), const SizedBox(height: 14)],

            _Label('كلمة المرور الحالية (المؤقتة)'),
            const SizedBox(height: 6),
            _PassField(controller: _currentCtrl,
                validator: (v) => (v?.isEmpty ?? true) ? 'مطلوب' : null),
            const SizedBox(height: 14),

            _Label('كلمة المرور الجديدة'),
            const SizedBox(height: 6),
            _PassField(
              controller: _newCtrl,
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.isEmpty) return 'مطلوب';
                if (!_hasMin8) return '8 أحرف على الأقل';
                return null;
              },
            ),
            const SizedBox(height: 8),
            PasswordStrengthRow(label: '8 أحرف على الأقل', met: _hasMin8),
            const SizedBox(height: 3),
            PasswordStrengthRow(label: 'رقم واحد على الأقل', met: _hasNumber),
            const SizedBox(height: 3),
            PasswordStrengthRow(label: 'رمز خاص (!@#\$)', met: _hasSpecial),
            const SizedBox(height: 14),

            _Label('تأكيد كلمة المرور'),
            const SizedBox(height: 6),
            _PassField(
              controller: _confirmCtrl,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (v) => v != _newCtrl.text ? 'كلمتا المرور غير متطابقتان' : null,
            ),
            const SizedBox(height: 24),

            AuthButton(label: 'حفظ وتسجيل الدخول', onPressed: _submit, isLoading: loading),
          ]),
        ));
      },
    );
  }
}

class _Label extends StatelessWidget {
  final String t;
  const _Label(this.t);
  @override
  Widget build(BuildContext context) => Text(t,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary));
}

class _PassField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputAction textInputAction;

  const _PassField({required this.controller, this.validator,
      this.onChanged, this.onSubmitted,
      this.textInputAction = TextInputAction.next});

  @override
  State<_PassField> createState() => _PassFieldState();
}

class _PassFieldState extends State<_PassField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    obscureText: _obscure,
    textInputAction: widget.textInputAction,
    onChanged: widget.onChanged,
    onFieldSubmitted: widget.onSubmitted,
    validator: widget.validator,
    decoration: InputDecoration(
      suffixIcon: GestureDetector(
        onTap: () => setState(() => _obscure = !_obscure),
        child: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textHint, size: 18),
      ),
    ),
  );
}

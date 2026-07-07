import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/web_auth_layout.dart';
import '../../../../core/widgets/dashboard/auth_button.dart';
import '../../../../core/widgets/dashboard/error_banner.dart';
import '../../../../core/constants/app_routes.dart';
import 'role_selector_screen.dart';

/// Login Screen — shows different form based on selected role
class LoginScreen extends StatefulWidget {
  final String role; // 'owner' | 'manager' | 'driver'
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _field1Ctrl = TextEditingController(); // email or phone
  final _passCtrl   = TextEditingController();
  bool _obscure = true;

  bool get _isDriver => widget.role == 'driver';

  @override
  void dispose() { _field1Ctrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isDriver) {
      context.read<AuthBloc>().add(DriverLoginEvent(_field1Ctrl.text.trim(), _passCtrl.text));
    } else {
      context.read<AuthBloc>().add(AdminLoginEvent(_field1Ctrl.text.trim(), _passCtrl.text));
    }
  }

  String get _roleLabel => switch (widget.role) {
    'owner'   => 'المالك',
    'manager' => 'المدير',
    _         => 'السائق',
  };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AdminLoginSuccess) {
          if (state.challengeToken != null) {
            Navigator.pushNamed(ctx, AppRoutes.verifyTotp,
                arguments: state.challengeToken);
          } else {
            Navigator.pushReplacementNamed(ctx, AppRoutes.adminDashboard);
          }
        } else if (state is DriverLoginSuccess) {
          if (state.requiresOtp) {
            Navigator.pushNamed(ctx, AppRoutes.verifyOtp,
                arguments: _field1Ctrl.text.trim());
          } else {
            Navigator.pushReplacementNamed(ctx, AppRoutes.driverHome);
          }
        } else if (state is MustChangePassword) {
          Navigator.pushNamed(ctx, AppRoutes.changePassword,
              arguments: {'isDriver': state.isDriver});
        }
      },
      builder: (ctx, state) {
        final loading = state is AuthLoading;
        final error   = state is AuthFailure ? state.message : null;

        return WebAuthLayout(
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Role badge
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('مرحبًا بعودتك',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text('تسجيل دخول كـ $_roleLabel',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ]),
                _RoleBadge(role: widget.role),
              ]),
              const SizedBox(height: 28),

              if (error != null) ...[ErrorBanner(error), const SizedBox(height: 16)],

              // Field 1 — email or phone
              _FieldLabel(_isDriver ? 'رقم الهاتف' : 'البريد الإلكتروني'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _field1Ctrl,
                keyboardType: _isDriver ? TextInputType.phone : TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: _isDriver ? '09xxxxxxxx' : 'email@company.com',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const _FieldLabel('كلمة المرور'),
                if (!_isDriver)
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(ctx, AppRoutes.forgotPassword),
                    child: const Text('نسيت كلمة المرور؟',
                        style: TextStyle(fontSize: 12, color: AppColors.primary,
                            fontWeight: FontWeight.w500)),
                  ),
              ]),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'كلمة المرور',
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textHint, size: 18),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'كلمة المرور مطلوبة' : null,
              ),
              const SizedBox(height: 24),

              AuthButton(label: 'تسجيل الدخول', onPressed: _submit, isLoading: loading),
              const SizedBox(height: 20),

              // Back to role selector
              Center(child: GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(ctx, AppRoutes.roleSelector),
                child: const Text('← تغيير الدور',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              )),
            ]),
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary));
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (role) {
      'owner'   => (const Color(0xFF7B1FA2), Icons.admin_panel_settings, 'مالك'),
      'manager' => (AppColors.primary, Icons.manage_accounts, 'مدير'),
      _         => (AppColors.success, Icons.drive_eta, 'سائق'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/web_auth_layout.dart';
import '../../../../core/widgets/dashboard/auth_button.dart';
import '../../../../core/widgets/dashboard/error_banner.dart';
import '../../../../core/constants/app_routes.dart';

/// Admin TOTP verification screen — step 2 of admin login when the account
/// has two-factor authentication enabled.
class VerifyOtpScreen extends StatefulWidget {
  final String challengeToken;

  const VerifyOtpScreen({super.key, required this.challengeToken});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _codeCtrl = TextEditingController();

  bool get _sessionExpired => widget.challengeToken.isEmpty;

  void _submit() {
    final code = _codeCtrl.text.trim().replaceAll(' ', '');
    if (code.isEmpty) return;
    if (_sessionExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('انتهت الجلسة، يرجى تسجيل الدخول مجدداً'),
            backgroundColor: AppColors.danger),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }
    context.read<AuthCubit>().adminVerifyTotp(widget.challengeToken, code);
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (ctx, state) {
        if (state is AdminLoginSuccess && state.challengeToken == null) {
          Navigator.pushReplacementNamed(ctx, AppRoutes.adminDashboard);
        } else if (state is MustChangePassword) {
          Navigator.pushReplacementNamed(ctx, AppRoutes.changePassword);
        }
      },
      builder: (ctx, state) {
        final loading = state is AuthLoading;
        final error = state is AuthFailure ? state.message : null;

        return WebAuthLayout(
          cardWidth: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('التحقق بخطوتين (TOTP)',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text('أدخل الرمز من تطبيق المصادقة',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 28),

              if (error != null) ...[ErrorBanner(error), const SizedBox(height: 16)],

              const Text('رمز التحقق',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 6,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(hintText: '000000', counterText: ''),
              ),
              if (_sessionExpired)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.dangerSurface, borderRadius: BorderRadius.circular(8)),
                    child: const Row(children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 16),
                      SizedBox(width: 8),
                      Expanded(child: Text(
                        'انتهت الجلسة، يرجى تسجيل الدخول مجدداً',
                        style: TextStyle(fontSize: 12, color: AppColors.danger),
                      )),
                    ]),
                  ),
                ),
              const SizedBox(height: 24),

              AuthButton(label: 'تأكيد', onPressed: _submit, isLoading: loading),
              const SizedBox(height: 16),

              Center(child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: const Text('← رجوع', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              )),
            ],
          ),
        );
      },
    );
  }
}

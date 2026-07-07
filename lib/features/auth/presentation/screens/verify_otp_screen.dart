import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/web_auth_layout.dart';
import '../../../../core/widgets/dashboard/auth_button.dart';
import '../../../../core/widgets/dashboard/error_banner.dart';
import '../../../../core/constants/app_routes.dart';

/// Driver OTP / Admin TOTP verification screen
class VerifyOtpScreen extends StatefulWidget {
  final String phone;     // driver phone
  final bool isTotp;      // true = admin TOTP
  final String? challengeToken;

  const VerifyOtpScreen({super.key, required this.phone,
      this.isTotp = false, this.challengeToken});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _codeCtrl = TextEditingController();

  void _submit() {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    if (widget.isTotp) {
      context.read<AuthBloc>().add(
          AdminVerifyTotpEvent(widget.challengeToken!, code));
    } else {
      context.read<AuthBloc>().add(DriverVerifyOtpEvent(widget.phone, code));
    }
  }

  @override
  void dispose() { _codeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AdminLoginSuccess) {
          Navigator.pushReplacementNamed(ctx, AppRoutes.adminDashboard);
        } else if (state is DriverLoginSuccess && !state.requiresOtp) {
          Navigator.pushReplacementNamed(ctx, AppRoutes.driverHome);
        }
      },
      builder: (ctx, state) {
        final loading = state is AuthLoading;
        final error   = state is AuthFailure ? state.message : null;

        return WebAuthLayout(cardWidth: 400, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.isTotp ? 'التحقق بخطوتين (TOTP)' : 'رمز التحقق (OTP)',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text(widget.isTotp
                ? 'أدخل الرمز من تطبيق المصادقة'
                : 'أدخل الرمز المرسل إلى ${widget.phone}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 28),

            if (error != null) ...[ErrorBanner(error), const SizedBox(height: 16)],

            const Text('رمز التحقق',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(hintText: '------'),
            ),
            const SizedBox(height: 24),

            AuthButton(label: 'تأكيد', onPressed: _submit, isLoading: loading),
            const SizedBox(height: 16),

            Center(child: GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: const Text('← رجوع',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            )),
          ],
        ));
      },
    );
  }
}

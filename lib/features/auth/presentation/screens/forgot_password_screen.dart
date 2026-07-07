import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/web_auth_layout.dart';
import '../../../../core/widgets/dashboard/auth_button.dart';
import '../../../../core/widgets/dashboard/error_banner.dart';
import '../../../../core/constants/app_routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 0;
  String _email = '';
  String _code  = '';

  final _emailCtrl   = TextEditingController();
  final _codeCtrl    = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose(); _codeCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is ResetCodeSent)     setState(() { _email = _emailCtrl.text.trim(); _step = 1; });
        if (state is ResetCodeVerified) setState(() { _code = state.code; _step = 2; });
        if (state is PasswordReset) {
          Navigator.pushReplacementNamed(ctx, AppRoutes.roleSelector);
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
            content: Text('تم تغيير كلمة المرور، يمكنك تسجيل الدخول'),
            backgroundColor: AppColors.success,
          ));
        }
      },
      builder: (ctx, state) {
        final loading = state is AuthLoading;
        final error   = state is AuthFailure ? state.message : null;

        return WebAuthLayout(cardWidth: 420, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              GestureDetector(
                onTap: () => _step > 0 ? setState(() => _step--) : Navigator.pop(ctx),
                child: const Icon(Icons.arrow_back, size: 20, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 10),
              const Text('استعادة كلمة المرور',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ]),
            const SizedBox(height: 8),

            // Step indicators
            _StepBar(current: _step),
            const SizedBox(height: 24),

            if (error != null) ...[ErrorBanner(error), const SizedBox(height: 14)],

            // Step body
            if (_step == 0) _StepEmail(
              ctrl: _emailCtrl, loading: loading,
              onSend: () => ctx.read<AuthBloc>().add(
                  ForgotPasswordEvent(_emailCtrl.text.trim())),
            ),
            if (_step == 1) _StepCode(
              ctrl: _codeCtrl, email: _email, loading: loading,
              onVerify: () => ctx.read<AuthBloc>().add(
                  VerifyResetCodeEvent(_email, _codeCtrl.text.trim())),
            ),
            if (_step == 2) _StepNewPass(
              passCtrl: _passCtrl, confirmCtrl: _confirmCtrl, loading: loading,
              onSave: () => ctx.read<AuthBloc>().add(
                  ResetPasswordEvent(_email, _code, _passCtrl.text)),
            ),
          ],
        ));
      },
    );
  }
}

// ── Step widgets ──────────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  final int current;
  const _StepBar({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(children: List.generate(3, (i) {
      final done = i < current;
      final active = i == current;
      return Expanded(child: Row(children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColors.success : active ? AppColors.primary : AppColors.border,
          ),
          child: Center(child: done
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : Text('${i + 1}', style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppColors.textHint))),
        ),
        if (i < 2) Expanded(child: Container(height: 2,
            color: i < current ? AppColors.success : AppColors.border)),
      ]));
    }));
  }
}

class _StepEmail extends StatelessWidget {
  final TextEditingController ctrl;
  final bool loading;
  final VoidCallback onSend;

  const _StepEmail({required this.ctrl, required this.loading, required this.onSend});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('أدخل بريدك الإلكتروني',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      const Text('سيُرسل كود التحقق إلى بريدك وهاتفك',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 18),
      const Text('البريد الإلكتروني',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      TextFormField(controller: ctrl, keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'email@company.com')),
      const SizedBox(height: 20),
      AuthButton(label: 'إرسال كود التحقق', onPressed: onSend, isLoading: loading),
    ],
  );
}

class _StepCode extends StatelessWidget {
  final TextEditingController ctrl;
  final String email;
  final bool loading;
  final VoidCallback onVerify;

  const _StepCode({required this.ctrl, required this.email,
      required this.loading, required this.onVerify});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('أدخل كود التحقق',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text('تم الإرسال إلى $email',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 18),
      const Text('الكود', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      TextFormField(controller: ctrl, keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '------')),
      const SizedBox(height: 20),
      AuthButton(label: 'التحقق', onPressed: onVerify, isLoading: loading),
    ],
  );
}

class _StepNewPass extends StatelessWidget {
  final TextEditingController passCtrl;
  final TextEditingController confirmCtrl;
  final bool loading;
  final VoidCallback onSave;

  const _StepNewPass({required this.passCtrl, required this.confirmCtrl,
      required this.loading, required this.onSave});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('كلمة مرور جديدة',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 18),
      const Text('كلمة المرور الجديدة', style: TextStyle(fontSize: 13,
          fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      TextFormField(controller: passCtrl, obscureText: true),
      const SizedBox(height: 14),
      const Text('تأكيد كلمة المرور', style: TextStyle(fontSize: 13,
          fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      TextFormField(controller: confirmCtrl, obscureText: true),
      const SizedBox(height: 20),
      AuthButton(label: 'حفظ كلمة المرور', onPressed: onSave, isLoading: loading),
    ],
  );
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

/// شاشة تسجيل الدخول
/// REQ-Auth-01: تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
/// REQ-Auth-09: السائق يسجل دخوله بالبريد وكلمة المرور
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool _loading     = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // TODO: AuthBloc.add(LoginEvent(email, password))
    await Future.delayed(const Duration(seconds: 1)); // placeholder

    if (!mounted) return;
    setState(() => _loading = false);

    // إذا كلمة المرور مؤقتة → صفحة التغيير الإجباري (REQ-Auth-07)
    // وإلا → الهوم
    const bool isFirstLogin = true; // سيجي من الـ API
    if (isFirstLogin) {
      Navigator.pushReplacementNamed(context, AppRoutes.changePassword);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          // ── Hero Section ──────────────────────────────────────────
          Expanded(
            flex: 4,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(.3), width: 1.5),
                    ),
                    child: const Icon(Icons.local_shipping_outlined, size: 42, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text('VTFMS', style: AppTextStyles.displayLarge),
                  const SizedBox(height: 4),
                  Text(
                    'نظام إدارة وتتبع الأسطول',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(.7)),
                  ),
                ],
              ),
            ),
          ),

          // ── Form Card ────────────────────────────────────────────
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('تسجيل الدخول', style: AppTextStyles.h1),
                    const SizedBox(height: 4),
                    Text('أدخل بياناتك للمتابعة', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 24),

                    AppTextField(
                      label: 'البريد الإلكتروني',
                      hint: 'driver@company.com',
                      controller: _emailCtrl,
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'البريد مطلوب';
                        if (!v.contains('@')) return 'بريد إلكتروني غير صحيح';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'كلمة المرور',
                      hint: '••••••••',
                      controller: _passCtrl,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _onLogin(),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'كلمة المرور مطلوبة';
                        if (v.length < 6) return 'كلمة المرور قصيرة جدًا';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // نسيت كلمة المرور
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        child: const Text('نسيت كلمة المرور؟', style: AppTextStyles.btnText),
                      ),
                    ),
                    const SizedBox(height: 20),

                    AppButton(
                      label: 'تسجيل الدخول',
                      onPressed: _onLogin,
                      isLoading: _loading,
                      icon: Icons.login_rounded,
                    ),

                    const Spacer(),

                    // إصدار التطبيق
                    Center(
                      child: Text('VTFMS Driver v1.0.0', style: AppTextStyles.caption),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

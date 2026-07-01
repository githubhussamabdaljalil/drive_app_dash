import 'package:flutter/material.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

/// شاشة تغيير كلمة المرور الإجباري — أول تسجيل دخول
/// REQ-Auth-07: يُجبر النظام المستخدم على تغيير كلمة المرور المؤقتة
/// REQ-Auth-08: يرفض النظام أي عملية حتى يتم التغيير
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _otpCtrl     = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading      = false;

  // Password strength checks
  bool get _hasMin8    => _newPassCtrl.text.length >= 8;
  bool get _hasNumber  => _newPassCtrl.text.contains(RegExp(r'\d'));
  bool get _hasSpecial => _newPassCtrl.text.contains(RegExp(r'[!@#\$%^&*]'));

  @override
  void dispose() {
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // TODO: AuthBloc.add(ChangePasswordEvent(...))
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // لا يوجد زر رجوع — الشاشة إجبارية
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_reset, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'مطلوب عند أول تسجيل دخول',
                        style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(.9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('تغيير كلمة المرور', style: AppTextStyles.displayMedium),
                const SizedBox(height: 4),
                Text(
                  'أنشئ كلمة مرور جديدة للبدء',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(.7)),
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // تنبيه إجباري
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warningSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withOpacity(.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'يجب تغيير كلمة المرور المؤقتة قبل استخدام التطبيق.',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // كلمة المرور المؤقتة
                    AppTextField(
                      label: 'كلمة المرور المؤقتة',
                      hint: 'أدخل الكلمة المؤقتة من المدير',
                      controller: _otpCtrl,
                      prefixIcon: Icons.vpn_key_outlined,
                      isPassword: true,
                      validator: (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
                    ),
                    const SizedBox(height: 16),

                    // كلمة المرور الجديدة
                    AppTextField(
                      label: 'كلمة المرور الجديدة',
                      hint: '8 أحرف على الأقل',
                      controller: _newPassCtrl,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
                        if (!_hasMin8) return 'يجب أن تكون 8 أحرف على الأقل';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // مؤشر قوة كلمة المرور
                    _PasswordStrengthRow(
                      label: '8 أحرف على الأقل',
                      met: _hasMin8,
                    ),
                    const SizedBox(height: 4),
                    _PasswordStrengthRow(
                      label: 'رقم واحد على الأقل',
                      met: _hasNumber,
                    ),
                    const SizedBox(height: 4),
                    _PasswordStrengthRow(
                      label: 'رمز خاص (!@#\$)',
                      met: _hasSpecial,
                    ),
                    const SizedBox(height: 16),

                    // تأكيد كلمة المرور
                    AppTextField(
                      label: 'تأكيد كلمة المرور الجديدة',
                      hint: 'أعد كلمة المرور',
                      controller: _confirmCtrl,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _onSave(),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
                        if (v != _newPassCtrl.text) return 'كلمتا المرور غير متطابقتان';
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    AppButton(
                      label: 'حفظ وتسجيل الدخول',
                      onPressed: _onSave,
                      isLoading: _loading,
                      icon: Icons.check_circle_outline,
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

/// صف واحد من متطلبات كلمة المرور
class _PasswordStrengthRow extends StatelessWidget {
  final String label;
  final bool met;

  const _PasswordStrengthRow({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: met ? AppColors.success : AppColors.textHint,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: met ? AppColors.success : AppColors.textHint,
            fontWeight: met ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

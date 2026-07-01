import 'package:flutter/material.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

/// شاشة نسيت كلمة المرور — 3 خطوات
/// REQ-Auth-02: إعادة تعيين كلمة المرور عبر كود يُرسل للبريد والهاتف معًا
/// UC-03: نسيان كلمة المرور — الكود يُرسل لكلا القناتين دائمًا
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step        = 0; // 0 = إدخال البريد، 1 = إدخال الكود، 2 = كلمة مرور جديدة
  bool _loading    = false;

  final _emailCtrl    = TextEditingController();
  final _codeCtrl     = TextEditingController();
  final _newPassCtrl  = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onNextStep() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // TODO: API call
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (_step < 2) _step++;
      else _onFinish();
    });
  }

  void _onFinish() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تغيير كلمة المرور بنجاح، يمكنك تسجيل الدخول الآن'),
        backgroundColor: AppColors.success,
      ),
    );
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
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 20,
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
                // زر الرجوع (متاح هنا لأن الشاشة اختيارية)
                GestureDetector(
                  onTap: () {
                    if (_step > 0) {
                      setState(() => _step--);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text('رجوع', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('استعادة كلمة المرور', style: AppTextStyles.displayMedium),
                const SizedBox(height: 4),
                Text(
                  'خطوة ${_step + 1} من 3',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(.7)),
                ),
                const SizedBox(height: 16),

                // شريط التقدم
                Row(
                  children: List.generate(3, (i) {
                    final isDone   = i < _step;
                    final isCurr   = i == _step;
                    return Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? AppColors.success
                                  : isCurr
                                      ? Colors.white
                                      : Colors.white.withOpacity(.25),
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isCurr ? AppColors.primary : Colors.white.withOpacity(.6),
                                      ),
                                    ),
                            ),
                          ),
                          if (i < 2)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: i < _step
                                    ? AppColors.success
                                    : Colors.white.withOpacity(.2),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStep(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:  return _StepEmail(ctrl: _emailCtrl, loading: _loading, onNext: _onNextStep);
      case 1:  return _StepCode(ctrl: _codeCtrl, email: _emailCtrl.text, loading: _loading, onNext: _onNextStep);
      default: return _StepNewPass(newCtrl: _newPassCtrl, confirmCtrl: _confirmCtrl, loading: _loading, onSave: _onNextStep);
    }
  }
}

// ── Step 1: إدخال البريد ──────────────────────────────────────────────────

class _StepEmail extends StatelessWidget {
  final TextEditingController ctrl;
  final bool loading;
  final VoidCallback onNext;

  const _StepEmail({required this.ctrl, required this.loading, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('step0'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Text('أدخل بريدك الإلكتروني', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(
          'سيتم إرسال كود التحقق إلى بريدك الإلكتروني ورقم هاتفك المسجلَين في النظام.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),

        // تنبيه: الكود يُرسل لكلا القناتين (حسب UC-03)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'سيُرسل الكود لكلا القناتين (البريد والهاتف) في آنٍ واحد.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        AppTextField(
          label: 'البريد الإلكتروني',
          hint: 'driver@company.com',
          controller: ctrl,
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),

        AppButton(
          label: 'إرسال كود التحقق',
          onPressed: onNext,
          isLoading: loading,
          icon: Icons.send_outlined,
        ),
      ],
    );
  }
}

// ── Step 2: إدخال الكود ──────────────────────────────────────────────────

class _StepCode extends StatelessWidget {
  final TextEditingController ctrl;
  final String email;
  final bool loading;
  final VoidCallback onNext;

  const _StepCode({required this.ctrl, required this.email, required this.loading, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Text('أدخل كود التحقق', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: AppTextStyles.bodyMedium,
            children: [
              const TextSpan(text: 'تم إرسال الكود إلى '),
              TextSpan(
                text: email,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              const TextSpan(text: ' ورقم هاتفك.'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        AppTextField(
          label: 'كود التحقق',
          hint: '------',
          controller: ctrl,
          prefixIcon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),

        // إعادة الإرسال
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('لم يصلك الكود؟ ', style: AppTextStyles.bodySmall),
            TextButton(
              onPressed: () {/* TODO: resend */},
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: const Text('إعادة الإرسال', style: AppTextStyles.btnText),
            ),
          ],
        ),
        const SizedBox(height: 16),

        AppButton(
          label: 'التحقق من الكود',
          onPressed: onNext,
          isLoading: loading,
          icon: Icons.verified_outlined,
        ),
      ],
    );
  }
}

// ── Step 3: كلمة مرور جديدة ──────────────────────────────────────────────

class _StepNewPass extends StatelessWidget {
  final TextEditingController newCtrl;
  final TextEditingController confirmCtrl;
  final bool loading;
  final VoidCallback onSave;

  const _StepNewPass({
    required this.newCtrl,
    required this.confirmCtrl,
    required this.loading,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Text('كلمة مرور جديدة', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text('اختر كلمة مرور قوية لحماية حسابك.', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 24),

        AppTextField(
          label: 'كلمة المرور الجديدة',
          hint: '8 أحرف على الأقل',
          controller: newCtrl,
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          validator: (v) {
            if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
            if (v.length < 8) return 'يجب أن تكون 8 أحرف على الأقل';
            return null;
          },
        ),
        const SizedBox(height: 16),

        AppTextField(
          label: 'تأكيد كلمة المرور',
          hint: 'أعد كلمة المرور',
          controller: confirmCtrl,
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          textInputAction: TextInputAction.done,
          validator: (v) {
            if (v != newCtrl.text) return 'كلمتا المرور غير متطابقتان';
            return null;
          },
        ),
        const SizedBox(height: 28),

        AppButton(
          label: 'حفظ كلمة المرور',
          onPressed: onSave,
          isLoading: loading,
          icon: Icons.check_circle_outline,
        ),
      ],
    );
  }
}

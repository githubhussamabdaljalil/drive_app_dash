import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import '../cubit/auth_cubit.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/web_auth_layout.dart';
import '../../../../core/widgets/dashboard/auth_button.dart';
import '../../../../core/widgets/dashboard/error_banner.dart';
import '../../../../core/constants/app_routes.dart';

/// TOTP verification screen.
///
/// Reached after:
/// stage = totp_required
///
/// The challenge token is temporary and is NOT the final auth token.
class VerifyOtpScreen extends StatefulWidget {
  final String challengeToken;

  const VerifyOtpScreen({super.key, required this.challengeToken});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  // Current OTP value.
  String _code = '';

  // When onSubmit is triggered by the package,
  // we save the complete 6-digit code here.
  String _completeCode = '';

  bool get _sessionExpired => widget.challengeToken.isEmpty;

  // ================================================================
  // VERIFY
  // ================================================================

  void _submit() {
    // Prefer the complete code received from onSubmit.
    final code = (_completeCode.isNotEmpty ? _completeCode : _code)
        .trim()
        .replaceAll(' ', '');

    // ------------------------------------------------------------
    // Validate OTP
    // ------------------------------------------------------------

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رمز التحقق المكون من 6 أرقام'),
          backgroundColor: AppColors.danger,
        ),
      );

      return;
    }

    // ------------------------------------------------------------
    // Check session
    // ------------------------------------------------------------

    if (_sessionExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('انتهت الجلسة، يرجى تسجيل الدخول مجدداً'),
          backgroundColor: AppColors.danger,
        ),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.login);

      return;
    }

    // ------------------------------------------------------------
    // Send API request
    // ------------------------------------------------------------

    context.read<AuthCubit>().adminVerifyTotp(widget.challengeToken, code);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (ctx, state) {
        // ----------------------------------------------------------
        // Login successful
        // ----------------------------------------------------------

        if (state is AdminLoginSuccess) {
          Navigator.pushReplacementNamed(ctx, AppRoutes.adminDashboard);
        }
        // ----------------------------------------------------------
        // First login
        // ----------------------------------------------------------
        else if (state is MustChangePassword) {
          Navigator.pushReplacementNamed(ctx, AppRoutes.changePassword);
        }
      },

      builder: (ctx, state) {
        final loading = state is AuthLoading;

        final error = state is AuthFailure ? state.message : null;

        return WebAuthLayout(
          cardWidth: 430,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====================================================
              // TITLE
              // ====================================================
              const Text(
                'التحقق بخطوتين (TOTP)',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'أدخل الرمز المكون من 6 أرقام من تطبيق المصادقة',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 28),

              // ====================================================
              // ERROR
              // ====================================================
              if (error != null) ...[
                ErrorBanner(error),
                const SizedBox(height: 18),
              ],

              // ====================================================
              // OTP LABEL
              // ====================================================
              const Text(
                'رمز التحقق',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 10),

              // ====================================================
              // OTP
              // ====================================================
              Directionality(
                textDirection: TextDirection.ltr,
                child: OtpTextField(
                  numberOfFields: 6,

                  fieldWidth: 50,

                  autoFocus: true,

                  showFieldAsBox: true,

                  borderRadius: BorderRadius.circular(8),

                  borderColor: AppColors.border,

                  focusedBorderColor: AppColors.primary,

                  disabledBorderColor: AppColors.border,

                  enabledBorderColor: AppColors.border,

                  filled: true,

                  fillColor: AppColors.surface,

                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),

                  keyboardType: TextInputType.number,

                  // ------------------------------------------------
                  // IMPORTANT:
                  // This does NOT send the request.
                  // It only keeps the current value.
                  // ------------------------------------------------
                  onCodeChanged: (String code) {
                    setState(() {
                      _code = code;
                    });
                  },

                  // ------------------------------------------------
                  // When all 6 fields are completed:
                  // Save the complete code ONLY.
                  //
                  // Do NOT call _submit() here.
                  // ------------------------------------------------
                  onSubmit: (String verificationCode) {
                    setState(() {
                      _completeCode = verificationCode;
                      _code = verificationCode;
                    });
                  },
                ),
              ),

              // ====================================================
              // EXPIRED SESSION
              // ====================================================
              if (_sessionExpired)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.dangerSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.danger,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'انتهت الجلسة، يرجى تسجيل الدخول مجدداً',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 28),

              // ====================================================
              // CONFIRM BUTTON
              // ====================================================
              AuthButton(
                label: 'تأكيد',

                // Request is sent ONLY here.
                onPressed: _submit,

                isLoading: loading,
              ),

              const SizedBox(height: 16),

              // ====================================================
              // LOGIN AGAIN
              // ====================================================
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  child: const Text(
                    '← تسجيل الدخول من جديد',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

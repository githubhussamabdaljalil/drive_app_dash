import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/web_auth_layout.dart';
import '../../../../core/widgets/dashboard/auth_button.dart';
import '../../../../core/widgets/dashboard/error_banner.dart';
import '../../../../core/constants/app_routes.dart';

/// Admin login screen.
///
/// The backend determines whether the authenticated user is:
/// - owner
/// - manager
///
/// No role is selected on the frontend.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().adminLogin(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (ctx, state) {
        // First-time TOTP setup
        if (state is AdminTotpSetupRequired) {
          Navigator.pushNamed(
            ctx,
            AppRoutes.setupTotp,
            arguments: {
              'challengeToken': state.challengeToken,
              'secret': state.secret,
              'provisioningUri': state.provisioningUri,
            },
          );
        }

        // TOTP already configured
        else if (state is AdminTotpRequired) {
          Navigator.pushNamed(
            ctx,
            AppRoutes.verifyTotp,
            arguments: state.challengeToken,
          );
        }

        // Login successful
        else if (state is AdminLoginSuccess) {
          Navigator.pushReplacementNamed(
            ctx,
            AppRoutes.adminDashboard,
          );
        }

        // First login requires password change
        else if (state is MustChangePassword) {
          Navigator.pushReplacementNamed(
            ctx,
            AppRoutes.changePassword,
          );
        }
      },

      builder: (ctx, state) {
        final loading = state is AuthLoading;

        final error = state is AuthFailure
            ? state.message
            : null;

        return WebAuthLayout(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  'مرحبًا بعودتك',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'سجل الدخول إلى نظام إدارة الأساطيل والمركبات',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                // Error
                if (error != null) ...[
                  ErrorBanner(error),
                  const SizedBox(height: 16),
                ],

                // Email
                const _FieldLabel(
                  'البريد الإلكتروني',
                ),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'email@company.com',
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'البريد الإلكتروني مطلوب';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const _FieldLabel(
                      'كلمة المرور',
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          ctx,
                          AppRoutes.forgotPassword,
                        );
                      },
                      child: const Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'كلمة المرور',
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                      child: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textHint,
                        size: 18,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'كلمة المرور مطلوبة';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                AuthButton(
                  label: 'تسجيل الدخول',
                  onPressed: _submit,
                  isLoading: loading,
                ),
              ],
            ),
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
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }
}
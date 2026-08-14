import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/web_auth_layout.dart';
import '../../../../core/widgets/dashboard/auth_button.dart';
import '../../../../core/widgets/dashboard/error_banner.dart';
import '../../../../core/constants/app_routes.dart';

/// Admin login (owner / manager).
///
/// Login flow:
/// 1. Normal login -> Dashboard
/// 2. totp_setup_required -> TOTP setup screen (QR + secret)
/// 3. totp_required -> TOTP verification screen
/// 4. must_change_password -> Change password screen
class LoginScreen extends StatefulWidget {
  final String role; // 'owner' | 'manager'

  const LoginScreen({
    super.key,
    required this.role,
  });

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

  String get _roleLabel {
    return widget.role == 'owner' ? 'المالك' : 'المدير';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (ctx, state) {
        // ─────────────────────────────────────────────────────────────
        // FIRST TIME TOTP SETUP
        // Backend:
        // stage = totp_setup_required
        //
        // We need to show:
        // QR Code + Secret
        // ─────────────────────────────────────────────────────────────
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

        // ─────────────────────────────────────────────────────────────
        // TOTP ALREADY CONFIGURED
        // Backend:
        // stage = totp_required
        //
        // Go directly to 6-digit code screen.
        // ─────────────────────────────────────────────────────────────
        else if (state is AdminTotpRequired) {
          Navigator.pushNamed(
            ctx,
            AppRoutes.verifyTotp,
            arguments: state.challengeToken,
          );
        }

        // ─────────────────────────────────────────────────────────────
        // NORMAL LOGIN SUCCESS
        // ─────────────────────────────────────────────────────────────
        else if (state is AdminLoginSuccess) {
          Navigator.pushReplacementNamed(
            ctx,
            AppRoutes.adminDashboard,
          );
        }

        // ─────────────────────────────────────────────────────────────
        // FIRST LOGIN -> CHANGE PASSWORD
        // ─────────────────────────────────────────────────────────────
        else if (state is MustChangePassword) {
          Navigator.pushNamed(
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

                // ─────────────────────────────────────────────
                // HEADER
                // ─────────────────────────────────────────────

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
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

                        const SizedBox(height: 3),

                        Text(
                          'تسجيل دخول كـ $_roleLabel',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    _RoleBadge(
                      role: widget.role,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ─────────────────────────────────────────────
                // ERROR
                // ─────────────────────────────────────────────

                if (error != null) ...[
                  ErrorBanner(error),
                  const SizedBox(height: 16),
                ],

                // ─────────────────────────────────────────────
                // EMAIL
                // ─────────────────────────────────────────────

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
                      return 'هذا الحقل مطلوب';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ─────────────────────────────────────────────
                // PASSWORD
                // ─────────────────────────────────────────────

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

                  onFieldSubmitted: (_) {
                    _submit();
                  },

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

                // ─────────────────────────────────────────────
                // LOGIN BUTTON
                // ─────────────────────────────────────────────

                AuthButton(
                  label: 'تسجيل الدخول',
                  onPressed: _submit,
                  isLoading: loading,
                ),

                const SizedBox(height: 20),

                // ─────────────────────────────────────────────
                // CHANGE ROLE
                // ─────────────────────────────────────────────

                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        ctx,
                        AppRoutes.roleSelector,
                      );
                    },

                    child: const Text(
                      '← تغيير الدور',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


/// Login field label.
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


/// Owner / Manager badge.
class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final (
      Color color,
      IconData icon,
      String label,
    ) = role == 'owner'
        ? (
            const Color(0xFF7B1FA2),
            Icons.admin_panel_settings,
            'مالك',
          )
        : (
            AppColors.primary,
            Icons.manage_accounts,
            'مدير',
          );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),

          const SizedBox(width: 5),

          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
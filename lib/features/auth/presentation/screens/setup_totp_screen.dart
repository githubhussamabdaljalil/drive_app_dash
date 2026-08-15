import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/web_auth_layout.dart';
import '../../../../core/widgets/dashboard/auth_button.dart';
import '../../../../core/constants/app_routes.dart';

class SetupTotpScreen extends StatefulWidget {
  final String challengeToken;
  final String secret;
  final String provisioningUri;

  const SetupTotpScreen({
    super.key,
    required this.challengeToken,
    required this.secret,
    required this.provisioningUri,
  });

  @override
  State<SetupTotpScreen> createState() =>
      _SetupTotpScreenState();
}

class _SetupTotpScreenState
    extends State<SetupTotpScreen> {

  Future<void> _copySecret() async {
    await Clipboard.setData(
      ClipboardData(
        text: widget.secret,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم نسخ المفتاح السري',
        ),
      ),
    );
  }

  void _continue() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.verifyTotp,
      arguments: widget.challengeToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebAuthLayout(
      cardWidth: 460,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          const Text(
            'إعداد التحقق بخطوتين',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'قم بإضافة الحساب إلى Google Authenticator قبل المتابعة.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // ----------------------------------------------------------
          // QR
          // ----------------------------------------------------------

          Center(
            child: Container(
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: QrImageView(
                data:
                    widget.provisioningUri,
                version:
                    QrVersions.auto,
                size: 220,
                backgroundColor:
                    Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'طريقة الإعداد',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            '1. افتح تطبيق Google Authenticator على هاتفك.\n'
            '2. اختر إضافة حساب جديد.\n'
            '3. امسح رمز QR الموجود أعلاه.\n'
            '4. إذا لم تتمكن من مسح الرمز، استخدم المفتاح السري بالأسفل.',
            style: TextStyle(
              fontSize: 13,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'المفتاح السري',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [

                Expanded(
                  child: Directionality(
                    textDirection:
                        TextDirection.ltr,
                    child: Text(
                      widget.secret,
                      style:
                          const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                        letterSpacing: 1.1,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  tooltip: 'نسخ',
                  onPressed:
                      _copySecret,
                  icon: const Icon(
                    Icons.copy_outlined,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          AuthButton(
            label: 'متابعة',
            onPressed: _continue,
          ),

          const SizedBox(height: 16),

          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.login,
                );
              },
              child: const Text(
                '← تسجيل الدخول من جديد',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
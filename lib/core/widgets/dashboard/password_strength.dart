import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PasswordStrengthRow extends StatelessWidget {
  final String label;
  final bool met;
  const PasswordStrengthRow({super.key, required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 14, color: met ? AppColors.success : AppColors.textHint),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 12,
          color: met ? AppColors.success : AppColors.textHint,
          fontWeight: met ? FontWeight.w600 : FontWeight.w400)),
    ]);
  }
}

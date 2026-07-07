import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Full-screen centered card layout — used by all auth screens on web
class WebAuthLayout extends StatelessWidget {
  final Widget child;
  final double cardWidth;

  const WebAuthLayout({super.key, required this.child, this.cardWidth = 420});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo + Brand
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('VTFMS',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary, letterSpacing: .5)),
              ]),
              const SizedBox(height: 28),
              // Card
              Container(
                width: cardWidth,
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(.07),
                        blurRadius: 24, offset: const Offset(0, 4)),
                  ],
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

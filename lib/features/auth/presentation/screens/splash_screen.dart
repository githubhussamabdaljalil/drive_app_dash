import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/storage/local_storage_service.dart';

/// Splash Screen
///
/// Checks whether the user is already authenticated.
///
/// Flow:
/// - Token + role exists -> Dashboard
/// - Otherwise -> Login
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _setupAnimations();
    _checkAuthStatus();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  Future<void> _checkAuthStatus() async {
    // Minimum splash duration
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    final storage = LocalStorageService.instance;

    final token = storage.getToken();
    final role = storage.getRole();

    if (token != null &&
        token.isNotEmpty &&
        role != null &&
        role.isNotEmpty) {
      _navigateToHome(role);
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToHome(String role) {
    switch (role) {
      case 'owner':
      case 'manager':
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.adminDashboard,
        );
        break;

      default:
        // Invalid/unknown role -> login again
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
        );
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.login,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_shipping_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'VTFMS',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'نظام إدارة الأساطيل والمركبات',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 48),

                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
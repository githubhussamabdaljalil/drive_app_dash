import 'package:flutter/material.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/change_password_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/attendance/presentation/screens/attendance_screen.dart';
import 'features/vehicle_linking/presentation/screens/vehicle_linking_screen.dart';
import 'features/vehicle_linking/presentation/screens/qr_scanner_screen.dart';
import 'features/route_management/presentation/screens/route_screen.dart';
import 'features/route_management/presentation/screens/navigation_screen.dart';
import 'features/route_management/presentation/screens/route_history_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';

class VTFMSApp extends StatelessWidget {
  const VTFMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VTFMS Driver',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // تفعيل RTL للغة العربية (حسب SRS — دعم RTL إلزامي)
      builder: (ctx, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login:           (_) => const LoginScreen(),
        AppRoutes.changePassword:  (_) => const ChangePasswordScreen(),
        AppRoutes.forgotPassword:  (_) => const ForgotPasswordScreen(),
        AppRoutes.home:            (_) => const HomeScreen(),
        AppRoutes.attendance:      (_) => const AttendanceScreen(),
        AppRoutes.vehicleLinking:  (_) => const VehicleLinkingScreen(),
        AppRoutes.qrScanner:       (_) => const QrScannerScreen(),
        AppRoutes.route:           (_) => const RouteScreen(),
        AppRoutes.navigation:      (_) => const NavigationScreen(),
        AppRoutes.routeHistory:    (_) => const RouteHistoryScreen(),
        AppRoutes.notifications:   (_) => const NotificationsScreen(),
        AppRoutes.profile:         (_) => const ProfileScreen(),
      },
    );
  }
}

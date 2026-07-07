import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Auth
import 'features/auth/presentation/screens/role_selector_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/verify_otp_screen.dart';
import 'features/auth/presentation/screens/change_password_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';

// Admin screens
import 'features/home/presentation/screens/admin_dashboard_screen.dart';
import 'features/home/presentation/screens/companies_screen.dart';
import 'features/home/presentation/screens/vehicles_screen.dart';
import 'features/home/presentation/screens/drivers_screen.dart';
import 'features/home/presentation/screens/destinations_screen.dart';
import 'features/home/presentation/screens/tracking_screen.dart';
import 'features/home/presentation/screens/sos_events_screen.dart';
import 'features/home/presentation/screens/route_history_screen.dart';
import 'features/home/presentation/screens/qr_codes_screen.dart';
import 'features/home/presentation/screens/sub_managers_screen.dart';
import 'features/home/presentation/screens/guest_codes_screen.dart';
import 'features/home/presentation/screens/admin_notifications_screen.dart';
import 'features/home/presentation/screens/reports_screen.dart';

// Driver screens
import 'features/home/presentation/screens/driver_home_screen.dart';
import 'features/route_management/presentation/screens/driver_route_screen.dart';
import 'features/route_management/presentation/screens/driver_history_screen.dart';
import 'features/attendance/presentation/screens/attendance_screen.dart';
import 'features/vehicle_linking/presentation/screens/vehicle_linking_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/emergency/presentation/screens/emergency_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';

class VTFMSApp extends StatelessWidget {
  const VTFMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: MaterialApp(
        title: 'VTFMS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        // RTL for Arabic
        builder: (ctx, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        ),
        initialRoute: AppRoutes.roleSelector,
        onGenerateRoute: (settings) {
          switch (settings.name) {

            // ── Auth ─────────────────────────────────────────────────
            case AppRoutes.roleSelector:
              return _r(settings, const RoleSelectorScreen());

            case AppRoutes.login:
              final role = settings.arguments as String? ?? 'manager';
              return _r(settings, LoginScreen(role: role));

            case AppRoutes.verifyOtp:
              final phone = settings.arguments as String? ?? '';
              return _r(settings, VerifyOtpScreen(phone: phone));

            case AppRoutes.verifyTotp:
              final token = settings.arguments as String? ?? '';
              return _r(settings,
                  VerifyOtpScreen(phone: '', isTotp: true, challengeToken: token));

            case AppRoutes.changePassword:
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              return _r(settings,
                  ChangePasswordScreen(isDriver: args['isDriver'] == true));

            case AppRoutes.forgotPassword:
              return _r(settings, const ForgotPasswordScreen());

            // ── Admin ─────────────────────────────────────────────────
            case AppRoutes.adminDashboard: return _r(settings, const AdminDashboardScreen());
            case AppRoutes.companies:      return _r(settings, const CompaniesScreen());
            case AppRoutes.vehicles:       return _r(settings, const VehiclesScreen());
            case AppRoutes.drivers:        return _r(settings, const DriversScreen());
            case AppRoutes.destinations:   return _r(settings, const DestinationsScreen());
            case AppRoutes.tracking:       return _r(settings, const TrackingScreen());
            case AppRoutes.sosEvents:      return _r(settings, const SosEventsScreen());
            case AppRoutes.routeHistory:   return _r(settings, const RouteHistoryScreen());
            case AppRoutes.qrCodes:        return _r(settings, const QrCodesScreen());
            case AppRoutes.subManagers:    return _r(settings, const SubManagersScreen());
            case AppRoutes.guestCodes:     return _r(settings, const GuestCodesScreen());
            case AppRoutes.notifications:  return _r(settings, const AdminNotificationsScreen());
            case AppRoutes.reports:        return _r(settings, const ReportsScreen());

            // ── Driver ─────────────────────────────────────────────────
            case AppRoutes.driverHome:     return _r(settings, const DriverHomeScreen());
            case AppRoutes.route:          return _r(settings, const DriverRouteScreen());
            case AppRoutes.driverHistory:  return _r(settings, const DriverHistoryScreen());
            case AppRoutes.attendance:     return _r(settings, const AttendanceScreen());
            case AppRoutes.vehicleLinking: return _r(settings, const VehicleLinkingScreen());
            case AppRoutes.driverNotif:    return _r(settings, const NotificationsScreen());
            case AppRoutes.emergency:      return _r(settings, const EmergencyScreen());
            case AppRoutes.profile:        return _r(settings, const ProfileScreen());

            default:
              return _r(settings, const RoleSelectorScreen());
          }
        },
      ),
    );
  }

  static MaterialPageRoute _r(RouteSettings s, Widget w) =>
      MaterialPageRoute(settings: s, builder: (_) => w);
}

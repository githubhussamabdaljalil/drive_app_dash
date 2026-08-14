import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/companies/presentation/cubit/company_cubit.dart';
import 'features/drivers/presentation/cubit/driver_cubit.dart';
import 'features/vehicles/presentation/cubit/vehicle_cubit.dart';
import 'features/owner/presentation/cubit/owner_statistics_cubit.dart';
import 'features/owner/presentation/cubit/owner_reports_cubit.dart';
import 'features/destinations/presentation/cubit/destination_cubit.dart';
import 'features/sos/presentation/cubit/sos_cubit.dart';
import 'features/qr_codes/presentation/cubit/qr_code_cubit.dart';
import 'features/guest_codes/presentation/cubit/guest_code_cubit.dart';
import 'features/sub_managers/presentation/cubit/sub_manager_cubit.dart';
import 'features/manager_notifications/presentation/cubit/manager_notification_cubit.dart';
import 'features/manager_reports/presentation/cubit/manager_reports_cubit.dart';

// Auth
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/role_selector_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/verify_otp_screen.dart';
import 'features/auth/presentation/screens/change_password_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';

// Admin screens (owner + manager)
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
import 'features/owner_profile/presentation/screens/profile_screen.dart';
import 'features/manager_reports/presentation/screens/manager_reports_screen.dart';
import 'core/services/storage/local_storage_service.dart';

class VTFMSApp extends StatelessWidget {
  const VTFMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => CompanyCubit(), lazy: true),
        BlocProvider(create: (_) => DriverCubit(), lazy: true),
        BlocProvider(create: (_) => VehicleCubit(), lazy: true),
        BlocProvider(create: (_) => OwnerStatisticsCubit(), lazy: true),
        BlocProvider(create: (_) => OwnerReportsCubit(), lazy: true),
        BlocProvider(create: (_) => DestinationCubit(), lazy: true),
        BlocProvider(create: (_) => SosCubit(), lazy: true),
        BlocProvider(create: (_) => QrCodeCubit(), lazy: true),
        BlocProvider(create: (_) => GuestCodeCubit(), lazy: true),
        BlocProvider(create: (_) => SubManagerCubit(), lazy: true),
        BlocProvider(create: (_) => ManagerNotificationCubit(), lazy: true),
        BlocProvider(create: (_) => ManagerReportsCubit(), lazy: true),
      ],
      child: MaterialApp(
        title: 'VTFMS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        builder: (ctx, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        initialRoute: AppRoutes.splash,
        // initialRoute: AppRoutes.adminDashboard,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            // ── Auth ─────────────────────────────────────────────────
            case AppRoutes.splash:
              return _r(settings, const SplashScreen());

            case AppRoutes.roleSelector:
              return _r(settings, const RoleSelectorScreen());

            case AppRoutes.login:
              final role = settings.arguments as String? ?? 'manager';
              return _r(settings, LoginScreen(role: role));

            case AppRoutes.verifyTotp:
              final token = settings.arguments as String? ?? '';
              return _r(settings, VerifyOtpScreen(challengeToken: token));

            case AppRoutes.changePassword:
              return _r(settings, const ChangePasswordScreen());

            case AppRoutes.forgotPassword:
              return _r(settings, const ForgotPasswordScreen());

            // ── Admin ─────────────────────────────────────────────────
            case AppRoutes.adminDashboard:
              return _r(settings, const AdminDashboardScreen());
            case AppRoutes.companies:
              return _r(settings, const CompaniesScreen());
            case AppRoutes.vehicles:
              return _r(settings, const VehiclesScreen());
            case AppRoutes.drivers:
              return _r(settings, const DriversScreen());
            case AppRoutes.destinations:
              return _r(settings, const DestinationsScreen());
            case AppRoutes.tracking:
              return _r(settings, const TrackingScreen());
            case AppRoutes.sosEvents:
              return _r(settings, const SosEventsScreen());
            case AppRoutes.routeHistory:
              return _r(settings, const RouteHistoryScreen());
            case AppRoutes.qrCodes:
              return _r(settings, const QrCodesScreen());
            case AppRoutes.subManagers:
              return _r(settings, const SubManagersScreen());
            case AppRoutes.guestCodes:
              return _r(settings, const GuestCodesScreen());
            case AppRoutes.notifications:
              return _r(settings, const AdminNotificationsScreen());
            case AppRoutes.reports:
              // Owner keeps the platform-wide report (owner's own feature,
              // untouched here). Manager gets the company-scoped report
              // wired to GET /admin/manager/reports — see manager_reports/.
              final role = LocalStorageService.instance.getRole();
              return _r(
                settings,
                role == 'owner' ? const ReportsScreen() : const ManagerReportsScreen(),
              );
            case AppRoutes.profile:
              return _r(settings, const ProfileScreen());

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

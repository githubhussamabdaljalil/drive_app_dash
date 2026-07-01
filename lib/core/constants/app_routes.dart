/// AppRoutes — مرجع مركزي لكل routes في التطبيق
/// كل route مسجل هنا بحيث ما في magic strings مكررة
class AppRoutes {
  AppRoutes._();

  static const String login         = '/login';
  static const String changePassword = '/change-password';
  static const String forgotPassword = '/forgot-password';

  static const String home           = '/';
  static const String notifications  = '/notifications';
  static const String profile        = '/profile';

  static const String attendance     = '/attendance';
  static const String vehicleLinking = '/vehicle-linking';
  static const String qrScanner     = '/qr-scanner';

  static const String route          = '/route';
  static const String navigation     = '/navigation';
  static const String routeHistory   = '/route-history';

  static const String emergency      = '/emergency';
}

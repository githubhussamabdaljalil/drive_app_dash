class AppRoutes {
  AppRoutes._();

  // ── Auth ────────────────────────────────────────────────────────────
  static const String splash = '/';

  static const String login = '/login';
  static const String verifyTotp = '/verify-totp';
  static const String changePassword = '/change-password';
  static const String forgotPassword = '/forgot-password';
  static const String setupTotp = '/setup-totp';
  // ── Admin (owner + manager) ─────────────────────────────────────────
  static const String adminDashboard = '/admin/dashboard';
  static const String companies = '/admin/companies';
  static const String vehicles = '/admin/vehicles';
  static const String drivers = '/admin/drivers';
  static const String destinations = '/admin/destinations';
  static const String tracking = '/admin/tracking';
  static const String sosEvents = '/admin/sos-events';
  static const String routeHistory = '/admin/route-history';
  static const String qrCodes = '/admin/qr-codes';
  static const String subManagers = '/admin/sub-managers';
  static const String guestCodes = '/admin/guest-codes';
  static const String notifications = '/admin/notifications';
  static const String reports = '/admin/reports';
  static const String profile = '/admin/profile';

  // ── Guest ────────────────────────────────────────────────────────────
  static const String guest = '/guest';
  static const String guestTrack = '/guest/track';
}

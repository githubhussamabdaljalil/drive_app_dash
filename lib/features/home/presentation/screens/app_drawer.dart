import 'package:flutter/material.dart';

/// AppDrawer — دراور السائق الشامل
/// يحتوي على كل الفيتشرات حسب SRS:
///   - معلومات السائق والمركبة المرتبطة
///   - تسجيل الحضور / الانصراف
///   - ربط مركبة (QR أو كود)
///   - المسارات (المهمة الحالية + السجل)
///   - الإشعارات
///   - الملف الشخصي
///   - تسجيل الخروج
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      child: Column(
        children: [
          // ── Header: معلومات السائق ──────────────────────────────────────
          _DrawerHeader(),

          // ── القائمة الرئيسية ─────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),

                // -- بطاقة الحضور (check-in/out) ─────────────────────────
                _AttendanceCard(),

                const _SectionDivider(label: 'المركبة'),

                _DrawerItem(
                  icon: Icons.qr_code_scanner,
                  iconColor: const Color(0xFF1976D2),
                  title: 'ربط مركبة',
                  subtitle: 'مسح QR أو إدخال كود',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/vehicle-linking');
                  },
                ),

                const _SectionDivider(label: 'المهام والمسارات'),

                _DrawerItem(
                  icon: Icons.navigation_outlined,
                  iconColor: const Color(0xFF388E3C),
                  title: 'المهمة الحالية',
                  subtitle: 'عرض الوجهة والملاحة',
                  badge: 'نشط',
                  badgeColor: const Color(0xFF388E3C),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/route');
                  },
                ),

                _DrawerItem(
                  icon: Icons.history,
                  iconColor: const Color(0xFF0288D1),
                  title: 'سجل المسارات',
                  subtitle: 'المسارات السابقة',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/route-history');
                  },
                ),

                const _SectionDivider(label: 'عام'),

                _DrawerItem(
                  icon: Icons.notifications_outlined,
                  iconColor: const Color(0xFFF57C00),
                  title: 'الإشعارات',
                  subtitle: 'التنبيهات والأحداث',
                  badge: '3',
                  badgeColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),

                _DrawerItem(
                  icon: Icons.person_outline,
                  iconColor: const Color(0xFF5C6BC0),
                  title: 'الملف الشخصي',
                  subtitle: 'تعديل بياناتك وكلمة المرور',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),

                const SizedBox(height: 8),
                const Divider(indent: 16, endIndent: 16),

                // ── تسجيل الخروج ──────────────────────────────────────
                _DrawerItem(
                  icon: Icons.logout,
                  iconColor: Colors.red,
                  title: 'تسجيل الخروج',
                  onTap: () => _showLogoutDialog(context),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Footer: إصدار التطبيق ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Text(
              'VTFMS Driver v1.0.0',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              // TODO: trigger AuthBloc logout event
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}

// ── Header Widget ─────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة السائق
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 12),

          // اسم السائق
          const Text(
            'محمد أحمد',                // TODO: من AuthBloc
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),

          // البريد
          const Text(
            'driver@company.com',       // TODO: من AuthBloc
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),

          // بادج المركبة المرتبطة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.directions_car, color: Colors.white, size: 14),
                SizedBox(width: 5),
                Text(
                  'أ·م·ع 1234',          // TODO: من HomeBloc
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Attendance Card ───────────────────────────────────────────────────────

/// بطاقة Check-In / Check-Out بارزة في الدراور
class _AttendanceCard extends StatelessWidget {
  // TODO: الحالة الحقيقية تيجي من AttendanceBloc
  final bool isCheckedIn = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCheckedIn
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCheckedIn
              ? const Color(0xFF81C784)
              : const Color(0xFFFFB74D),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCheckedIn ? Icons.work : Icons.work_off_outlined,
            color: isCheckedIn ? const Color(0xFF388E3C) : const Color(0xFFF57C00),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCheckedIn ? 'في الدوام' : 'خارج الدوام',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isCheckedIn ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                  ),
                ),
                Text(
                  isCheckedIn ? 'بدأ: 08:00 ص' : 'اضغط لتسجيل الحضور',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/attendance');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isCheckedIn
                  ? const Color(0xFFD32F2F)
                  : const Color(0xFF388E3C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isCheckedIn ? 'انصراف' : 'حضور',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drawer Item ───────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 11, color: Colors.grey))
          : null,
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor ?? Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge!,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            )
          : const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      onTap: onTap,
    );
  }
}

// ── Section Divider ───────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(height: 1)),
        ],
      ),
    );
  }
}

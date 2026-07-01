import 'package:flutter/material.dart';
import '../widgets/map_view.dart';
import '../widgets/vehicle_status_card.dart';
import '../widgets/active_route_banner.dart';
import '../widgets/sos_button.dart';
import 'app_drawer.dart';

/// Home Screen — الشاشة الرئيسية للسائق
/// تحتوي على: الخريطة الحية + بانر المسار النشط + زر SOS + الدراور
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // ── طبقة 1: الخريطة (تملأ الشاشة كاملة) ──────────────────────
          const MapView(),

          // ── طبقة 2: AppBar مخصص شفاف فوق الخريطة ─────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // زر فتح الدراور
                  _MapIconButton(
                    icon: Icons.menu,
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const Spacer(),
                  // بادج الإشعارات
                  _NotificationButton(),
                ],
              ),
            ),
          ),

          // ── طبقة 3: بانر المسار النشط (يظهر فقط لما في مهمة) ─────────
          const Positioned(
            top: 70,
            left: 12,
            right: 12,
            child: ActiveRouteBanner(),
          ),

          // ── طبقة 4: بطاقة حالة المركبة (أسفل الشاشة) ─────────────────
          Positioned(
            bottom: 100,
            left: 12,
            right: 12,
            child: VehicleStatusCard(),
          ),

          // ── طبقة 5: زر SOS (أسفل يمين — دائمًا ظاهر) ────────────────
          const Positioned(
            bottom: 24,
            right: 16,
            child: SosButton(),
          ),
        ],
      ),
    );
  }
}

// ── Widgets مساعدة داخل الهوم ──────────────────────────────────────────────

class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _MapIconButton(
          icon: Icons.notifications_outlined,
          onTap: () => Navigator.pushNamed(context, '/notifications'),
        ),
        // بادج العدد (يظهر لما في إشعارات غير مقروءة)
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '3',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

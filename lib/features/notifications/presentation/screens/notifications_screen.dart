import 'package:flutter/material.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/constants/app_routes.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: '/driver/notifications',
      pageTitle: 'الإشعارات',
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Icon(Icons.construction_outlined, size: 48, color: Color(0xFF9AA5B8)),
          SizedBox(height: 12),
          Text('الإشعارات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
              color: Color(0xFF1A2A4A))),
          SizedBox(height: 6),
          Text('TODO: implement this screen',
              style: TextStyle(fontSize: 13, color: Color(0xFF9AA5B8))),
        ]),
      ),
    );
  }
}

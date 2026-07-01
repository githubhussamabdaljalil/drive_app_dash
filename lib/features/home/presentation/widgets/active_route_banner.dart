import 'package:flutter/material.dart';

/// ActiveRouteBanner — بانر المهمة النشطة فوق الخريطة
/// يظهر فقط لما السائق عنده وجهة مرسلة (REQ-Route Manage-05)
class ActiveRouteBanner extends StatelessWidget {
  const ActiveRouteBanner({super.key});

  // TODO: اربطه بـ RouteBloc لتحديد ما إذا في مهمة نشطة
  final bool hasActiveRoute = true;

  @override
  Widget build(BuildContext context) {
    if (!hasActiveRoute) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Color(0xFF388E3C), shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('وجهة نشطة', style: TextStyle(fontSize: 11, color: Colors.grey)),
                Text('مستودع الشركة — الميدان', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/navigation'),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('فتح الملاحة ›', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

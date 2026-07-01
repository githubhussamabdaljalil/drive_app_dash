import 'package:flutter/material.dart';

/// VehicleStatusCard — بطاقة حالة المركبة المرتبطة
/// تظهر رقم اللوحة + حالة الدوام + زر QR Scan السريع
class VehicleStatusCard extends StatelessWidget {
  // TODO: البيانات الحقيقية من HomeBloc
  final String? linkedPlate = 'أ·م·ع 1234';
  final bool isCheckedIn = false;

  @override
  Widget build(BuildContext context) {
    if (linkedPlate == null) {
      // السائق غير مرتبط بمركبة — اظهر زر الربط
      return _LinkVehiclePrompt(context);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_car, color: Color(0xFF1565C0), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  linkedPlate!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  isCheckedIn ? 'في الدوام — الموقع يُبث' : 'خارج الدوام',
                  style: TextStyle(
                    fontSize: 11,
                    color: isCheckedIn ? const Color(0xFF388E3C) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // مؤشر بث GPS
          if (isCheckedIn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.gps_fixed, color: Color(0xFF388E3C), size: 12),
                  SizedBox(width: 3),
                  Text('Live', style: TextStyle(color: Color(0xFF388E3C), fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _LinkVehiclePrompt(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/vehicle-linking'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFB74D)),
        ),
        child: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Color(0xFFF57C00)),
            SizedBox(width: 12),
            Text('اضغط لربط مركبة', style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

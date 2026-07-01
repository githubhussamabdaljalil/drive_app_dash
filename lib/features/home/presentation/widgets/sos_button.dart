import 'package:flutter/material.dart';

/// SosButton — زر الطوارئ SOS الدائم
/// REQ-SHIP-01: يجب أن يتمكن السائق من إرسال تنبيه SOS في حالات الطوارئ
class SosButton extends StatelessWidget {
  const SosButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _onSOSTriggered(context),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFB71C1C),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0x66B71C1C),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.warning_rounded, color: Colors.white, size: 22),
            Text('SOS', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _onSOSTriggered(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('طوارئ SOS'),
          ],
        ),
        content: const Text('هل تريد إرسال تنبيه طوارئ؟\nسيتم إرسال موقعك الحالي للمدير فورًا.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: EmergencyBloc.add(SendSOSEvent())
            },
            child: const Text('إرسال SOS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

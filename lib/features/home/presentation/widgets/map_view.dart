import 'package:flutter/material.dart';

/// MapView — placeholder للخريطة الحية
/// استبدلها بـ flutter_map أو google_maps_flutter
class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8EAF0),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Color(0xFF90A4AE)),
            SizedBox(height: 8),
            Text('الخريطة الحية', style: TextStyle(color: Color(0xFF607D8B))),
            Text('flutter_map / google_maps_flutter', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

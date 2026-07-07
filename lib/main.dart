import 'package:flutter/material.dart';
import 'core/services/storage/local_storage_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.instance.init();
  runApp(const VTFMSApp());
}

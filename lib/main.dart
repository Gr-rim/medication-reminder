import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication_reminder/app/app.dart';
import 'package:medication_reminder/services/hive_service.dart';
import 'package:medication_reminder/services/notification_service.dart';

void main() async {
  // Required for plugins that use platform channels (e.g., Hive, notifications)
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database (Hive)
  await HiveService.init();

  // Initialize notification service (requests permissions, sets up plugin)
  await NotificationService.init();

  // Launch the app
  runApp(const ProviderScope(child: App()));
}

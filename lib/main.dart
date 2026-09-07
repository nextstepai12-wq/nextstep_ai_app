// lib/main.dart

import 'package:flutter/material.dart';

import 'package:nextstep_ai_app/app.dart';
import 'package:nextstep_ai_app/core/di/service_locator.dart';
import 'package:nextstep_ai_app/core/helpers/app_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive + Supabase
  await AppInitializer.init();

  // Register dependencies
  await setupServiceLocator();

  runApp(const MyApp());
}
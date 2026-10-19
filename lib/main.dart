import 'package:flutter/material.dart';

import 'package:nextstep_ai_app/app.dart';
import 'package:nextstep_ai_app/core/di/service_locator.dart';
import 'package:nextstep_ai_app/core/helpers/app_initializer.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppInitializer.init();
  await AppTheme.loadPersistedThemeMode();

  await setupServiceLocator();

  runApp(const MyApp());
}

import 'package:flutter/material.dart';

import 'package:nextstep_ai_app/features/university/ui/screens/university_profile_screen.dart';

/// The settings tab and the profile route share the same premium
/// "Profile & Settings" experience, so this screen simply renders
/// [UniversityProfileScreen].
class UniversitySettingsScreen extends StatelessWidget {
  const UniversitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UniversityProfileScreen();
  }
}

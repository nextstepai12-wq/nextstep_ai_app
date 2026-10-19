import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../networking/supabase_service.dart';
import 'token_manager.dart';

/// Clears the locally persisted session and returns to the sign-in screen.
///
/// The current project has no production auth backend yet; calling
/// [SupabaseService.signOut] keeps this helper ready for the real
/// implementation without changing any account-provisioning rules.
Future<void> logoutToLogin(BuildContext context) async {
  await TokenManager.clearAll();
  try {
    await SupabaseService().signOut();
  } catch (_) {
    // Local session is already cleared; never block sign-out on the stub.
  }
  if (context.mounted) {
    context.go('/login');
  }
}

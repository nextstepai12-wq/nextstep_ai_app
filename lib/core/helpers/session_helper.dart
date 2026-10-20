import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../networking/supabase_service.dart';
import 'token_manager.dart';






Future<void> logoutToLogin(BuildContext context) async {
  await TokenManager.clearAll();
  try {
    await SupabaseService().signOut();
  } catch (_) {
    
  }
  if (context.mounted) {
    context.go('/login');
  }
}

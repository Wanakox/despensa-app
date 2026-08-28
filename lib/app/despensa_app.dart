import 'package:flutter/material.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/households/presentation/households_screen.dart';
import '../core/services/auth_service.dart';
import 'theme/app_theme.dart';

class DespensaApp extends StatelessWidget {
  const DespensaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Despensa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AuthService.currentUser == null
          ? const LoginScreen()
          : const HouseholdsScreen(),
    );
  }
}

import 'package:flutter/material.dart';

import '../features/auth/presentation/login_screen.dart';
import 'theme/app_theme.dart';

class DespensaApp extends StatelessWidget {
  const DespensaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Despensa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginScreen(),
    );
  }
}

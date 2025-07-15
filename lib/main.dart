import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/app/main_app.dart';

void main() {
  runApp(const ProviderScope(child: MagicScanApp()));
}

/// Componente atómico principal - App Root
class MagicScanApp extends StatelessWidget {
  const MagicScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MagicScan',
      debugShowCheckedModeBanner: false,

      // Theme atómico
      theme: AppTheme.lightTheme,

      // App principal atómica
      home: const MainApp(),
    );
  }
}

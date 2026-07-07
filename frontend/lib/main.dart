import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/api_service.dart';

/// Shared single instance of the API client for the whole app.
final ApiService api = ApiService();

void main() {
  runApp(const StoreAdminApp());
}

class StoreAdminApp extends StatelessWidget {
  const StoreAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5));
    return MaterialApp(
      title: 'Store Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

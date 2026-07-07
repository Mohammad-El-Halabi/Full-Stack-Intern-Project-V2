import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

/// Shared single instance of the API client for the whole app.
final ApiService api = ApiService();

void main() {
  runApp(const StoreAdminApp());
}

class StoreAdminApp extends StatelessWidget {
  const StoreAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HomeScreen(),
    );
  }
}

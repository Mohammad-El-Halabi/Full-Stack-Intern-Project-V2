import 'package:flutter/foundation.dart';

/// Central place for the backend API base URL.
///
/// - Web / Windows desktop reach the API on `localhost`.
/// - The Android emulator reaches the host machine on the special IP
///   `10.0.2.2` instead of `localhost`.
///
/// You can also override this at build/run time without touching code:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8080
class ApiConfig {
  ApiConfig._();

  static const String _override =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  /// Root of the REST API.
  static String get apiUrl => '$baseUrl/api';
}

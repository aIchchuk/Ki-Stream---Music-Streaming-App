import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api';
    }
    // Windows, macOS, iOS (physical devices need IP), etc.
    return 'http://localhost:5000/api';
  }

  static String get baseStaticUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/public';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/public';
    }
    return 'http://localhost:5000/public';
  }
}

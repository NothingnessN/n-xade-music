import 'package:flutter/foundation.dart';

class DebugLogger {
  static void log(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print(message);
    }
  }
} 
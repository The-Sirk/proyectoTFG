import 'package:flutter/material.dart';

class AppLogger {
  static void logMethod(String methodName, {String? message}) {
    debugPrint('\x1B[36m[ENTRANDO] $methodName\x1B[0m${message != null ? ' - $message' : ''}');
  }

  static void logVar(String varName, dynamic value) {
    debugPrint('\x1B[33m[VARIABLE] $varName: $value\x1B[0m');
  }

  static void logInfo(String info) {
    debugPrint('\x1B[32m[INFO] $info\x1B[0m');
  }

  static void logWarning(String warning) {
    debugPrint('\x1B[35m[WARNING] $warning\x1B[0m');
  }

  static void logError(String error) {
    debugPrint('\x1B[31m[ERROR] $error\x1B[0m');
  }
}

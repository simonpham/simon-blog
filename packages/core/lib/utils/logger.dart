import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

void printLog(dynamic log) {
  if (!kDebugMode) {
    return;
  }
  developer.log(
    '💬 $log',
    name: 'SoFluffy',
  );
}

void printError(dynamic err, StackTrace trace) {
  if (!kDebugMode) {
    return;
  }
  developer.log(
    '🐞 $err',
    error: err,
    stackTrace: trace,
    name: 'SoFluffy',
  );
}

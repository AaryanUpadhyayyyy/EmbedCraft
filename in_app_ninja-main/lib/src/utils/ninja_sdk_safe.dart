import 'dart:async';

import 'package:flutter/foundation.dart';

import 'ninja_logger.dart';

/// Invokes an optional zero-arg callback without letting failures crash the host app.
void ninjaSdkSafeOptional(Function()? fn, {String? context}) {
  if (fn == null) return;
  ninjaSdkSafeSync(() => fn(), context: context);
}

/// Internal SDK error boundary — logs and swallows errors so host apps are not torn down.
void ninjaSdkSafeSync(void Function() fn, {String? context}) {
  try {
    fn();
  } catch (e, st) {
    ninjaSdkLogError(e, st, context);
  }
}

/// Runs an async block and returns `null` on any failure.
Future<T?> ninjaSdkSafeAsync<T>(Future<T> Function() fn, {String? context}) async {
  try {
    return await fn();
  } catch (e, st) {
    ninjaSdkLogError(e, st, context);
    return null;
  }
}

/// Fire-and-forget [Future] that must not surface errors to the host zone.
void ninjaSdkSafeUnawaited(Future<void> future, {String? context}) {
  unawaited(
    future.catchError((e, st) {
      ninjaSdkLogError(e, st, context);
    }),
  );
}

/// Logs an SDK error using the unified [NinjaLog] format.
/// Always visible (errors are never silenced), includes stack trace in debug mode.
void ninjaSdkLogError(Object e, Object? st, [String? context]) {
  final tag = context != null && context.isNotEmpty ? context : 'NinjaSDK';
  NinjaLog.e(tag, '$e', stack: st is StackTrace ? st : null);
}

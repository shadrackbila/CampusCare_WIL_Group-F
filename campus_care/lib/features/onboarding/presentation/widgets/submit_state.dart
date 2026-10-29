import 'package:flutter/widgets.dart';

import '../../../../core/errors/app_exception.dart';

/// Shared loading/error handling for the step screens.
mixin SubmitState<T extends StatefulWidget> on State<T> {
  bool loading = false;
  String? error;

  /// Runs [action]; shows the friendly error on failure. On success the provider
  /// advances the step, which replaces this widget, so we only touch state if still mounted.
  Future<void> run(Future<void> Function() action) async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await action();
      if (mounted) setState(() => loading = false);
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          error = e.message;
          loading = false;
        });
      }
    }
  }
}

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class OtaUpdater with WidgetsBindingObserver {
  final _updater = ShorebirdUpdater();

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    await _checkAndUpdate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // check again when the app returns to foreground
      unawaited(_checkAndUpdate());
    }
  }

  Future<void> _checkAndUpdate() async {
    if (!_updater.isAvailable) return;
    final status = await _updater.checkForUpdate(); // returns UpdateStatus
    // You can switch track: checkForUpdate(track: UpdateTrack.stable)
    if (status == UpdateStatus.outdated) {
      await _updater.update(); // downloads + stages patch, then restarts when safe
    }
  }

  void dispose() => WidgetsBinding.instance.removeObserver(this);
}
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// La demostración sustituye al servicio solo en memoria.
final demoModeProvider = NotifierProvider<DemoModeController, bool>(
  DemoModeController.new,
);

class DemoModeController extends Notifier<bool> {
  @override
  bool build() => false;

  void enable() => state = true;

  void disable() => state = false;
}

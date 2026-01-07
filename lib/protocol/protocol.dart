import 'package:govee_lights_control/device.dart';
import 'package:meta/meta.dart';

/// A protocol for controlling a light.
abstract class Protocol {
  /// Creates a new [Protocol].
  Protocol({
    required this.device,
    this.tickInterval = const Duration(minutes: 1),
  });

  /// The device to control.
  final Device device;

  /// The interval between ticks.
  @nonVirtual
  final Duration tickInterval;

  /// The function that is called every tick.
  Future<bool> tick(DateTime time);

  /// Runs the protocol.
  @nonVirtual
  Future<void> run() async {
    while (true) {
      final now = DateTime.now();

      final shouldContinue = await tick(now);
      if (!shouldContinue) break;

      await Future<void>.delayed(tickInterval);
    }
  }
}

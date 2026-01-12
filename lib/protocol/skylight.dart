import 'dart:io';
import 'dart:math';

import 'package:govee_lights_control/control.dart';
import 'package:govee_lights_control/protocol/protocol.dart';

/// Sets the light based on the sun.
class Skylight extends Protocol {
  /// Creates a new [Skylight].
  Skylight({
    required super.device,
    required this.sunrise,
    required this.sunset,
  });

  /// The sunrise time.
  final DateTime sunrise;

  /// The sunset time.
  final DateTime sunset;

  /// Interpolates between [min] and [max] based on the sun's arc.
  double _sunLerp({
    required double min,
    required double max,
    required DateTime time,
  }) {
    // Convert everything to minutes since midnight for easier calculation
    final currentMinutes = time.hour * 60 + time.minute;
    final sunriseMinutes = sunrise.hour * 60 + sunrise.minute;
    final sunsetMinutes = sunset.hour * 60 + sunset.minute;

    // Outside daylight hours, return min
    if (currentMinutes < sunriseMinutes || currentMinutes > sunsetMinutes) {
      return min;
    }

    // Calculate progress through the day [0, 1].
    final dayLength = sunsetMinutes - sunriseMinutes;
    final elapsed = currentMinutes - sunriseMinutes;
    final progress = elapsed / dayLength;

    // Use sine to create the arc: sin(0) = 0, sin(π/2) = 1, sin(π) = 0
    // This gives us 0 at sunrise, 1 at noon, 0 at sunset
    final sunPosition = sin(progress * pi);

    // Adjust the sun position to be more gradual at the edges.
    final adjSunPosition = pow(sunPosition, 2.5);

    // Lerp between min and max using the sun position
    return min + (max - min) * adjSunPosition;
  }

  /// Called every tick to update the light.
  @override
  Future<bool> tick(DateTime time) async {
    // Keep the light off until sunrise.
    if (time.isBefore(sunrise)) {
      await setPower(device, power: false);
      return true;
    }

    // Keep the light on during the day.
    if (time.isAfter(sunrise) && time.isBefore(sunset)) {
      await setPower(device, power: true);
    }

    // Keep the light off after sunset.
    if (time.isAfter(sunset)) {
      await setPower(device, power: false);
      return false;
    }

    final brightness = _sunLerp(min: 1, max: 100, time: time).round();
    final color = _sunLerp(min: 2200, max: 6500, time: time).round();

    stdout
      ..writeln('+ Sunrise Protocol +')
      ..writeln('Time: $time')
      ..writeln('Brightness: $brightness')
      ..writeln('Color: $color')
      ..writeln();

    await setBrightness(device, brightness: brightness);
    await setColorK(device, temperature: color);

    // After sunset, stop the protocol.
    if (time.isAfter(sunset)) return false;

    // Run indefinitely.
    return true;
  }
}

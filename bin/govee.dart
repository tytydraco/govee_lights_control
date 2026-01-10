import 'dart:async';
import 'dart:io';

import 'package:govee_lights_control/api.dart';
import 'package:govee_lights_control/devices/h607c_floor_lamp_2.dart';
import 'package:govee_lights_control/protocol/skylight.dart';

Future<void> main(List<String> arguments) async {
  if (apiKey == null) {
    stdout.writeln('GOVEE_API_KEY is not set');
    exit(1);
  }

  final now = DateTime.now();
  final sunrise = DateTime(now.year, now.month, now.day, 6);
  final sunset = DateTime(now.year, now.month, now.day, 18);
  final skylight = Skylight(
    device: floorLamp2,
    sunrise: sunrise,
    sunset: sunset,
  );
  await skylight.run();
}

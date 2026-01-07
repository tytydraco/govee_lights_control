import 'dart:convert';

import 'package:govee_lights_control/api.dart';
import 'package:http/http.dart' as http;

/// A Govee device.
class Device {
  /// Creates a new [Device].
  Device({
    required this.sku,
    required this.device,
    required this.name,
    this.raw,
  });

  /// The SKU.
  final String sku;

  /// The device ID.
  final String device;

  /// The name of the device.
  final String name;

  /// The raw capabilities of the device.
  final Map<String, dynamic>? raw;
}

/// Returns a list of [Device]s associated with the Govee account.
Future<List<Device>> getDevices() async {
  final uri = Uri.https('openapi.api.govee.com', '/router/api/v1/user/devices');
  final info = await http.get(
    uri,
    headers: {'Govee-API-Key': apiKey!, 'Content-Type': 'application/json'},
  );

  final devicesJson = jsonDecode(info.body) as Map<String, dynamic>;

  final devices = List<Device>.empty(growable: true);
  for (final entry in devicesJson['data'] as List<Map<String, dynamic>>) {
    final device = Device(
      sku: entry['sku'] as String,
      device: entry['device'] as String,
      name: entry['deviceName'] as String,
      raw: entry,
    );

    devices.add(device);
  }

  return devices;
}

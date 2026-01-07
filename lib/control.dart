import 'dart:convert';

import 'package:govee_lights_control/constants.dart';
import 'package:govee_lights_control/device.dart';
import 'package:http/http.dart' as http;

/// Set the value for the API endpoint.
Future<Map<String, dynamic>> setValue<T>(
  Device device,
  String endpoint,
  String type,
  String instance,
  T value,
) async {
  final uri = Uri.https('openapi.api.govee.com', endpoint);
  final info = await http.post(
    uri,
    headers: {'Govee-API-Key': apiKey, 'Content-Type': 'application/json'},
    body: jsonEncode({
      'requestId': '1',
      'payload': {
        'sku': device.sku,
        'device': device.device,
        'capability': {'type': type, 'instance': instance, 'value': value},
      },
    }),
  );
  return jsonDecode(info.body) as Map<String, dynamic>;
}

/// Set the power state of the light.
Future<Map<String, dynamic>> setPower(
  Device device, {
  required bool power,
}) async {
  return setValue(
    device,
    '/router/api/v1/device/control',
    'devices.capabilities.on_off',
    'powerSwitch',
    power ? 1 : 0,
  );
}

/// Set the gradient state.
Future<Map<String, dynamic>> setGradient(
  Device device, {
  required bool on,
}) async {
  return setValue(
    device,
    '/router/api/v1/device/control',
    'devices.capabilities.toggle',
    'gradientToggle',
    on ? 1 : 0,
  );
}

/// Set the brightness of the light.
Future<Map<String, dynamic>> setBrightness(
  Device device, {
  required int brightness,
}) async {
  return setValue(
    device,
    '/router/api/v1/device/control',
    'devices.capabilities.range',
    'brightness',
    brightness.clamp(1, 100),
  );
}

/// Set the segmented brightness.
Future<Map<String, dynamic>> setSegmentedBrightness(
  Device device, {
  required List<int> segments,
  required int brightness,
}) async {
  return setValue(
    device,
    '/router/api/v1/device/control',
    'devices.capabilities.segment_color_setting',
    'segmentedBrightness',
    {'segment': segments, 'brightness': brightness},
  );
}

/// Set the segmented RGB colors.
Future<Map<String, dynamic>> setSegmentedRgb(
  Device device, {
  required List<int> segments,
  required int rgb,
}) async {
  return setValue(
    device,
    '/router/api/v1/device/control',
    'devices.capabilities.segment_color_setting',
    'segmentedColorRgb',
    {'segment': segments, 'rgb': rgb.clamp(0, 0xffffff)},
  );
}

/// Set the color in Kelvin.
Future<Map<String, dynamic>> setColorK(
  Device device, {
  required int temperature,
}) async {
  return setValue(
    device,
    '/router/api/v1/device/control',
    'devices.capabilities.color_setting',
    'colorTemperatureK',
    temperature.clamp(2200, 6500),
  );
}

/// Set the color of the light.
Future<Map<String, dynamic>> setColorRgb(
  Device device, {
  required int rgb,
}) async {
  return setValue(
    device,
    '/router/api/v1/device/control',
    'devices.capabilities.color_setting',
    'colorRgb',
    rgb.clamp(0, 0xffffff),
  );
}

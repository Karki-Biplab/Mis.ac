import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ Replace with your PC's IP address if running on device or emulator
  static const String baseUrl = 'http://localhost/mis_api/devices.php';

  /// GET: Fetch all devices
  static Future<List<Map<String, dynamic>>> getDevices() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load devices: ${response.statusCode}');
    }
  }

  /// POST: Add new device
  static Future<void> addDevice(Map<String, dynamic> newDevice) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newDevice),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add device: ${response.statusCode}');
    }
  }

  /// PUT: Update device (e.g., toggle power or status)
  static Future<void> updateDevice(Map<String, dynamic> updatedDevice) async {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedDevice),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update device: ${response.statusCode}');
    }
  }

  /// DELETE: Delete a device by ID
  static Future<void> deleteDevice(String id) async {
    final response = await http.delete(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete device: ${response.statusCode}');
    }
  }
}

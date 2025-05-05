import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your PC's IP address if running on device or emulator
  static const String baseUrlDevices = 'http://localhost/mis_api/devices.php';
  static const String baseUrlRents = 'http://localhost/mis_api/rents.php';

  // Device Management API Calls
  static Future<List<Map<String, dynamic>>> getDevices() async {
    final response = await http.get(Uri.parse(baseUrlDevices));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load devices: ${response.statusCode}');
    }
  }

  static Future<void> addDevice(Map<String, dynamic> newDevice) async {
    final response = await http.post(
      Uri.parse(baseUrlDevices),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newDevice),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add device: ${response.statusCode}');
    }
  }

  static Future<void> updateDevice(Map<String, dynamic> updatedDevice) async {
    final response = await http.put(
      Uri.parse(baseUrlDevices),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedDevice),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update device: ${response.statusCode}');
    }
  }

  static Future<void> deleteDevice(String id) async {
    final response = await http.delete(
      Uri.parse(baseUrlDevices),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete device: ${response.statusCode}');
    }
  }

  // Rent Management API Calls
  // GET: Fetch all rent records
  static Future<List<Map<String, dynamic>>> getRents() async {
    final response = await http.get(Uri.parse(baseUrlRents));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load rents: ${response.statusCode}');
    }
  }

  // GET: Fetch rent records for a specific tenant
  static Future<List<Map<String, dynamic>>> getRentsByTenantId(String tenantId) async {
    final response = await http.get(Uri.parse('$baseUrlRents?tenant_id=$tenantId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load tenant rents: ${response.statusCode}');
    }
  }

  // POST: Add a new rent record
  static Future<void> addRent(Map<String, dynamic> newRent) async {
    final response = await http.post(
      Uri.parse(baseUrlRents),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newRent),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add rent: ${response.statusCode}');
    }
  }

  // PUT: Update existing rent record
  static Future<void> updateRent(Map<String, dynamic> updatedRent) async {
    final response = await http.put(
      Uri.parse(baseUrlRents),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedRent),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update rent: ${response.statusCode}');
    }
  }

  // DELETE: Remove a rent record
  static Future<void> deleteRent(String id) async {
    final response = await http.delete(
      Uri.parse(baseUrlRents),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete rent: ${response.statusCode}');
    }
  }

  // POST: Add a payment to an existing rent record
  static Future<void> addPayment(String rentId, Map<String, dynamic> payment) async {
    final response = await http.post(
      Uri.parse('$baseUrlRents?action=add_payment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'rent_id': rentId,
        'payment': payment,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add payment: ${response.statusCode}');
    }
  }
}
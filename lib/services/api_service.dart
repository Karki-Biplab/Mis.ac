import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://your-php-site.com/api';

  static Future<String?> getRent() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/rent'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['amount'].toString();
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<List<String>> getPaymentHistory() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/payment-history'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<String>.from(data.map((e) => e.toString()));
      }
    } catch (e) {
      print(e);
    }
    return [];
  }

  static Future<List<String>> getDueNotifications() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/due'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<String>.from(data.map((e) => e.toString()));
      }
    } catch (e) {
      print(e);
    }
    return [];
  }

  static Future<String> controlDevice(String action) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/device-control'),
          body: {'action': action});
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['message'] ?? 'Success';
      }
    } catch (e) {
      print(e);
    }
    return 'Failed';
  }
}

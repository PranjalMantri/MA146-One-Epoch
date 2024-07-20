import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.224.6.194:5000';

  Future<Map<String, dynamic>?> fetchLatestLog() async {
    final response = await http.get(Uri.parse('$baseUrl/latest_log'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}

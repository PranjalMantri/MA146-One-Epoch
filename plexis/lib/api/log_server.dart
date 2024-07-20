import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plexis/pages/notifications_page.dart';

class LogService {
  static Future<List<Log>> getLogs() async {
    final response = await http.get(Uri.parse('http://your-backend-url/latest_logs'));

    if (response.statusCode == 200) {
      final List<dynamic> logJson = json.decode(response.body);
      return logJson.map((json) => Log.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load logs');
    }
  }
}

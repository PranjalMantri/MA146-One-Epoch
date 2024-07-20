import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<Log>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = fetchLogs();
  }

  Future<List<Log>> fetchLogs() async {
    final response = await http.get(Uri.parse('http://10.224.6.194:5000/last_10_logs'));

    if (response.statusCode == 200) {
      List<dynamic> logJson = json.decode(response.body);
      return logJson.map((json) => Log.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load logs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: FutureBuilder<List<Log>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading logs'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No logs available'));
          }

          final logs = snapshot.data!;
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                title: Text(log.event),
                subtitle: Text('${log.timestamp} - ${log.description}'),
              );
            },
          );
        },
      ),
    );
  }
}

class Log {
  final String event;
  final String timestamp;
  final String description;

  Log({required this.event, required this.timestamp, required this.description});

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      event: json['event_detected'],
      timestamp: json['timestamp'],
      description: json['description'],
    );
  }
}

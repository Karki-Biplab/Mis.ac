import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DueNotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Due Notifications')),
      body: FutureBuilder<List<String>>(
        future: ApiService.getDueNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Failed to load notifications'));
          }
          return ListView(
            children: snapshot.data!
                .map((due) => ListTile(title: Text(due)))
                .toList(),
          );
        },
      ),
    );
  }
}
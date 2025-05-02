import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DeviceControllerScreen extends StatelessWidget {
  void _controlDevice(String action) async {
    final result = await ApiService.controlDevice(action);
    print('Device $action: $result');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Device Controller')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _controlDevice('on'),
              child: Text('Turn ON'),
            ),
            ElevatedButton(
              onPressed: () => _controlDevice('off'),
              child: Text('Turn OFF'),
            ),
          ],
        ),
      ),
    );
  }
}

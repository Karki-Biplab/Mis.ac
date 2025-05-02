import 'package:flutter/material.dart';
// import '../services/api_service.dart';

class DeviceControllerScreen extends StatefulWidget {
  @override
  _DeviceControllerScreenState createState() => _DeviceControllerScreenState();
}

class _DeviceControllerScreenState extends State<DeviceControllerScreen> {
  // Dummy device data
  List<Map<String, dynamic>> devices = [
    {
      "name": "Living Room Light",
      "status": false,
      "power": "20W",
      "id": "device001"
    },
    {
      "name": "Smart Fan",
      "status": true,
      "power": "45W",
      "id": "device002"
    },
  ];

  // void _controlDevice(String id, String action) async {
  //   final result = await ApiService.controlDevice(id, action);
  //   print('Device $action: $result');
  // }

  void _showControllerDialog(Map<String, dynamic> device) {
    bool isOn = device["status"];

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(device["name"]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Power: ${device['power']}"),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Status: ${isOn ? 'ON' : 'OFF'}"),
                  Switch(
                    value: isOn,
                    onChanged: (value) {
                      setState(() {
                        device["status"] = value;
                      });
                      Navigator.of(context).pop();
                      _showControllerDialog(device);
                      // _controlDevice(device["id"], value ? 'on' : 'off');
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    devices.remove(device);
                  });
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.delete),
                label: Text("Unpair/Delete"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _addDevice() {
    setState(() {
      devices.add({
        "name": "New Device ${devices.length + 1}",
        "status": false,
        "power": "Unknown",
        "id": "device${devices.length + 1}"
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Devices'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 3,
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(Icons.devices),
                title: Text(device["name"]),
                subtitle: Text("Power: ${device["power"]}"),
                trailing: Icon(device["status"] ? Icons.power : Icons.power_off, color: device["status"] ? Colors.green : Colors.grey),
                onTap: () => _showControllerDialog(device),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDevice,
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
        tooltip: "Add Device",
      ),
    );
  }
}

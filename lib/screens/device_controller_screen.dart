import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DeviceControllerScreen extends StatefulWidget {
  @override
  _DeviceControllerScreenState createState() => _DeviceControllerScreenState();
}

class _DeviceControllerScreenState extends State<DeviceControllerScreen> {
  List<Map<String, dynamic>> devices = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchDevices() async {
    try {
      final fetchedDevices = await ApiService.getDevices();
      setState(() {
        devices = fetchedDevices;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching devices: $e");
    }
  }

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
                    onChanged: (value) async {
                      setState(() {
                        device["status"] = value;
                      });

                      try {
                        await ApiService.updateDevice(device);
                        Navigator.of(context).pop();
                        _showControllerDialog(device);
                      } catch (e) {
                        print("Error updating device: $e");
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showRenameDialog(device);
                    },
                    icon: Icon(Icons.edit),
                    label: Text("Rename"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showDeviceDetails(device);
                    },
                    icon: Icon(Icons.info_outline),
                    label: Text("Details"),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  _showDeleteConfirmation(device);
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

  void _showRenameDialog(Map<String, dynamic> device) {
    // Create a local controller for this specific dialog instance
    showDialog(
      context: context,
      builder: (_) {
        // Create controller within the builder scope
        final TextEditingController localRenameController = TextEditingController(
          text: device["name"]
        );
        
        return AlertDialog(
          title: Text("Rename Device"),
          content: TextField(
            controller: localRenameController,
            decoration: InputDecoration(
              labelText: "Device Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (localRenameController.text.trim().isNotEmpty) {
                  try {
                    final updatedDevice = {...device, "name": localRenameController.text.trim()};
                    await ApiService.updateDevice(updatedDevice);
                    
                    setState(() {
                      final index = devices.indexWhere((d) => d["id"] == device["id"]);
                      if (index != -1) {
                        devices[index]["name"] = localRenameController.text.trim();
                      }
                    });
                    
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Device renamed successfully"))
                    );
                  } catch (e) {
                    print("Error renaming device: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to rename device"))
                    );
                  }
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showDeviceDetails(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Device Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text("Device ID"),
                subtitle: Text(device["id"]),
                dense: true,
              ),
              ListTile(
                title: Text("Name"),
                subtitle: Text(device["name"]),
                dense: true,
              ),
              ListTile(
                title: Text("Power"),
                subtitle: Text(device["power"]),
                dense: true,
              ),
              ListTile(
                title: Text("Status"),
                subtitle: Text(device["status"] ? "ON" : "OFF"),
                dense: true,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete ${device["name"]}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await ApiService.deleteDevice(device["id"]);
                  setState(() {
                    devices.removeWhere((d) => d["id"] == device["id"]);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Device deleted successfully"))
                  );
                } catch (e) {
                  print("Error deleting device: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to delete device"))
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _addDevice() async {
    // Create controller only when needed within the builder to avoid premature disposal
    showDialog(
      context: context,
      builder: (_) {
        // Create controller within the builder scope
        final TextEditingController nameController = TextEditingController(
          text: "New Device ${devices.length + 1}"
        );
        
        return AlertDialog(
          title: Text("Add New Device"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Device Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Dismiss dialog, controller will be disposed with the dialog
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final deviceName = nameController.text.trim().isNotEmpty ? 
                    nameController.text.trim() : "New Device ${devices.length + 1}";
                
                final newDevice = {
                  "name": deviceName,
                  "status": false,
                  "power": "Unknown",
                  "id": "device${DateTime.now().millisecondsSinceEpoch}"
                };

                try {
                  await ApiService.addDevice(newDevice);
                  setState(() {
                    devices.add(newDevice);
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Device added successfully"))
                  );
                } catch (e) {
                  print("Error adding device: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to add device"))
                  );
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
    // No manual dispose needed here as the controller is scoped to the dialog builder
  }

  void _filterDevices() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Filter Devices",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        devices.sort((a, b) => a["name"].compareTo(b["name"]));
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Sort by Name"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        devices.sort((a, b) => 
                          (b["status"] ? 1 : 0).compareTo(a["status"] ? 1 : 0));
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Sort by Status"),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        devices = devices.where((d) => d["status"]).toList();
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Show Active Only"),
                  ),
                  ElevatedButton(
                    onPressed: () => fetchDevices().then((_) => Navigator.pop(context)),
                    child: Text("Reset All"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Devices'), 
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _filterDevices,
            tooltip: "Filter Devices",
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchDevices,
              child: devices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.devices_other, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "No devices found",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _addDevice,
                            child: Text("Add a Device"),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 3,
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(Icons.devices),
                              title: Text(device["name"]),
                              subtitle: Text("Power: ${device["power"]}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: device["status"],
                                    onChanged: (value) async {
                                      setState(() {
                                        device["status"] = value;
                                      });
                                      try {
                                        await ApiService.updateDevice(device);
                                      } catch (e) {
                                        print("Error updating device: $e");
                                        // Revert state if update fails
                                        setState(() {
                                          device["status"] = !value;
                                        });
                                      }
                                    },
                                  ),
                                  Icon(
                                    device["status"] ? Icons.power : Icons.power_off,
                                    color: device["status"] ? Colors.green : Colors.grey,
                                  ),
                                ],
                              ),
                              onTap: () => _showControllerDialog(device),
                              onLongPress: () => _showRenameDialog(device),
                            ),
                          );
                        },
                      ),
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
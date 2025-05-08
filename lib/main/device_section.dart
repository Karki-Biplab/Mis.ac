import 'package:flutter/material.dart';

class DeviceSection extends StatelessWidget {
  final List<Map<String, dynamic>> devices;
  final int activeDevices;
  final Function(Map<String, dynamic>, bool) onDeviceToggle;
  final Function(BuildContext) onViewAll;

  const DeviceSection({
    required this.devices,
    required this.activeDevices,
    required this.onDeviceToggle,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Devices',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => onViewAll(context),
                child: Text(
                  'View All',
                  style: TextStyle(color: Color(0xFF00897B)),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          devices.isEmpty 
              ? _buildEmptyState()
              : _buildDeviceList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            Icon(Icons.devices_other, size: 48, color: Colors.grey[400]),
            SizedBox(height: 12),
            Text('No devices connected', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: devices.length > 3 ? 3 : devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: device["status"] ? Color(0xFF00897B).withOpacity(0.1) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.devices,
                  color: device["status"] ? Color(0xFF00897B) : Colors.grey,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device["name"],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Power: ${device["power"]}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: device["status"],
                activeColor: Color(0xFF00897B),
                onChanged: (value) => onDeviceToggle(device, value),
              ),
            ],
          ),
        );
      },
    );
  }
}
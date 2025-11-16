import 'package:flutter/material.dart';
import 'add_edit_vehicle_screen.dart';
import 'vehicles/vehicle_details_screen.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final List<Map<String, dynamic>> _vehicles = [
    {
      'id': 'lorry-1',
      'name': 'Lorry 1',
      'nextMaintenance': 'Engine Oil – Due in 12 days',
      'status': 'Yellow',
      'color': Colors.orange,
    },
    {
      'id': 'lorry-2',
      'name': 'Lorry 2', 
      'nextMaintenance': 'Wheel Maintenance – Overdue',
      'status': 'Red',
      'color': Colors.red,
    },
    {
      'id': 'truck-a',
      'name': 'Truck A',
      'nextMaintenance': 'Air Filter – Due in 25 days',
      'status': 'Green',
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Vehicles'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Text(
              '${_vehicles.length} vehicle(s) found',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Vehicle List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _vehicles.length,
              itemBuilder: (context, index) {
                return _buildVehicleRow(_vehicles[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddVehicle(),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
      ),
    );
  }

  Widget _buildVehicleRow(Map<String, dynamic> vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          print('🚗 Vehicle clicked: ${vehicle['name']}');
          // Show visual feedback with SnackBar too
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Clicked ${vehicle['name']}'),
              duration: const Duration(milliseconds: 1500),
            ),
          );
          
          // Navigate to VehicleDetailsScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VehicleDetailsScreen(vehicleId: vehicle['id']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle['nextMaintenance'],
                      style: TextStyle(
                        fontSize: 14,
                        color: vehicle['color'],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: vehicle['color'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  vehicle['status'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAddVehicle() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditVehicleScreen(),
      ),
    );
  }
}

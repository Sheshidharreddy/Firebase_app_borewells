import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../services/test_vehicle_service.dart';
import 'user_vehicle_details_screen.dart';

class UserVehicleListScreen extends StatefulWidget {
  final String userId;
  final bool showTasksOnly;

  const UserVehicleListScreen({
    super.key,
    required this.userId,
    this.showTasksOnly = false,
  });

  @override
  State<UserVehicleListScreen> createState() => _UserVehicleListScreenState();
}

class _UserVehicleListScreenState extends State<UserVehicleListScreen> {
  final TestVehicleService _vehicleService = TestVehicleService();
  List<VehicleModel> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserVehicles();
  }

  Future<void> _loadUserVehicles() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get all vehicles and filter by driver ID
      final allVehicles = await _vehicleService.getAllVehicles();
      
      // Filter vehicles assigned to this user
      final userVehicles = allVehicles.where((vehicle) {
        return vehicle.driverId == widget.userId;
      }).toList();

      // If no vehicles assigned, show first 3 for demo
      List<VehicleModel> vehiclesToShow;
      if (userVehicles.isEmpty) {
        print("⚠️ No vehicles assigned to user ${widget.userId}, showing all vehicles for demo");
        vehiclesToShow = allVehicles.take(3).toList();
      } else {
        vehiclesToShow = userVehicles;
      }

      // If showing tasks only, filter vehicles with pending maintenance
      if (widget.showTasksOnly) {
        vehiclesToShow = vehiclesToShow.where((vehicle) {
          // For demo purposes, consider vehicles with 'inUse' or 'maintenance' status as having tasks
          return vehicle.status == VehicleStatus.inUse || vehicle.status == VehicleStatus.maintenance;
        }).toList();
      }

      setState(() {
        _vehicles = vehiclesToShow;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error loading user vehicles: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.showTasksOnly ? 'My Tasks' : 'My Vehicles';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.showTasksOnly 
                              ? 'Pending Maintenance Tasks'
                              : 'Your Assigned Vehicles',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_vehicles.length} ${widget.showTasksOnly ? 'task(s)' : 'vehicle(s)'} found',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Vehicle List
                  Expanded(
                    child: _vehicles.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _vehicles.length,
                            itemBuilder: (context, index) {
                              return _buildVehicleCard(_vehicles[index]);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.showTasksOnly ? Icons.task_alt : Icons.directions_car_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            widget.showTasksOnly 
                ? 'No pending tasks'
                : 'No vehicles assigned',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.showTasksOnly
                ? 'Great! All maintenance tasks are up to date.'
                : 'Contact your administrator to get vehicles assigned.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    // Determine maintenance status
    String maintenanceText;
    Color statusColor;
    IconData statusIcon;
    
    switch (vehicle.status) {
      case VehicleStatus.maintenance:
        maintenanceText = 'Under Maintenance - Action Required';
        statusColor = Colors.red;
        statusIcon = Icons.build;
        break;
      case VehicleStatus.inUse:
        maintenanceText = 'Engine Oil - Due in 12 days';
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      default:
        maintenanceText = 'Air Filter - Due in 25 days';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.1),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserVehicleDetailsScreen(
                  vehicle: vehicle,
                  userId: widget.userId,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Vehicle Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Vehicle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.licensePlate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            statusIcon,
                            size: 16,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              maintenanceText,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status Badge & Arrow
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        vehicle.statusDisplayName,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

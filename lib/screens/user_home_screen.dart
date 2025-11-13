import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/test_vehicle_service.dart';
import '../services/test_maintenance_log_service.dart';
import '../models/vehicle_model.dart';
import '../models/maintenance_log_model.dart';
import 'maintenance_log_list_screen.dart';
import 'simple_maintenance_log_screen.dart';
import 'simple_vehicle_update_screen.dart';

enum MaintenanceStatus {
  ok,
  dueSoon,
  overdue,
}

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final AuthService _authService = AuthService();
  final TestVehicleService _vehicleService = TestVehicleService();
  final TestMaintenanceLogService _logService = TestMaintenanceLogService();
  
  List<VehicleModel> _vehicles = [];
  List<MaintenanceLog> _recentLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final vehicles = await _vehicleService.getAllVehicles();
      final logsStream = _logService.getAllLogs();
      final logs = await logsStream.first;
      
      // Sort logs by date (most recent first)
      logs.sort((a, b) => b.date.compareTo(a.date));
      
      setState(() {
        _vehicles = vehicles;
        _recentLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ServiceMaster - User'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 16),
                    _buildVehicleSection(),
                    const SizedBox(height: 16),
                    _buildRecentLogsSection(),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Welcome, User!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'You can view vehicle information and update hours/km readings. Contact admin for other changes.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.directions_car, color: Colors.blue),
            const SizedBox(width: 8),
            const Text(
              'My Vehicles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${_vehicles.length} vehicles',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_vehicles.isEmpty)
          Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.directions_car_outlined, 
                       size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  const Text(
                    'No vehicles assigned',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          ...(_vehicles.take(3).map((vehicle) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getMaintenanceStatusColor(vehicle).withOpacity(0.2),
                  child: Icon(
                    _getMaintenanceStatusIcon(vehicle),
                    color: _getMaintenanceStatusColor(vehicle),
                  ),
                ),
                title: Text(
                  vehicle.licensePlate,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${vehicle.name} - ${vehicle.model ?? 'N/A'}'),
                    if (vehicle.hours != null || vehicle.km != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (vehicle.hours != null) ...[
                            Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${vehicle.hours!.toStringAsFixed(1)}h',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (vehicle.km != null) ...[
                            Icon(Icons.speed, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${vehicle.km!.toStringAsFixed(0)} km',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getMaintenanceStatusIcon(vehicle),
                            size: 14,
                            color: _getMaintenanceStatusColor(vehicle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getMaintenanceStatusText(vehicle),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getMaintenanceStatusColor(vehicle),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (action) {
                    if (action == 'update') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SimpleVehicleUpdateScreen(vehicle: vehicle),
                        ),
                      ).then((updated) {
                        if (updated == true) _loadData();
                      });
                    } else if (action == 'details') {
                      _showVehicleDetailsDialog(vehicle);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'update',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          const SizedBox(width: 8),
                          Text('Update Readings'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16),
                          const SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ))).toList(),
      ],
    );
  }

  Widget _buildRecentLogsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: Colors.orange),
            const SizedBox(width: 8),
            const Text(
              'Recent Maintenance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (_recentLogs.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MaintenanceLogListScreen(),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_recentLogs.isEmpty)
          Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.build_outlined, 
                       size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  const Text(
                    'No maintenance records yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: _recentLogs.take(3).map((log) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.green.withOpacity(0.2),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                  title: Text(
                    log.itemName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formatDate(log.date)),
                      if (log.notes.isNotEmpty)
                        Text(
                          log.notes.length > 50 
                              ? '${log.notes.substring(0, 50)}...'
                              : log.notes,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${log.hours.toStringAsFixed(1)}h',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${log.km.toStringAsFixed(0)}km',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.flash_on, color: Colors.purple),
            SizedBox(width: 8),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.assignment, color: Colors.blue),
                title: const Text('View Maintenance Logs'),
                subtitle: const Text('See all maintenance history'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MaintenanceLogListScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.build_circle, color: Colors.orange),
                title: const Text('Log Maintenance'),
                subtitle: const Text('Record completed maintenance'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleMaintenanceLogScreen(),
                    ),
                  ).then((result) {
                    if (result == true) _loadData();
                  });
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.update, color: Colors.green),
                title: const Text('Update Vehicle Readings'),
                subtitle: const Text('Update hours and km readings'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showUpdateReadingsDialog();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showUpdateReadingsDialog() {
    if (_vehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No vehicles available to update')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Vehicle to Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _vehicles.map((vehicle) {
            return ListTile(
              leading: Icon(
                _getMaintenanceStatusIcon(vehicle),
                color: _getMaintenanceStatusColor(vehicle),
              ),
              title: Text(vehicle.licensePlate),
              subtitle: Text('${vehicle.name} - ${vehicle.hours?.toStringAsFixed(1) ?? '0'}h, ${vehicle.km?.toStringAsFixed(0) ?? '0'}km'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SimpleVehicleUpdateScreen(vehicle: vehicle),
                  ),
                ).then((updated) {
                  if (updated == true) _loadData();
                });
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Maintenance status methods
  Color _getMaintenanceStatusColor(VehicleModel vehicle) {
    final status = _calculateMaintenanceStatus(vehicle);
    switch (status) {
      case MaintenanceStatus.ok:
        return Colors.green;
      case MaintenanceStatus.dueSoon:
        return Colors.orange;
      case MaintenanceStatus.overdue:
        return Colors.red;
    }
  }

  IconData _getMaintenanceStatusIcon(VehicleModel vehicle) {
    final status = _calculateMaintenanceStatus(vehicle);
    switch (status) {
      case MaintenanceStatus.ok:
        return Icons.check_circle;
      case MaintenanceStatus.dueSoon:
        return Icons.warning;
      case MaintenanceStatus.overdue:
        return Icons.error;
    }
  }

  String _getMaintenanceStatusText(VehicleModel vehicle) {
    final status = _calculateMaintenanceStatus(vehicle);
    switch (status) {
      case MaintenanceStatus.ok:
        return 'Maintenance OK';
      case MaintenanceStatus.dueSoon:
        return 'Service Due Soon';
      case MaintenanceStatus.overdue:
        return 'Service Overdue';
    }
  }

  MaintenanceStatus _calculateMaintenanceStatus(VehicleModel vehicle) {
    final hours = vehicle.hours ?? 0.0;
    final km = vehicle.km ?? 0.0;
    
    // Simple logic for demo - in real app this would check against maintenance schedules
    // Check oil change (every 250 hours or 10000 km)
    final hoursSinceOil = hours % 250;
    final kmSinceOil = km % 10000;
    
    // Overdue if past threshold
    if (hoursSinceOil > 250 || kmSinceOil > 10000) {
      return MaintenanceStatus.overdue;
    }
    
    // Due soon if within 20% of threshold
    if (hoursSinceOil > 200 || kmSinceOil > 8000) {
      return MaintenanceStatus.dueSoon;
    }
    
    return MaintenanceStatus.ok;
  }

  void _showVehicleDetailsDialog(VehicleModel vehicle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(vehicle.licensePlate),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Name', vehicle.name),
              if (vehicle.model != null) _buildDetailRow('Model', vehicle.model!),
              if (vehicle.year != null) _buildDetailRow('Year', vehicle.year!),
              if (vehicle.color != null) _buildDetailRow('Color', vehicle.color!),
              _buildDetailRow('Type', vehicle.type.name.toUpperCase()),
              _buildDetailRow('Status', vehicle.status.name.toUpperCase()),
              if (vehicle.capacity != null) 
                _buildDetailRow('Capacity', '${vehicle.capacity!.toStringAsFixed(1)} tons'),
              if (vehicle.hours != null) 
                _buildDetailRow('Hours', '${vehicle.hours!.toStringAsFixed(1)} hours'),
              if (vehicle.km != null) 
                _buildDetailRow('Kilometers', '${vehicle.km!.toStringAsFixed(0)} km'),
              if (vehicle.driverName != null) 
                _buildDetailRow('Driver', vehicle.driverName!),
              if (vehicle.notes != null && vehicle.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Notes:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(vehicle.notes!),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

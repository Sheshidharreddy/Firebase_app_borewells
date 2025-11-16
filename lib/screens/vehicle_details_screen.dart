import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../services/maintenance_due_service.dart';
import '../services/test_maintenance_log_service.dart';
import '../models/maintenance_log_model.dart';
import '../models/simple_maintenance_item.dart';
import 'add_edit_vehicle_screen.dart';
import 'simple_maintenance_log_screen.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const VehicleDetailsScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final MaintenanceDueService _maintenanceService = MaintenanceDueService();
  final TestMaintenanceLogService _logService = TestMaintenanceLogService();
  
  List<MaintenanceDueItem> _maintenanceDue = [];
  List<MaintenanceLog> _recentLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicleDetails();
  }

  Future<void> _loadVehicleDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final dueItems = await _maintenanceService.calculateMaintenanceDue(widget.vehicle);
      final allLogs = await _logService.getAllLogs().first;
      final vehicleLogs = allLogs
          .where((log) => log.vehicleId == widget.vehicle.id)
          .toList();
      vehicleLogs.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _maintenanceDue = dueItems;
        _recentLogs = vehicleLogs.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(),
                  const SizedBox(height: 24),
                  _buildNextMaintenanceDue(),
                  const SizedBox(height: 24),
                  _buildRecentLogs(),
                  const SizedBox(height: 24),
                  _buildFullSchedules(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                ],
              ),
            ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Vehicle Info',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              _buildInfoRow('Name', widget.vehicle.name),
              _buildInfoRow('Type', widget.vehicle.typeDisplayName),
              _buildInfoRow('License Plate', widget.vehicle.licensePlate),
              if (widget.vehicle.model != null)
                _buildInfoRow('Model', widget.vehicle.model!),
              _buildInfoRow('Hours', '${widget.vehicle.hours ?? 0}'),
              _buildInfoRow('Kilometers', '${widget.vehicle.km ?? 0}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildNextMaintenanceDue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Next Maintenance Due',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_maintenanceDue.isEmpty)
          const Text(
            'No maintenance scheduled',
            style: TextStyle(color: Colors.grey),
          )
        else
          Column(
            children: _maintenanceDue.map((item) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: item.statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.itemName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      item.statusText,
                      style: TextStyle(
                        color: item.statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildRecentLogs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Logs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_recentLogs.isEmpty)
          const Text(
            'No maintenance logs found',
            style: TextStyle(color: Colors.grey),
          )
        else
          Column(
            children: _recentLogs.map((log) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.itemName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(log.date),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      '${log.hours}h / ${log.km}km',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildFullSchedules() {
    final schedules = SimpleMaintenanceItem.getActiveItems();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Full Schedules',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: schedules.map((schedule) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      schedule.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    _getScheduleInterval(schedule),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getScheduleInterval(SimpleMaintenanceItem schedule) {
    final intervals = <String>[];
    if (schedule.intervalMonths != null) {
      intervals.add('Every ${schedule.intervalMonths} Months');
    }
    if (schedule.intervalHours != null) {
      intervals.add('Every ${schedule.intervalHours} Hours');
    }
    if (schedule.intervalKm != null) {
      intervals.add('Every ${schedule.intervalKm} km');
    }
    return intervals.isEmpty ? 'No schedule' : intervals.join(' / ');
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleMaintenanceLogScreen(),
                    ),
                  ).then((_) => _loadVehicleDetails());
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Log'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditVehicleScreen(vehicle: widget.vehicle),
                    ),
                  ).then((_) => _loadVehicleDetails());
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Vehicle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays <= 7) {
      return '${difference.inDays} days ago';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}

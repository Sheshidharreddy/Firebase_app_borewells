import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../services/maintenance_due_service.dart';
import 'add_edit_vehicle_screen.dart';
import 'vehicle_details_screen.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final MaintenanceDueService _maintenanceService = MaintenanceDueService();
  List<VehicleMaintenanceSummary> _vehicleSummaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final summaries = await _maintenanceService.getVehicleMaintenanceSummary();
      
      setState(() {
        _vehicleSummaries = summaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vehicles: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Vehicles'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vehicleSummaries.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadVehicles,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        color: Colors.grey[100],
                        child: Text(
                          '${_vehicleSummaries.length} vehicle(s) found',
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
                          itemCount: _vehicleSummaries.length,
                          itemBuilder: (context, index) {
                            return _buildVehicleRow(_vehicleSummaries[index]);
                          },
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildVehicleRow(VehicleMaintenanceSummary summary) {
    final vehicle = summary.vehicle;
    final nextDue = summary.nextMaintenanceDue;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _navigateToVehicleDetails(vehicle),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          vehicle.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: nextDue != null 
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${nextDue.itemName} – ${nextDue.statusText}',
                  style: TextStyle(
                    fontSize: 14,
                    color: nextDue.statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : const Text(
                'No maintenance scheduled',
                style: TextStyle(color: Colors.grey),
              ),
        trailing: nextDue != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: nextDue.statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusLabel(nextDue.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  String _getStatusLabel(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.overdue:
        return 'Red';
      case MaintenanceStatus.dueSoon:
        return 'Yellow';
      case MaintenanceStatus.ok:
        return 'Green';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No vehicles found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first vehicle to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddVehicle(),
            icon: const Icon(Icons.add),
            label: const Text('Add Vehicle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddVehicle() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditVehicleScreen(),
      ),
    ).then((_) => _loadVehicles());
  }

  void _navigateToVehicleDetails(VehicleModel vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VehicleDetailsScreen(vehicle: vehicle),
      ),
    ).then((_) => _loadVehicles());
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

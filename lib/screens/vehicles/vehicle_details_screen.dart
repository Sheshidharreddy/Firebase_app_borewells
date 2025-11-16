import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../models/vehicle_model.dart';
import '../../models/maintenance_log_model.dart';
import '../../models/simple_maintenance_item.dart';
import '../../services/test_vehicle_service.dart';
import '../../services/test_maintenance_log_service.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailsScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final TestVehicleService _testVehicleService = TestVehicleService();
  final TestMaintenanceLogService _logService = TestMaintenanceLogService();
  
  @override
  void initState() {
    super.initState();
    print("Loading vehicleId: ${widget.vehicleId}");
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: FutureBuilder<VehicleModel?>(
        future: _loadVehicleData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          final vehicle = snapshot.data;
          if (vehicle == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Vehicle not found for ID: ${widget.vehicleId}'),
                  const SizedBox(height: 8),
                  Text('Available IDs: 1, 2, 3', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Basic Info Section
                _buildBasicInfoSection(vehicle),
                const SizedBox(height: 24),
                
                // 2. Next Maintenance Due Section
                _buildNextMaintenanceSection(vehicle),
                const SizedBox(height: 24),
                
                // 3. Recent Logs Section (limit 5)
                _buildRecentLogsSection(),
                const SizedBox(height: 24),
                
                // 4. Full Maintenance Schedule Section
                _buildMaintenanceScheduleSection(),
                const SizedBox(height: 24),
                
                // 5. Quick Actions Section
                _buildQuickActionsSection(vehicle),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // Load vehicle data - simplified Firestore fetch with timeout
  Future<VehicleModel?> _loadVehicleData() async {
    print("Loading vehicle with ID: ${widget.vehicleId}");
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .get()
          .timeout(const Duration(seconds: 3)); // 3 second timeout
      
      print("VehicleDetails fetched for: ${widget.vehicleId}, exists: ${doc.exists}");
      
      if (doc.exists) {
        return VehicleModel.fromMap(doc.data()!, doc.id);
      } else {
        // Fallback to test service if document not found
        return await _loadFromTestService();
      }
    } catch (e) {
      print("❌ Firestore error or timeout: $e");
      // Fallback to test service on any error or timeout
      return await _loadFromTestService();
    }
  }
  
  Future<VehicleModel?> _loadFromTestService() async {
    try {
      print("🔄 Trying test service with ID: ${widget.vehicleId}");
      
      // First, try the exact ID
      var vehicle = await _testVehicleService.getVehicleById(widget.vehicleId);
      if (vehicle != null) {
        print("✅ Vehicle loaded from test service: ${vehicle.name}");
        return vehicle;
      }
      
      // If no exact match, try to map Firestore IDs to test service IDs
      String? mappedId;
      if (widget.vehicleId.contains('lorry')) {
        mappedId = '1'; // Map lorry to test vehicle 1
      } else if (widget.vehicleId.contains('van')) {
        mappedId = '2'; // Map van to test vehicle 2
      } else if (widget.vehicleId.contains('car')) {
        mappedId = '3'; // Map car to test vehicle 3
      }
      
      if (mappedId != null) {
        print("🔄 Trying mapped ID: $mappedId for original ID: ${widget.vehicleId}");
        vehicle = await _testVehicleService.getVehicleById(mappedId);
        if (vehicle != null) {
          print("✅ Vehicle loaded from test service with mapped ID: ${vehicle.name}");
          return vehicle;
        }
      }
      
      // If still no match, try the first available vehicle as fallback
      final allVehicles = await _testVehicleService.getAllVehicles();
      if (allVehicles.isNotEmpty) {
        print("⚠️ Using first available vehicle as fallback for ID: ${widget.vehicleId}");
        return allVehicles.first;
      }
      
      print("❌ No vehicles found in test service");
      return null;
    } catch (e) {
      print("❌ Test service error: $e");
      return null;
    }
  }

  // Helper method to get the correct vehicle ID for maintenance logs
  String _getMappedVehicleId() {
    // Use the same mapping logic as in _loadFromTestService
    if (widget.vehicleId.contains('lorry')) {
      return '1'; // Map lorry to test vehicle 1
    } else if (widget.vehicleId.contains('van')) {
      return '2'; // Map van to test vehicle 2
    } else if (widget.vehicleId.contains('car')) {
      return '3'; // Map car to test vehicle 3
    }
    
    // If no mapping found, return original ID
    return widget.vehicleId;
  }

  Widget _buildBasicInfoSection(VehicleModel vehicle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Vehicle Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Vehicle Name (Large Header)
            Text(
              vehicle.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            
            // ALL Vehicle Details
            _buildInfoRow('Vehicle ID', widget.vehicleId),
            _buildInfoRow('Name', vehicle.name),
            _buildInfoRow('Type', vehicle.typeDisplayName),
            _buildInfoRow('License Plate', vehicle.licensePlate),
            if (vehicle.model != null) _buildInfoRow('Model', vehicle.model!),
            if (vehicle.year != null) _buildInfoRow('Year', vehicle.year!),
            if (vehicle.color != null) _buildInfoRow('Color', vehicle.color!),
            if (vehicle.capacity != null) _buildInfoRow('Capacity', '${vehicle.capacity!.toStringAsFixed(1)} tons'),
            
            // Engine Info (if available)
            _buildInfoRow('Engine', vehicle.model ?? 'Standard Engine'),
            
            // Operating Hours
            if (vehicle.hours != null) 
              _buildInfoRow('Operating Hours', '${vehicle.hours!.toStringAsFixed(1)} hrs'),
            
            // Kilometers
            if (vehicle.km != null) 
              _buildInfoRow('Kilometers', '${vehicle.km!.toStringAsFixed(0)} km'),
            
            // Driver Info
            if (vehicle.driverId != null && vehicle.driverName != null)
              _buildInfoRow('Assigned Driver', vehicle.driverName!),
            
            // Notes
            if (vehicle.notes != null && vehicle.notes!.isNotEmpty)
              _buildInfoRow('Notes', vehicle.notes!),
            
            const SizedBox(height: 12),
            
            // Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(vehicle.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getStatusColor(vehicle.status)),
                  ),
                  child: Text(
                    vehicle.statusDisplayName,
                    style: TextStyle(
                      color: _getStatusColor(vehicle.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Timestamps
            Text(
              'Created: ${_formatDate(vehicle.createdAt)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              'Updated: ${_formatDate(vehicle.updatedAt)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextMaintenanceSection(VehicleModel vehicle) {
    final scheduleItems = SimpleMaintenanceItem.getActiveItems();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Next Maintenance Due',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<MaintenanceLog>>(
              stream: _logService.getLogsByVehicle(_getMappedVehicleId()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final logs = snapshot.data ?? [];
                final maintenanceDues = _calculateMaintenanceDues(scheduleItems, logs);
                
                // Sort by most urgent first
                maintenanceDues.sort((a, b) => a['daysUntilDue'].compareTo(b['daysUntilDue']));
                
                return Column(
                  children: maintenanceDues.take(5).map((due) {
                    return _buildMaintenanceDueCard(due);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceDueCard(Map<String, dynamic> due) {
    final daysUntilDue = due['daysUntilDue'] as int;
    final item = due['item'] as SimpleMaintenanceItem;
    
    Color statusColor;
    String statusText;
    
    if (daysUntilDue < 0) {
      statusColor = Colors.red;
      statusText = 'Overdue by ${-daysUntilDue} days';
    } else if (daysUntilDue <= 15) {
      statusColor = Colors.orange;
      statusText = 'Due in $daysUntilDue days';
    } else {
      statusColor = Colors.green;
      statusText = 'Due in $daysUntilDue days';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: statusColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: statusColor.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            daysUntilDue < 0 ? Icons.warning : Icons.schedule,
            color: statusColor,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLogsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Recent Logs (Last 5)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<MaintenanceLog>>(
              stream: _logService.getLogsByVehicle(_getMappedVehicleId()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final allLogs = snapshot.data ?? [];
                final recentLogs = allLogs.take(5).toList(); // Limit to 5
                
                if (recentLogs.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.history_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'No maintenance logs found for this vehicle',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  children: [
                    Text(
                      'Showing ${recentLogs.length} of ${allLogs.length} total logs',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ...recentLogs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final log = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.withOpacity(0.2),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            log.itemName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${_formatDate(log.date)}'),
                              Text('Hours: ${log.hours} | KM: ${log.km.toStringAsFixed(0)}'),
                              if (log.notes.isNotEmpty)
                                Text('Notes: ${log.notes}', 
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                          trailing: Text(
                            log.performedBy ?? 'Unknown',
                            style: const TextStyle(fontSize: 10),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceScheduleSection() {
    final scheduleItems = SimpleMaintenanceItem.getActiveItems();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list_alt, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Maintenance Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: scheduleItems.map((item) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.withOpacity(0.2),
                    child: const Icon(Icons.build, color: Colors.purple),
                  ),
                  title: Text(item.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.description),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (item.intervalMonths != null)
                            _buildIntervalChip('${item.intervalMonths} months', Icons.calendar_month),
                          if (item.intervalHours != null)
                            _buildIntervalChip('${item.intervalHours} hours', Icons.schedule),
                          if (item.intervalKm != null)
                            _buildIntervalChip('${item.intervalKm} km', Icons.speed),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(VehicleModel vehicle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickActionButton(
                  'Update Hours/KM',
                  Icons.update,
                  Colors.blue,
                  () => _showUpdateDialog(vehicle),
                ),
                _buildQuickActionButton(
                  'Add Log',
                  Icons.add_circle,
                  Colors.green,
                  () => _showAddLogDialog(),
                ),
                _buildQuickActionButton(
                  'Edit Vehicle',
                  Icons.edit,
                  Colors.orange,
                  () => _showEditDialog(),
                ),
                _buildQuickActionButton(
                  'View All Logs',
                  Icons.history,
                  Colors.purple,
                  () => _showAllLogs(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  List<Map<String, dynamic>> _calculateMaintenanceDues(
    List<SimpleMaintenanceItem> scheduleItems,
    List<MaintenanceLog> logs,
  ) {
    final List<Map<String, dynamic>> dues = [];
    
    for (final item in scheduleItems) {
      // Find the most recent log for this maintenance item
      final itemLogs = logs.where((log) => log.itemName == item.name).toList();
      itemLogs.sort((a, b) => b.date.compareTo(a.date));
      
      DateTime lastPerformed;
      if (itemLogs.isNotEmpty) {
        lastPerformed = itemLogs.first.date;
      } else {
        // If no logs, assume last performed 6 months ago (to show items as due)
        lastPerformed = DateTime.now().subtract(const Duration(days: 180));
      }
      
      // Calculate due date based on interval months (simplified calculation)
      final intervalMonths = item.intervalMonths ?? 6; // Default to 6 months
      final dueDate = DateTime(
        lastPerformed.year,
        lastPerformed.month + intervalMonths,
        lastPerformed.day,
      );
      
      final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
      
      dues.add({
        'item': item,
        'lastPerformed': lastPerformed,
        'dueDate': dueDate,
        'daysUntilDue': daysUntilDue,
      });
    }
    
    return dues;
  }

  Color _getStatusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return Colors.green;
      case VehicleStatus.inUse:
        return Colors.blue;
      case VehicleStatus.maintenance:
        return Colors.orange;
      case VehicleStatus.outOfService:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showUpdateDialog(VehicleModel vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Vehicle Readings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Hours: ${vehicle.hours?.toStringAsFixed(1) ?? 'N/A'}'),
            Text('Current KM: ${vehicle.km?.toStringAsFixed(0) ?? 'N/A'}'),
            const SizedBox(height: 16),
            const Text('Update functionality would be implemented here.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddLogDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Log functionality would be implemented here')),
    );
  }

  void _showEditDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Vehicle functionality would be implemented here')),
    );
  }

  void _showAllLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('View All Logs functionality would be implemented here')),
    );
  }
}

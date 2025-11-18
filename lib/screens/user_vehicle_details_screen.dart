import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../models/maintenance_log_model.dart';
import '../models/simple_maintenance_item.dart';
import '../services/test_maintenance_log_service.dart';
import 'user_maintenance_completion_screen.dart';
import 'maintenance_detail_screen.dart';
import 'add_custom_maintenance_screen.dart';
import 'simple_all_logs_screen.dart' show AllMaintenanceLogsScreen;

class UserVehicleDetailsScreen extends StatefulWidget {
  final VehicleModel vehicle;
  final String userId;

  const UserVehicleDetailsScreen({
    super.key,
    required this.vehicle,
    required this.userId,
  });

  @override
  State<UserVehicleDetailsScreen> createState() => _UserVehicleDetailsScreenState();
}

class _UserVehicleDetailsScreenState extends State<UserVehicleDetailsScreen> {
  final TestMaintenanceLogService _logService = TestMaintenanceLogService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVehicleInfoCard(),
              const SizedBox(height: 16),
              _buildMaintenanceTasksCard(),
              const SizedBox(height: 16),
              _buildRecentMaintenanceCard(),
              const SizedBox(height: 16),
              _buildQuickActionsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
                    size: 35,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vehicle.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Prominent license plate display
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.vehicle.licensePlate,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            
            // Vehicle Type and Model prominently displayed
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Icon(Icons.category, color: Colors.blue, size: 24),
                            const SizedBox(height: 8),
                            Text(
                              'Vehicle Type',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.vehicle.typeDisplayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 60,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Icon(Icons.info, color: Colors.blue, size: 24),
                            const SizedBox(height: 8),
                            Text(
                              'Model',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.vehicle.model ?? 'Not specified',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    'Hours', 
                    '${widget.vehicle.hours?.toStringAsFixed(1) ?? '0'} hrs',
                    Icons.schedule,
                  ),
                ),
                Expanded(
                  child: _buildInfoTile(
                    'Kilometers', 
                    '${widget.vehicle.km?.toStringAsFixed(0) ?? '0'} km',
                    Icons.speed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    switch (widget.vehicle.status) {
      case VehicleStatus.available:
        statusColor = Colors.green;
        break;
      case VehicleStatus.inUse:
        statusColor = Colors.orange;
        break;
      case VehicleStatus.maintenance:
        statusColor = Colors.red;
        break;
      case VehicleStatus.outOfService:
        statusColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        widget.vehicle.statusDisplayName,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMaintenanceTasksCard() {
    // Get maintenance items that are due
    final scheduleItems = SimpleMaintenanceItem.getActiveItems();
    final dueTasks = _getDueTasks(scheduleItems);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.build, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Maintenance Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: dueTasks.isEmpty ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${dueTasks.length} Due',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (dueTasks.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 48, color: Colors.green[400]),
                    const SizedBox(height: 8),
                    Text(
                      'All maintenance up to date!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Great job keeping your vehicle maintained.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: dueTasks.map((task) => _buildTaskItem(task)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    final item = task['item'] as SimpleMaintenanceItem;
    final daysOverdue = task['daysOverdue'] as int;
    final isOverdue = daysOverdue > 0;
    final isDueSoon = daysOverdue <= 0 && daysOverdue >= -15; // Due within 15 days
    
    // Calculate due date
    final dueDate = DateTime.now().add(Duration(days: -daysOverdue));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isOverdue ? Colors.red[50] : (isDueSoon ? Colors.orange[50] : Colors.blue[50]),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            // Navigate to maintenance completion form for due tasks
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserMaintenanceCompletionScreen(
                  vehicle: widget.vehicle,
                  maintenanceItem: item,
                  userId: widget.userId,
                ),
              ),
            ).then((_) => setState(() {})); // Refresh when returning
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isOverdue ? Colors.red : (isDueSoon ? Colors.orange : Colors.blue),
                    borderRadius: BorderRadius.circular(2),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            isOverdue ? Icons.warning : Icons.schedule,
                            size: 14,
                            color: isOverdue ? Colors.red : (isDueSoon ? Colors.orange : Colors.blue),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOverdue 
                                ? 'Overdue by ${daysOverdue} days'
                                : 'Due in ${-daysOverdue} days',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? Colors.red : (isDueSoon ? Colors.orange : Colors.blue),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (isOverdue ? Colors.red : (isDueSoon ? Colors.orange : Colors.blue)).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isOverdue ? Colors.red : (isDueSoon ? Colors.orange : Colors.blue),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          _formatDate(dueDate),
                          style: TextStyle(
                            fontSize: 10,
                            color: isOverdue ? Colors.red : (isDueSoon ? Colors.orange : Colors.blue),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isOverdue ? Colors.red : (isDueSoon ? Colors.orange : Colors.blue),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.build,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete\nMaintenance',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildRecentMaintenanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Recent Maintenance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllMaintenanceLogsScreen(vehicle: widget.vehicle),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            StreamBuilder<List<MaintenanceLog>>(
              stream: _logService.getLogsByVehicle(widget.vehicle.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final logs = snapshot.data ?? [];
                final recentLogs = logs.take(5).toList();
                
                if (recentLogs.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No maintenance history found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Maintenance records will appear here',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  children: recentLogs.map((log) => _buildMaintenanceLogItem(log)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceLogItem(MaintenanceLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            // Navigate to maintenance detail screen for this specific maintenance type
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MaintenanceDetailScreen(
                  maintenanceType: log.itemName,
                  vehicleId: widget.vehicle.id,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.itemName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(log.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.person, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              log.performedBy ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.speed, size: 10, color: Colors.blue),
                                const SizedBox(width: 2),
                                Text(
                                  '${log.km.toStringAsFixed(0)} km',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.schedule, size: 10, color: Colors.orange),
                                const SizedBox(width: 2),
                                Text(
                                  '${log.hours.toStringAsFixed(1)}h',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Column(
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[500],
                      ),
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

  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.purple),
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
            
            // First row of buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Update Reading',
                    Icons.speed,
                    Colors.blue,
                    () => _showUpdateReadingDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Report Issue',
                    Icons.warning,
                    Colors.orange,
                    () => _showReportIssueDialog(),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Second row - Add custom maintenance note button
            SizedBox(
              width: double.infinity,
              child: _buildActionButton(
                'Add Custom Maintenance Note',
                Icons.note_add,
                Colors.green,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCustomMaintenanceScreen(
                        vehicle: widget.vehicle,
                        userId: widget.userId,
                      ),
                    ),
                  ).then((result) {
                    if (result == true) {
                      setState(() {}); // Refresh the screen to show new data
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  List<Map<String, dynamic>> _getDueTasks(List<SimpleMaintenanceItem> scheduleItems) {
    final List<Map<String, dynamic>> dueTasks = [];
    
    for (final item in scheduleItems) {
      // Simulate realistic maintenance due dates based on item type
      int daysOverdue = 0;
      bool isDue = false;
      
      if (item.name.toLowerCase().contains('engine oil') || item.name.toLowerCase().contains('oil change')) {
        daysOverdue = -12; // Due in 12 days
        isDue = true;
      } else if (item.name.toLowerCase().contains('air filter') || item.name.toLowerCase().contains('filter')) {
        daysOverdue = -25; // Due in 25 days  
        isDue = true;
      } else if (item.name.toLowerCase().contains('brake')) {
        daysOverdue = -8; // Due in 8 days
        isDue = true;
      } else if (item.name.toLowerCase().contains('tire') || item.name.toLowerCase().contains('wheel')) {
        if (widget.vehicle.status == VehicleStatus.maintenance) {
          daysOverdue = 3; // 3 days overdue
          isDue = true;
        }
      } else if (item.name.toLowerCase().contains('compressor')) {
        daysOverdue = -13; // Due in 13 days (within your specified range)
        isDue = true;
      } else if (item.name.toLowerCase().contains('hydraulic')) {
        daysOverdue = -15; // Due in 15 days
        isDue = true;
      }
      
      if (isDue) {
        dueTasks.add({
          'item': item,
          'daysOverdue': daysOverdue,
        });
      }
    }
    
    return dueTasks;
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
      return '${months[date.month - 1]} ${date.day}';
    }
  }

  void _showUpdateReadingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Vehicle Reading'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current: ${widget.vehicle.hours?.toStringAsFixed(1) ?? '0'} hrs'),
            Text('Current: ${widget.vehicle.km?.toStringAsFixed(0) ?? '0'} km'),
            const SizedBox(height: 16),
            const Text('This feature will allow you to update the vehicle readings.'),
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

  void _showReportIssueDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Vehicle Issue'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Describe the issue you\'ve encountered with this vehicle.'),
            SizedBox(height: 16),
            Text('This feature will allow you to report problems or concerns.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}

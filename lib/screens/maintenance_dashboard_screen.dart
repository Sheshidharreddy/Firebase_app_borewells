import 'package:flutter/material.dart';
import '../models/maintenance_item_model.dart';
import '../models/maintenance_log_model.dart';
import '../services/test_maintenance_item_service.dart';
import '../services/test_maintenance_log_service.dart';
import '../screens/add_edit_maintenance_log_screen.dart';
import '../screens/maintenance_log_list_screen.dart';

class MaintenanceDashboardScreen extends StatefulWidget {
  const MaintenanceDashboardScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceDashboardScreen> createState() => _MaintenanceDashboardScreenState();
}

class _MaintenanceDashboardScreenState extends State<MaintenanceDashboardScreen> {
  final TestMaintenanceItemService _itemService = TestMaintenanceItemService();
  final TestMaintenanceLogService _logService = TestMaintenanceLogService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MaintenanceLogListScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history),
            tooltip: 'View All Logs',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {}); // Trigger rebuild
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats Cards
              _buildStatsRow(),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(),
              const SizedBox(height: 24),

              // Overdue Maintenance
              _buildOverdueSection(),
              const SizedBox(height: 24),

              // Due Soon
              _buildDueSoonSection(),
              const SizedBox(height: 24),

              // Upcoming Maintenance
              _buildUpcomingSection(),
              const SizedBox(height: 24),

              // Recent Activity
              _buildRecentActivitySection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditMaintenanceLogScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Log Maintenance',
      ),
    );
  }

  Widget _buildStatsRow() {
    return StreamBuilder<List<MaintenanceItem>>(
      stream: _itemService.getAllMaintenanceItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            children: [
              Expanded(child: _StatsCardSkeleton()),
              SizedBox(width: 12),
              Expanded(child: _StatsCardSkeleton()),
              SizedBox(width: 12),
              Expanded(child: _StatsCardSkeleton()),
            ],
          );
        }

        final items = snapshot.data ?? [];
        final overdue = items.where((item) => item.isOverdue).length;
        final dueSoon = items.where((item) => item.isDueSoon).length;
        final upcoming = items.where((item) => !item.isOverdue && !item.isDueSoon).length;

        return Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                title: 'Overdue',
                count: overdue,
                color: Colors.red,
                icon: Icons.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatsCard(
                title: 'Due Soon',
                count: dueSoon,
                color: Colors.orange,
                icon: Icons.schedule,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatsCard(
                title: 'Upcoming',
                count: upcoming,
                color: Colors.blue,
                icon: Icons.event,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    title: 'Log Maintenance',
                    subtitle: 'Record completed work',
                    icon: Icons.build,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEditMaintenanceLogScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    title: 'Update Vehicle',
                    subtitle: 'Hours, mileage',
                    icon: Icons.update,
                    color: Colors.blue,
                    onTap: () {
                      _showUpdateVehicleDialog();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.05),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverdueSection() {
    return _buildMaintenanceSection(
      title: 'Overdue Maintenance',
      icon: Icons.warning,
      color: Colors.red,
      filter: (item) => item.isOverdue,
      emptyMessage: 'No overdue maintenance items',
    );
  }

  Widget _buildDueSoonSection() {
    return _buildMaintenanceSection(
      title: 'Due Soon (Next 7 days)',
      icon: Icons.schedule,
      color: Colors.orange,
      filter: (item) => item.isDueSoon,
      emptyMessage: 'No maintenance due soon',
    );
  }

  Widget _buildUpcomingSection() {
    return _buildMaintenanceSection(
      title: 'Upcoming Maintenance',
      icon: Icons.event,
      color: Colors.blue,
      filter: (item) => !item.isOverdue && !item.isDueSoon,
      emptyMessage: 'No upcoming maintenance scheduled',
      limit: 5,
    );
  }

  Widget _buildMaintenanceSection({
    required String title,
    required IconData icon,
    required Color color,
    required bool Function(MaintenanceItem) filter,
    required String emptyMessage,
    int? limit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<MaintenanceItem>>(
          stream: _itemService.getAllMaintenanceItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (snapshot.hasError) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            }

            var items = (snapshot.data ?? []).where(filter).toList();
            
            // Sort by due date (earliest first)
            items.sort((a, b) => a.nextDue.compareTo(b.nextDue));
            
            if (limit != null && items.length > limit) {
              items = items.take(limit).toList();
            }

            if (items.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    emptyMessage,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            }

            return Column(
              children: items
                  .map((item) => _buildMaintenanceItemCard(item))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMaintenanceItemCard(MaintenanceItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.statusColor.withOpacity(0.2),
          child: Icon(
            _getMaintenanceIcon(item.itemName),
            color: item.statusColor,
            size: 20,
          ),
        ),
        title: Text(
          item.itemName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle: ${item.vehicleId}'),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDueDate(item),
                  style: TextStyle(
                    color: item.isOverdue ? Colors.red : Colors.grey[600],
                    fontWeight: item.isOverdue ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: item.priorityColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: item.priorityColor.withOpacity(0.5)),
          ),
          child: Text(
            item.priority.toString().split('.').last.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: item.priorityColor,
            ),
          ),
        ),
        onTap: () {
          _showMaintenanceItemDialog(item);
        },
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: Colors.purple, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const Spacer(),
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
        StreamBuilder<List<MaintenanceLog>>(
          stream: _logService.getRecentActivity(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final logs = (snapshot.data ?? []).take(3).toList();

            if (logs.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No recent maintenance activity',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            }

            return Card(
              child: Column(
                children: logs
                    .map((log) => _buildRecentActivityItem(log))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivityItem(MaintenanceLog log) {
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.green.withOpacity(0.2),
        child: Icon(
          Icons.check,
          color: Colors.green,
          size: 16,
        ),
      ),
      title: Text(
        log.itemName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(_formatRecentDate(log.date)),
      trailing: Text(
        '${log.hours}h',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getMaintenanceIcon(String itemName) {
    final name = itemName.toLowerCase();
    if (name.contains('oil')) return Icons.opacity;
    if (name.contains('brake')) return Icons.speed;
    if (name.contains('tire')) return Icons.circle_outlined;
    if (name.contains('filter')) return Icons.air;
    if (name.contains('battery')) return Icons.battery_std;
    if (name.contains('engine')) return Icons.settings;
    return Icons.build;
  }

  String _formatDueDate(MaintenanceItem item) {
    final now = DateTime.now();
    final difference = item.nextDue.difference(now);
    
    if (item.isOverdue) {
      final overdueDays = -difference.inDays;
      return 'Overdue by $overdueDays days';
    } else if (difference.inDays == 0) {
      return 'Due today';
    } else if (difference.inDays == 1) {
      return 'Due tomorrow';
    } else if (difference.inDays <= 7) {
      return 'Due in ${difference.inDays} days';
    } else {
      return 'Due ${_formatDate(item.nextDue)}';
    }
  }

  String _formatRecentDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays <= 7) {
      return '${difference.inDays} days ago';
    } else {
      return _formatDate(date);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}';
  }

  void _showMaintenanceItemDialog(MaintenanceItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.itemName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle: ${item.vehicleId}'),
            const SizedBox(height: 8),
            Text('Description: ${item.description}'),
            const SizedBox(height: 8),
            Text('Due: ${_formatDueDate(item)}'),
            const SizedBox(height: 8),
            Text('Priority: ${item.priority.toString().split('.').last}'),
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${item.notes}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditMaintenanceLogScreen(),
                ),
              );
            },
            child: const Text('Log Maintenance'),
          ),
        ],
      ),
    );
  }

  void _showUpdateVehicleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Vehicle Metrics'),
        content: const Text(
          'This feature will allow updating vehicle hours and mileage.\n\n'
          'Coming soon in the next update!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _StatsCardSkeleton extends StatelessWidget {
  const _StatsCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 48,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

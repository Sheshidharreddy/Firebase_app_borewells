import 'package:flutter/material.dart';
import '../models/simple_maintenance_item.dart';

class AdminMaintenanceScheduleScreen extends StatefulWidget {
  const AdminMaintenanceScheduleScreen({super.key});

  @override
  State<AdminMaintenanceScheduleScreen> createState() => _AdminMaintenanceScheduleScreenState();
}

class _AdminMaintenanceScheduleScreenState extends State<AdminMaintenanceScheduleScreen> {
  List<SimpleMaintenanceItem> _scheduleItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadScheduleItems();
  }

  void _loadScheduleItems() {
    setState(() {
      _isLoading = true;
      // Load predefined items for now
      _scheduleItems = SimpleMaintenanceItem.getActiveItems();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Schedule'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadScheduleItems,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.withOpacity(0.1), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.schedule, size: 48, color: Colors.blue),
                      const SizedBox(height: 8),
                      Text(
                        'Maintenance Schedule Management',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Configure maintenance intervals and requirements',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Schedule Items List
                Expanded(
                  child: _scheduleItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No maintenance schedules found',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _scheduleItems.length,
                          itemBuilder: (context, index) {
                            final item = _scheduleItems[index];
                            return _buildScheduleItemCard(item);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // For now, show info about predefined schedules
          _showAddScheduleInfo();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Schedule'),
      ),
    );
  }

  Widget _buildScheduleItemCard(SimpleMaintenanceItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getItemColor(item).withOpacity(0.2),
          child: Icon(
            _getItemIcon(item),
            color: _getItemColor(item),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.description),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (item.intervalMonths != null)
                  _buildIntervalChip(
                    '${item.intervalMonths} months',
                    Icons.calendar_month,
                    Colors.blue,
                  ),
                if (item.intervalHours != null)
                  _buildIntervalChip(
                    '${item.intervalHours} hours',
                    Icons.schedule,
                    Colors.orange,
                  ),
                if (item.intervalKm != null)
                  _buildIntervalChip(
                    '${item.intervalKm} km',
                    Icons.speed,
                    Colors.green,
                  ),
              ],
            ),
            if (item.product != null || item.adminComments != null) ...[
              const SizedBox(height: 8),
              if (item.product != null) 
                Text('Product: ${item.product}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              if (item.adminComments != null)
                Text('Notes: ${item.adminComments}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'edit') {
              _editScheduleItem(item);
            } else if (action == 'duplicate') {
              _duplicateScheduleItem(item);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit, size: 18),
                title: Text('Edit Schedule'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: ListTile(
                leading: Icon(Icons.copy, size: 18),
                title: Text('Duplicate'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getItemColor(SimpleMaintenanceItem item) {
    switch (item.id) {
      case 'engine_oil':
        return Colors.blue;
      case 'air_filter':
        return Colors.green;
      case 'fuel_filters':
        return Colors.orange;
      case 'fuel_injectors':
        return Colors.red;
      case 'wheel_maintenance':
        return Colors.purple;
      case 'compressor_oil':
        return Colors.indigo;
      case 'compressor_air_filter':
        return Colors.teal;
      case 'hydraulic_fluid':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getItemIcon(SimpleMaintenanceItem item) {
    switch (item.id) {
      case 'engine_oil':
        return Icons.oil_barrel;
      case 'air_filter':
        return Icons.air;
      case 'fuel_filters':
        return Icons.filter_alt;
      case 'fuel_injectors':
        return Icons.precision_manufacturing;
      case 'wheel_maintenance':
        return Icons.tire_repair;
      case 'compressor_oil':
        return Icons.compress;
      case 'compressor_air_filter':
        return Icons.filter_list;
      case 'hydraulic_fluid':
        return Icons.water_drop;
      default:
        return Icons.build;
    }
  }

  void _editScheduleItem(SimpleMaintenanceItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Maintenance Item: ${item.name}'),
            const SizedBox(height: 8),
            Text('Description: ${item.description}'),
            const SizedBox(height: 16),
            const Text(
              'In the full version, you would be able to edit intervals, products, and comments here.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.name} schedule updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _duplicateScheduleItem(SimpleMaintenanceItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Duplicate ${item.name}'),
        content: const Text(
          'This would create a copy of the maintenance schedule with modified intervals.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.name} schedule duplicated')),
              );
            },
            child: const Text('Duplicate'),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Maintenance Schedule'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Implementation:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Pre-defined maintenance items are available'),
            Text('• Users can select from the predefined list'),
            Text('• Intervals are set for each maintenance type'),
            SizedBox(height: 16),
            Text(
              'Full Version Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Add custom maintenance items'),
            Text('• Set custom intervals (months/hours/km)'),
            Text('• Assign specific products and parts'),
            Text('• Add detailed maintenance procedures'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/maintenance_log_model.dart';
import '../services/test_maintenance_log_service.dart';

class MaintenanceDetailScreen extends StatefulWidget {
  final String maintenanceType;
  final String vehicleId;

  const MaintenanceDetailScreen({
    super.key,
    required this.maintenanceType,
    required this.vehicleId,
  });

  @override
  State<MaintenanceDetailScreen> createState() => _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends State<MaintenanceDetailScreen> {
  final TestMaintenanceLogService _logService = TestMaintenanceLogService();
  List<MaintenanceLog> _maintenanceLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceLogs();
  }

  Future<void> _loadMaintenanceLogs() async {
    try {
      final allLogs = await _logService.getAllLogs().first;
      final filteredLogs = allLogs
          .where((log) => 
              log.vehicleId == widget.vehicleId && 
              log.itemName.toLowerCase().contains(widget.maintenanceType.toLowerCase()))
          .toList();
      
      filteredLogs.sort((a, b) => b.date.compareTo(a.date));
      
      setState(() {
        _maintenanceLogs = filteredLogs;
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
        title: Text('$widget.maintenanceType History'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with current status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.blue.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.build_circle, color: Colors.blue.shade700, size: 30),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.maintenanceType,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                Text(
                                  'Maintenance History & Details',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                        if (_maintenanceLogs.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildStatItem('Last Changed', _formatDate(_maintenanceLogs.first.date)),
                              const SizedBox(width: 20),
                              _buildStatItem('At KM', '${_maintenanceLogs.first.km.toStringAsFixed(0)} km'),
                            ],
                          ),
                        ]
                    ],
                  ),
                ),
                
                // Maintenance logs list
                Expanded(
                  child: _maintenanceLogs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No ${widget.maintenanceType} history found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Maintenance records will appear here once logged',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _maintenanceLogs.length,
                          itemBuilder: (context, index) {
                            final log = _maintenanceLogs[index];
                            return _buildMaintenanceLogCard(log, index);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceLogCard(MaintenanceLog log, int index) {
    final isLatest = index == 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: isLatest ? 4 : 2,
        color: isLatest ? Colors.green.shade50 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isLatest ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isLatest ? Icons.star : Icons.build,
                      color: Colors.white,
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLatest ? Colors.green.shade700 : Colors.black,
                          ),
                        ),
                        Text(
                          isLatest ? 'Latest Service' : 'Service Record',
                          style: TextStyle(
                            fontSize: 12,
                            color: isLatest ? Colors.green.shade600 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLatest)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Latest',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Service details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildDetailItem(Icons.calendar_today, 'Date', _formatDate(log.date)),
                        const SizedBox(width: 20),
                        _buildDetailItem(Icons.speed, 'Kilometers', '${log.km.toStringAsFixed(0)} km'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildDetailItem(Icons.schedule, 'Engine Hours', '${log.hours.toStringAsFixed(1)} hrs'),
                        const SizedBox(width: 20),
                        _buildDetailItem(Icons.person, 'Performed By', log.performedBy ?? 'Unknown'),
                      ],
                    ),
                  ],
                ),
              ),
              
              if (log.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.note, color: Colors.blue.shade700, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Service Notes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        log.notes,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
}
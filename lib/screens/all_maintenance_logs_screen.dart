import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../models/maintenance_log_model.dart';
import '../services/test_maintenance_log_service.dart';
import 'maintenance_detail_screen.dart';

class AllMaintenanceLogsScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const AllMaintenanceLogsScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<AllMaintenanceLogsScreen> createState() => _AllMaintenanceLogsScreenState();
}

class _AllMaintenanceLogsScreenState extends State<AllMaintenanceLogsScreen> {
  final TestMaintenanceLogService _logService = TestMaintenanceLogService();
  List<MaintenanceLog> _allLogs = [];
  Map<String, List<MaintenanceLog>> _groupedLogs = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllLogs();
  }

  Future<void> _loadAllLogs() async {
    try {
      final allLogs = await _logService.getAllLogs().first;
      final vehicleLogs = allLogs
          .where((log) => log.vehicleId == widget.vehicle.id)
          .toList();
      
      vehicleLogs.sort((a, b) => b.date.compareTo(a.date));
      
      // Group logs by maintenance type
      final Map<String, List<MaintenanceLog>> grouped = {};
      for (final log in vehicleLogs) {
        final key = log.itemName;
        if (grouped[key] == null) {
          grouped[key] = [];
        }
        grouped[key]!.add(log);
      }
      
      setState(() {
        _allLogs = vehicleLogs;
        _groupedLogs = grouped;
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
        title: Text('${widget.vehicle.name} - All Logs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary header
                _buildSummaryHeader(),
                
                // Logs content
                Expanded(
                  child: _allLogs.isEmpty
                      ? _buildEmptyState()
                      : DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              Container(
                                color: Colors.white,
                                child: const TabBar(
                                  labelColor: Colors.blue,
                                  unselectedLabelColor: Colors.grey,
                                  indicatorColor: Colors.blue,
                                  tabs: [
                                    Tab(
                                      icon: Icon(Icons.list),
                                      text: 'All Logs',
                                    ),
                                    Tab(
                                      icon: Icon(Icons.category),
                                      text: 'By Type',
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _buildAllLogsTab(),
                                    _buildByTypeTab(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.history,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maintenance History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      '${_allLogs.length} total records • ${_groupedLogs.keys.length} maintenance types',
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
          
          if (_allLogs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  'Last Service',
                  _formatDate(_allLogs.first.date),
                ),
                const SizedBox(width: 20),
                _buildStatItem(
                  'Current KM',
                  '${widget.vehicle.km?.toStringAsFixed(0) ?? '0'} km',
                ),
                const SizedBox(width: 20),
                _buildStatItem(
                  'Current Hours',
                  '${widget.vehicle.hours?.toStringAsFixed(1) ?? '0'} hrs',
                ),
              ],
            ),
          ],
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No maintenance history',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildAllLogsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allLogs.length,
      itemBuilder: (context, index) {
        final log = _allLogs[index];
        return _buildLogCard(log, index == 0);
      },
    );
  }

  Widget _buildByTypeTab() {
    final sortedTypes = _groupedLogs.keys.toList()..sort();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedTypes.length,
      itemBuilder: (context, index) {
        final type = sortedTypes[index];
        final logs = _groupedLogs[type]!;
        return _buildMaintenanceTypeCard(type, logs);
      },
    );
  }

  Widget _buildLogCard(MaintenanceLog log, bool isLatest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                          _formatDate(log.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  _buildDetailChip(Icons.speed, '${log.km.toStringAsFixed(0)} km'),
                  const SizedBox(width: 12),
                  _buildDetailChip(Icons.schedule, '${log.hours.toStringAsFixed(1)} hrs'),
                  const SizedBox(width: 12),
                  _buildDetailChip(Icons.person, log.performedBy ?? 'Unknown'),
                ],
              ),
              
              if (log.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    log.notes,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceTypeCard(String type, List<MaintenanceLog> logs) {
    final latestLog = logs.first;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MaintenanceDetailScreen(
                  maintenanceType: type,
                  vehicleId: widget.vehicle.id,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
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
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.build_circle,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${logs.length} service${logs.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Service',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(latestLog.date)} at ${latestLog.km.toStringAsFixed(0)} km',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
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
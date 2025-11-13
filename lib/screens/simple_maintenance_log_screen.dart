import 'package:flutter/material.dart';
import '../models/maintenance_log_model.dart';
import '../models/simple_maintenance_item.dart';
import '../models/vehicle_model.dart';
import '../services/test_maintenance_log_service.dart';
import '../services/test_vehicle_service.dart';

class SimpleMaintenanceLogScreen extends StatefulWidget {
  final String? vehicleId;

  const SimpleMaintenanceLogScreen({
    super.key,
    this.vehicleId,
  });

  @override
  State<SimpleMaintenanceLogScreen> createState() => _SimpleMaintenanceLogScreenState();
}

class _SimpleMaintenanceLogScreenState extends State<SimpleMaintenanceLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final TestMaintenanceLogService _logService = TestMaintenanceLogService();
  final TestVehicleService _vehicleService = TestVehicleService();

  VehicleModel? _selectedVehicle;
  SimpleMaintenanceItem? _selectedMaintenanceItem;
  final TextEditingController _notesController = TextEditingController();
  
  List<VehicleModel> _vehicles = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final vehicles = await _vehicleService.getAllVehicles();
      
      setState(() {
        _vehicles = vehicles;
        
        // Pre-select vehicle if provided
        if (widget.vehicleId != null) {
          _selectedVehicle = vehicles.firstWhere(
            (v) => v.id == widget.vehicleId,
            orElse: () => vehicles.isNotEmpty ? vehicles.first : vehicles.first,
          );
        } else if (vehicles.isNotEmpty) {
          _selectedVehicle = vehicles.first;
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Maintenance'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.build_circle,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Record Maintenance',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select maintenance type and vehicle',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Vehicle Selection
                    _buildVehicleSelection(),
                    
                    const SizedBox(height: 16),
                    
                    // Maintenance Item Selection
                    _buildMaintenanceItemSelection(),
                    
                    const SizedBox(height: 16),
                    
                    // Auto-filled Information
                    _buildAutoFilledInfo(),
                    
                    const SizedBox(height: 16),
                    
                    // Optional Notes
                    _buildNotesField(),
                    
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildVehicleSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Select Vehicle',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<VehicleModel>(
              value: _selectedVehicle,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.directions_car_outlined),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              hint: const Text('Choose vehicle'),
              items: _vehicles.map((vehicle) {
                return DropdownMenuItem(
                  value: vehicle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        vehicle.licensePlate,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${vehicle.name} - ${vehicle.model ?? 'N/A'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (vehicle) {
                setState(() {
                  _selectedVehicle = vehicle;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a vehicle';
                }
                return null;
              },
            ),
            if (_selectedVehicle != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Current: ${_selectedVehicle!.hours?.toStringAsFixed(1) ?? '0'} hours, ${_selectedVehicle!.km?.toStringAsFixed(0) ?? '0'} km',
                        style: TextStyle(color: Colors.green[800], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceItemSelection() {
    final activeItems = SimpleMaintenanceItem.getActiveItems();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Maintenance Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SimpleMaintenanceItem>(
              value: _selectedMaintenanceItem,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.build_outlined),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              hint: const Text('Choose maintenance type'),
              items: activeItems.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        item.description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (item) {
                setState(() {
                  _selectedMaintenanceItem = item;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select maintenance type';
                }
                return null;
              },
            ),
            if (_selectedMaintenanceItem != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Interval:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[800],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getIntervalText(_selectedMaintenanceItem!),
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAutoFilledInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Auto-filled Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Date', _formatDate(_selectedDate), Icons.calendar_today),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Current Hours',
                    '${_selectedVehicle?.hours?.toStringAsFixed(1) ?? '0.0'} hours',
                    Icons.schedule,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Current KM',
                    '${_selectedVehicle?.km?.toStringAsFixed(0) ?? '0'} km',
                    Icons.speed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '* These values are automatically filled from vehicle data',
              style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_alt, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Notes (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Any additional notes...',
                prefixIcon: Icon(Icons.edit_note),
              ),
              maxLength: 100,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      onPressed: _selectedVehicle != null && _selectedMaintenanceItem != null
          ? _submitLog
          : null,
      icon: const Icon(Icons.save),
      label: const Text('Record Maintenance'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getIntervalText(SimpleMaintenanceItem item) {
    List<String> intervals = [];
    if (item.intervalMonths != null) {
      intervals.add('${item.intervalMonths} months');
    }
    if (item.intervalHours != null) {
      intervals.add('${item.intervalHours} hours');
    }
    if (item.intervalKm != null) {
      intervals.add('${item.intervalKm} km');
    }
    return intervals.isNotEmpty ? intervals.join(' or ') : 'As needed';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _submitLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final log = MaintenanceLog(
        itemName: _selectedMaintenanceItem!.name,
        date: _selectedDate,
        hours: _selectedVehicle!.hours ?? 0.0,
        km: _selectedVehicle!.km ?? 0.0,
        notes: _notesController.text.trim().isEmpty ? 'Routine maintenance completed' : _notesController.text.trim(),
        vehicleId: _selectedVehicle!.id,
        performedBy: 'current_user', // This would be the actual user ID
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _logService.addLog(log);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Maintenance recorded successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording maintenance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

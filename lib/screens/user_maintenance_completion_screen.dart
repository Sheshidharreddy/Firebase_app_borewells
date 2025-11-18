import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../models/simple_maintenance_item.dart';
import '../models/maintenance_log_model.dart';
import '../services/test_maintenance_log_service.dart';

class UserMaintenanceCompletionScreen extends StatefulWidget {
  final VehicleModel vehicle;
  final SimpleMaintenanceItem maintenanceItem;
  final String userId;

  const UserMaintenanceCompletionScreen({
    super.key,
    required this.vehicle,
    required this.maintenanceItem,
    required this.userId,
  });

  @override
  State<UserMaintenanceCompletionScreen> createState() => _UserMaintenanceCompletionScreenState();
}

class _UserMaintenanceCompletionScreenState extends State<UserMaintenanceCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TestMaintenanceLogService _logService = TestMaintenanceLogService();
  
  final _hoursController = TextEditingController();
  final _kmController = TextEditingController();
  final _notesController = TextEditingController();
  final _oilTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _brandController = TextEditingController();
  final _partNumberController = TextEditingController();
  
  DateTime _completedDate = DateTime.now();
  bool _isSubmitting = false;
  String? _selectedOilType;
  String? _selectedBrand;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current vehicle readings
    _hoursController.text = widget.vehicle.hours?.toStringAsFixed(1) ?? '0.0';
    _kmController.text = widget.vehicle.km?.toStringAsFixed(0) ?? '0';
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _kmController.dispose();
    _notesController.dispose();
    _oilTypeController.dispose();
    _quantityController.dispose();
    _brandController.dispose();
    _partNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Maintenance'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskInfoCard(),
                const SizedBox(height: 16),
                _buildCompletionFormCard(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.build,
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
                        widget.maintenanceItem.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'on ${widget.vehicle.name}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Description:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.maintenanceItem.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionFormCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completion Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Current Readings Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vehicle Readings at Time of Service:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _hoursController,
                          decoration: const InputDecoration(
                            labelText: 'Engine Hours',
                            suffixText: 'hrs',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _kmController,
                          decoration: const InputDecoration(
                            labelText: 'Kilometers',
                            suffixText: 'km',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Maintenance Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Maintenance Notes',
                hintText: 'Describe what was done, parts used, observations, etc.',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide details about the maintenance performed';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Completion Checklist
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completion Checklist:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildChecklistItem('✓ Task completed according to specifications'),
                  _buildChecklistItem('✓ All safety procedures followed'),
                  _buildChecklistItem('✓ Vehicle tested and functioning properly'),
                  _buildChecklistItem('✓ Work area cleaned and tools returned'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.green[600],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _completedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _completedDate) {
      setState(() {
        _completedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitMaintenance,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Submitting...'),
                ],
              )
            : const Text(
                'Complete Maintenance Task',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  String _buildMaintenanceNotes() {
    List<String> noteComponents = [];

    // Add maintenance type
    noteComponents.add('Maintenance Type: ${widget.maintenanceItem.name}');

    // Add vehicle readings
    if (_hoursController.text.isNotEmpty) {
      noteComponents.add('Engine Hours: ${_hoursController.text} hrs');
    }
    if (_kmController.text.isNotEmpty) {
      noteComponents.add('Kilometers: ${_kmController.text} km');
    }

    // Add oil-specific information for engine oil changes
    if (widget.maintenanceItem.name.toLowerCase().contains('oil')) {
      if (_oilTypeController.text.isNotEmpty) {
        noteComponents.add('Oil Type: ${_oilTypeController.text}');
      }
      if (_brandController.text.isNotEmpty) {
        noteComponents.add('Oil Brand: ${_brandController.text}');
      }
      if (_quantityController.text.isNotEmpty) {
        noteComponents.add('Oil Quantity: ${_quantityController.text} liters');
      }
    }

    // Add filter-specific information
    if (widget.maintenanceItem.name.toLowerCase().contains('filter')) {
      if (_brandController.text.isNotEmpty) {
        noteComponents.add('Filter Brand: ${_brandController.text}');
      }
      if (_partNumberController.text.isNotEmpty) {
        noteComponents.add('Part Number: ${_partNumberController.text}');
      }
    }

    // Add user notes
    if (_notesController.text.trim().isNotEmpty) {
      noteComponents.add('Additional Notes: ${_notesController.text.trim()}');
    }

    // Add completion timestamp
    noteComponents.add('Completed: ${DateTime.now().toString()}');

    return noteComponents.join('\n');
  }

  Future<void> _submitMaintenance() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Build comprehensive notes from form data
      String comprehensiveNotes = _buildMaintenanceNotes();

      // Create maintenance log
      final log = MaintenanceLog(
        id: null, // Will be generated by service
        itemName: widget.maintenanceItem.name,
        date: DateTime.now(),
        hours: double.parse(_hoursController.text),
        km: double.parse(_kmController.text),
        notes: comprehensiveNotes,
        performedBy: 'User', // You can get actual user name
        vehicleId: widget.vehicle.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Submit to service
      await _logService.addLog(log);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Maintenance completed successfully for ${widget.maintenanceItem.name}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting maintenance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

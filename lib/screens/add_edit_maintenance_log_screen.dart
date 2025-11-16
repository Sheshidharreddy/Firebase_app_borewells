import 'package:flutter/material.dart';
import '../models/maintenance_log_model.dart';
import '../services/maintenance_log_service.dart';
import '../services/test_maintenance_log_service.dart';

class AddEditMaintenanceLogScreen extends StatefulWidget {
  final MaintenanceLog? log;
  final String? userId;

  const AddEditMaintenanceLogScreen({
    super.key,
    this.log,
    this.userId,
  });

  @override
  State<AddEditMaintenanceLogScreen> createState() => _AddEditMaintenanceLogScreenState();
}

class _AddEditMaintenanceLogScreenState extends State<AddEditMaintenanceLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final MaintenanceLogService _logService = MaintenanceLogService();
  final TestMaintenanceLogService _testLogService = TestMaintenanceLogService();

  late TextEditingController _itemNameController;
  late TextEditingController _hoursController;
  late TextEditingController _kmController;
  late TextEditingController _notesController;
  
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  
  // Use test mode for now (same as other services)
  static const bool _useTestMode = true;

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController(text: widget.log?.itemName ?? '');
    _hoursController = TextEditingController(
      text: widget.log?.hours.toString() ?? '',
    );
    _kmController = TextEditingController(
      text: widget.log?.km.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.log?.notes ?? '');
    
    if (widget.log != null) {
      _selectedDate = widget.log!.date;
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _hoursController.dispose();
    _kmController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.log != null;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveLog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final log = MaintenanceLog(
        id: widget.log?.id,
        itemName: _itemNameController.text.trim(),
        date: _selectedDate,
        hours: double.tryParse(_hoursController.text) ?? 0.0,
        km: double.tryParse(_kmController.text) ?? 0.0,
        notes: _notesController.text.trim(),
        performedBy: 'Current User', // TODO: Get from auth service
        vehicleId: null, // TODO: Add vehicle selection
        createdAt: widget.log?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        if (_useTestMode) {
          await _testLogService.updateLog(log);
        } else {
          await _logService.updateLog(log);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maintenance log updated successfully')),
          );
        }
      } else {
        if (_useTestMode) {
          await _testLogService.addLog(log);
        } else {
          await _logService.addLog(log);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maintenance log added successfully')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving maintenance log: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Maintenance Log' : 'Add Maintenance Log'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveLog,
              child: Text(
                _isEditing ? 'Update' : 'Save',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Item Name field
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name *',
                  hintText: 'e.g., Oil Change, Brake Pads, Tire Rotation',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.build),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date field
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Hours and KM in a row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hoursController,
                      decoration: const InputDecoration(
                        labelText: 'Hours *',
                        hintText: '0.0',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                        suffixText: 'hrs',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final hours = double.tryParse(value);
                        if (hours == null || hours < 0) {
                          return 'Invalid hours';
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
                        labelText: 'Distance *',
                        hintText: '0.0',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.speed),
                        suffixText: 'km',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final km = double.tryParse(value);
                        if (km == null || km < 0) {
                          return 'Invalid distance';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Additional details, observations, or next steps...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveLog,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(_isEditing ? Icons.update : Icons.save),
                  label: Text(
                    _isEditing ? 'Update Log' : 'Save Log',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Instructions
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Tips',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Be specific with item names for better tracking\n'
                        '• Record both time and distance when applicable\n'
                        '• Use notes for important observations or next steps\n'
                        '• Regular maintenance helps extend vehicle life',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
    
    if (selectedDay == today) {
      return 'Today (${_getFormattedDate(date)})';
    } else if (selectedDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday (${_getFormattedDate(date)})';
    } else {
      return _getFormattedDate(date);
    }
  }

  String _getFormattedDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

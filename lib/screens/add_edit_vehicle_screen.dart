import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';

class AddEditVehicleScreen extends StatefulWidget {
  final VehicleModel? vehicle;

  const AddEditVehicleScreen({super.key, this.vehicle});

  bool get isEditing => vehicle != null;

  @override
  State<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final VehicleService _vehicleService = VehicleService();
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _capacityController = TextEditingController();
  final _notesController = TextEditingController();
  
  VehicleType _selectedType = VehicleType.truck;
  VehicleStatus _selectedStatus = VehicleStatus.available;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _populateForm();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _licensePlateController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _capacityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _populateForm() {
    final vehicle = widget.vehicle!;
    _nameController.text = vehicle.name;
    _licensePlateController.text = vehicle.licensePlate;
    _modelController.text = vehicle.model ?? '';
    _yearController.text = vehicle.year ?? '';
    _colorController.text = vehicle.color ?? '';
    _capacityController.text = vehicle.capacity?.toString() ?? '';
    _notesController.text = vehicle.notes ?? '';
    _selectedType = vehicle.type;
    _selectedStatus = vehicle.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Basic Information Section
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _nameController,
              label: 'Vehicle Name',
              hint: 'e.g., Service Truck 01',
              icon: Icons.directions_car,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vehicle name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _licensePlateController,
              label: 'License Plate',
              hint: 'e.g., ABC-1234',
              icon: Icons.credit_card,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter license plate';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Vehicle Type Dropdown
            _buildDropdown<VehicleType>(
              label: 'Vehicle Type',
              value: _selectedType,
              icon: Icons.category,
              items: VehicleType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeDisplayName(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Status Dropdown
            _buildDropdown<VehicleStatus>(
              label: 'Status',
              value: _selectedStatus,
              icon: Icons.info,
              items: VehicleStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_getStatusDisplayName(status)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Vehicle Details Section
            _buildSectionHeader('Vehicle Details'),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _modelController,
                    label: 'Model',
                    hint: 'e.g., Ford Transit',
                    icon: Icons.directions_car,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _yearController,
                    label: 'Year',
                    hint: 'e.g., 2023',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final year = int.tryParse(value);
                        if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                          return 'Invalid year';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _colorController,
                    label: 'Color',
                    hint: 'e.g., White',
                    icon: Icons.color_lens,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _capacityController,
                    label: 'Capacity (tons)',
                    hint: 'e.g., 2.5',
                    icon: Icons.scale,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final capacity = double.tryParse(value);
                        if (capacity == null || capacity <= 0) {
                          return 'Invalid capacity';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _notesController,
              label: 'Notes',
              hint: 'Additional information about the vehicle',
              icon: Icons.notes,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.isEditing ? 'Update Vehicle' : 'Add Vehicle',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  String _getTypeDisplayName(VehicleType type) {
    switch (type) {
      case VehicleType.truck:
        return 'Truck';
      case VehicleType.van:
        return 'Van';
      case VehicleType.car:
        return 'Car';
      case VehicleType.motorcycle:
        return 'Motorcycle';
    }
  }

  String _getStatusDisplayName(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return 'Available';
      case VehicleStatus.inUse:
        return 'In Use';
      case VehicleStatus.maintenance:
        return 'Maintenance';
      case VehicleStatus.outOfService:
        return 'Out of Service';
    }
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

  void _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final capacity = _capacityController.text.isNotEmpty 
          ? double.tryParse(_capacityController.text) 
          : null;

      if (widget.isEditing) {
        // Update existing vehicle
        final updatedVehicle = widget.vehicle!.copyWith(
          name: _nameController.text.trim(),
          licensePlate: _licensePlateController.text.trim(),
          type: _selectedType,
          status: _selectedStatus,
          model: _modelController.text.isNotEmpty ? _modelController.text.trim() : null,
          year: _yearController.text.isNotEmpty ? _yearController.text.trim() : null,
          color: _colorController.text.isNotEmpty ? _colorController.text.trim() : null,
          capacity: capacity,
          notes: _notesController.text.isNotEmpty ? _notesController.text.trim() : null,
          updatedAt: now,
        );
        
        await _vehicleService.updateVehicle(updatedVehicle);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle updated successfully')),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Add new vehicle
        final newVehicle = VehicleModel(
          id: '', // Will be set by the service
          name: _nameController.text.trim(),
          licensePlate: _licensePlateController.text.trim(),
          type: _selectedType,
          status: _selectedStatus,
          model: _modelController.text.isNotEmpty ? _modelController.text.trim() : null,
          year: _yearController.text.isNotEmpty ? _yearController.text.trim() : null,
          color: _colorController.text.isNotEmpty ? _colorController.text.trim() : null,
          capacity: capacity,
          notes: _notesController.text.isNotEmpty ? _notesController.text.trim() : null,
          createdAt: now,
          updatedAt: now,
        );
        
        await _vehicleService.addVehicle(newVehicle);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle added successfully')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving vehicle: $e')),
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
}

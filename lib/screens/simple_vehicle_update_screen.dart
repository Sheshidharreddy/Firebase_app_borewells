import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../services/test_vehicle_service.dart';

class SimpleVehicleUpdateScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const SimpleVehicleUpdateScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<SimpleVehicleUpdateScreen> createState() => _SimpleVehicleUpdateScreenState();
}

class _SimpleVehicleUpdateScreenState extends State<SimpleVehicleUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TestVehicleService _vehicleService = TestVehicleService();
  
  late TextEditingController _hoursController;
  late TextEditingController _kmController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _hoursController = TextEditingController(
      text: widget.vehicle.hours?.toStringAsFixed(1) ?? '0.0',
    );
    _kmController = TextEditingController(
      text: widget.vehicle.km?.toStringAsFixed(0) ?? '0',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Vehicle Readings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vehicle Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.vehicle.licensePlate,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.vehicle.name} - ${widget.vehicle.model ?? 'N/A'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.vehicle.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(widget.vehicle.status).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          widget.vehicle.status.name.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(widget.vehicle.status),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Update Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You can only update vehicle hours and kilometers. Other changes require admin approval.',
                        style: TextStyle(color: Colors.blue[700], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Hours Input
              _buildHoursInput(),
              
              const SizedBox(height: 16),
              
              // KM Input
              _buildKmInput(),
              
              const SizedBox(height: 24),
              
              // Update Button
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoursInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Total Operating Hours',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _hoursController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                labelText: 'Hours',
                suffixText: 'hours',
                prefixIcon: Icon(Icons.schedule_outlined),
                helperText: 'Enter the current total operating hours',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter hours';
                }
                final hours = double.tryParse(value);
                if (hours == null || hours < 0) {
                  return 'Please enter a valid number';
                }
                final currentHours = widget.vehicle.hours ?? 0.0;
                if (hours < currentHours) {
                  return 'Hours cannot go backwards (current: ${currentHours.toStringAsFixed(1)})';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Current: ${widget.vehicle.hours?.toStringAsFixed(1) ?? '0.0'} hours',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKmInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Total Kilometers',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _kmController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                labelText: 'Kilometers',
                suffixText: 'km',
                prefixIcon: Icon(Icons.speed_outlined),
                helperText: 'Enter the current odometer reading',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter kilometers';
                }
                final km = double.tryParse(value);
                if (km == null || km < 0) {
                  return 'Please enter a valid number';
                }
                final currentKm = widget.vehicle.km ?? 0.0;
                if (km < currentKm) {
                  return 'Kilometers cannot go backwards (current: ${currentKm.toStringAsFixed(0)})';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Current: ${widget.vehicle.km?.toStringAsFixed(0) ?? '0'} km',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _updateVehicle,
      icon: _isLoading 
          ? SizedBox(
              width: 16, 
              height: 16, 
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.save),
      label: Text(_isLoading ? 'Updating...' : 'Update Readings'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
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

  Future<void> _updateVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final hours = double.parse(_hoursController.text);
      final km = double.parse(_kmController.text);

      final updatedVehicle = widget.vehicle.copyWith(
        hours: hours,
        km: km,
        updatedAt: DateTime.now(),
      );

      await _vehicleService.updateVehicle(updatedVehicle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Vehicle readings updated successfully!'),
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
            content: Text('Error updating vehicle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _kmController.dispose();
    super.dispose();
  }
}

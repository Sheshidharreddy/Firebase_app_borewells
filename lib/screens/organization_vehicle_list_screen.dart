import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';
import '../services/organization_service.dart';
import '../services/vehicle_service.dart';
import 'user_vehicle_details_screen.dart';

class OrganizationVehicleListScreen extends StatefulWidget {
  final UserModel currentUser;

  const OrganizationVehicleListScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<OrganizationVehicleListScreen> createState() => _OrganizationVehicleListScreenState();
}

class _OrganizationVehicleListScreenState extends State<OrganizationVehicleListScreen> {
  final VehicleService _vehicleService = VehicleService();
  List<VehicleModel> _vehicles = [];
  List<VehicleModel> _filteredVehicles = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() async {
    setState(() => _isLoading = true);
    
    try {
      // For demo purposes, use demo data
      final allVehicles = OrganizationService.getDemoVehicles();
      final userVehicles = OrganizationService.filterVehiclesByUserAccess(
        allVehicles,
        widget.currentUser,
      );
      
      setState(() {
        _vehicles = userVehicles;
        _filteredVehicles = userVehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading vehicles: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterVehicles(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredVehicles = _vehicles;
      } else {
        _filteredVehicles = _vehicles.where((vehicle) {
          return vehicle.name.toLowerCase().contains(query.toLowerCase()) ||
                 vehicle.licensePlate.toLowerCase().contains(query.toLowerCase()) ||
                 (vehicle.model?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.currentUser.name}\'s Vehicles'),
        backgroundColor: widget.currentUser.isAdmin ? Colors.purple : Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadVehicles,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildUserInfo(),
          _buildSearchBar(),
          Expanded(
            child: _isLoading ? _buildLoadingView() : _buildVehicleList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    final organizationName = OrganizationService.getOrganizationName(widget.currentUser.organizationId);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.currentUser.isAdmin ? Colors.purple[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.currentUser.isAdmin ? Colors.purple[200]! : Colors.green[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.currentUser.isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: widget.currentUser.isAdmin ? Colors.purple : Colors.green,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.currentUser.name} (${widget.currentUser.role.toUpperCase()})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.currentUser.isAdmin ? Colors.purple : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Organization: $organizationName',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.currentUser.isAdmin
                ? 'Access: All vehicles in organization (${_vehicles.length} vehicles)'
                : 'Access: Only assigned vehicles (${_vehicles.length} vehicles)',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: _filterVehicles,
        decoration: InputDecoration(
          hintText: 'Search vehicles...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _filterVehicles('');
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildVehicleList() {
    if (_filteredVehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.directions_car_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No vehicles match your search'
                  : widget.currentUser.isAdmin
                      ? 'No vehicles in your organization'
                      : 'No vehicles assigned to you',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty && !widget.currentUser.isAdmin) ...[
              const SizedBox(height: 8),
              Text(
                'Contact your admin to get vehicle assignments',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredVehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _filteredVehicles[index];
        return _buildVehicleCard(vehicle);
      },
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserVehicleDetailsScreen(
                vehicle: vehicle,
                userId: widget.currentUser.id,
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
                  // Vehicle Type Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(vehicle.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getVehicleIcon(vehicle.type),
                      color: _getStatusColor(vehicle.status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Vehicle Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          vehicle.licensePlate,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                        if (vehicle.model != null) ...[
                          Text(
                            '${vehicle.model} ${vehicle.year ?? ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(vehicle.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vehicle.statusDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Vehicle Details
              Row(
                children: [
                  if (vehicle.hours != null) ...[
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${vehicle.hours!.toStringAsFixed(1)} hrs',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (vehicle.km != null) ...[
                    Icon(Icons.speed, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${vehicle.km!.toStringAsFixed(0)} km',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                  const Spacer(),
                  if (vehicle.hasDriver) ...[
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      vehicle.driverName!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.truck:
        return Icons.local_shipping;
      case VehicleType.van:
        return Icons.airport_shuttle;
      case VehicleType.car:
        return Icons.directions_car;
      case VehicleType.motorcycle:
        return Icons.motorcycle;
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
}
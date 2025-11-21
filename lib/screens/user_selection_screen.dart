import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/organization_service.dart';

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  List<UserModel> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _allUsers = OrganizationService.getDemoUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: _buildUsersList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Role-Based Access Demo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Select a user profile to see how different roles and organizations affect vehicle access:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Admins can see all vehicles in their organization\n'
            '• Drivers can only see their assigned vehicles\n'
            '• Each organization is isolated from others',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    // Group users by organization
    final organizationGroups = <String, List<UserModel>>{};
    for (final user in _allUsers) {
      if (!organizationGroups.containsKey(user.organizationId)) {
        organizationGroups[user.organizationId] = [];
      }
      organizationGroups[user.organizationId]!.add(user);
    }

    return ListView.builder(
      itemCount: organizationGroups.length,
      itemBuilder: (context, index) {
        final organizationId = organizationGroups.keys.elementAt(index);
        final users = organizationGroups[organizationId]!;
        final organizationName = OrganizationService.getOrganizationName(organizationId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                organizationName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            ...users.map((user) => _buildUserCard(user)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    final isAdmin = user.isAdmin;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _selectUser(user),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // User Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isAdmin ? Colors.purple[100] : Colors.green[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: isAdmin ? Colors.purple : Colors.green,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name ?? 'Unknown User',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isAdmin ? Colors.purple[50] : Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isAdmin ? 'ADMIN' : 'DRIVER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isAdmin ? Colors.purple : Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          OrganizationService.getOrganizationName(user.organizationId),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Access Indicator
              Column(
                children: [
                  Icon(
                    isAdmin ? Icons.visibility : Icons.visibility_outlined,
                    color: isAdmin ? Colors.purple : Colors.green,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAdmin ? 'All Org\nVehicles' : 'Assigned\nVehicles',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectUser(UserModel user) {
    // Show user access info dialog first
    _showUserAccessDialog(user);
  }

  void _showUserAccessDialog(UserModel user) {
    final organizationName = OrganizationService.getOrganizationName(user.organizationId);
    final vehicles = OrganizationService.getDemoVehicles();
    final userVehicles = OrganizationService.filterVehiclesByUserAccess(vehicles, user);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              user.isAdmin ? Icons.admin_panel_settings : Icons.person,
              color: user.isAdmin ? Colors.purple : Colors.green,
            ),
            const SizedBox(width: 8),
            Text('${user.name}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Organization: $organizationName'),
            const SizedBox(height: 8),
            Text('Role: ${user.role.toUpperCase()}'),
            const SizedBox(height: 8),
            Text(
              user.isAdmin 
                ? 'Can access ALL vehicles in organization'
                : 'Can only access ASSIGNED vehicles',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: user.isAdmin ? Colors.purple : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text('Accessible Vehicles: ${userVehicles.length}'),
            const SizedBox(height: 8),
            ...userVehicles.take(3).map((vehicle) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• ${vehicle.name} (${vehicle.licensePlate})'),
            )),
            if (userVehicles.length > 3)
              Text('• ... and ${userVehicles.length - 3} more'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToVehicleList(user);
            },
            child: const Text('View Vehicles'),
          ),
        ],
      ),
    );
  }

  void _navigateToVehicleList(UserModel user) {
    // For now, just show a snackbar with the user info
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Logged in as ${user.name} (${user.role}) - '
          '${OrganizationService.getOrganizationName(user.organizationId)}'
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: user.isAdmin ? Colors.purple : Colors.green,
      ),
    );
  }
}
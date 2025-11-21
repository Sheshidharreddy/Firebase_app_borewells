import '../models/user_model.dart';
import '../models/vehicle_model.dart';

class OrganizationService {
  static const Map<String, String> _organizationNames = {
    'org_a': 'Organization A',
    'org_b': 'Organization B', 
    'org_c': 'Organization C',
    'org_default': 'Default Organization',
  };

  // Get organization name by ID
  static String getOrganizationName(String organizationId) {
    return _organizationNames[organizationId] ?? 'Unknown Organization';
  }

  // Filter vehicles based on user's organization and role
  static List<VehicleModel> filterVehiclesByUserAccess(
    List<VehicleModel> vehicles,
    UserModel currentUser,
  ) {
    if (currentUser.isAdmin) {
      // Admin can see all vehicles in their organization
      return vehicles.where((vehicle) => 
        vehicle.organizationId == currentUser.organizationId
      ).toList();
    } else {
      // Regular users can only see vehicles assigned to them
      return vehicles.where((vehicle) => 
        vehicle.organizationId == currentUser.organizationId &&
        vehicle.driverId == currentUser.id
      ).toList();
    }
  }

  // Filter users based on admin's organization
  static List<UserModel> filterUsersByAdminAccess(
    List<UserModel> users,
    UserModel adminUser,
  ) {
    if (!adminUser.isAdmin) {
      return []; // Non-admin users cannot see other users
    }

    // Admin can see all users in their organization
    return users.where((user) => 
      user.organizationId == adminUser.organizationId
    ).toList();
  }

  // Check if user can access a specific vehicle
  static bool canUserAccessVehicle(UserModel user, VehicleModel vehicle) {
    // Must be same organization
    if (user.organizationId != vehicle.organizationId) {
      return false;
    }

    // Admin can access all vehicles in their organization
    if (user.isAdmin) {
      return true;
    }

    // Regular user can only access vehicles assigned to them
    return vehicle.driverId == user.id;
  }

  // Check if admin can manage a specific user
  static bool canAdminManageUser(UserModel admin, UserModel targetUser) {
    if (!admin.isAdmin) {
      return false;
    }

    // Admin can manage users in their organization
    return admin.organizationId == targetUser.organizationId;
  }

  // Get demo users for different organizations
  static List<UserModel> getDemoUsers() {
    final now = DateTime.now();
    
    return [
      // Organization A users
      UserModel(
        id: 'admin_a1',
        email: 'admin.a1@orga.com',
        role: 'admin',
        name: 'Admin A1',
        organizationId: 'org_a',
        createdAt: now.subtract(const Duration(days: 100)),
      ),
      UserModel(
        id: 'user_a1',
        email: 'driver.a1@orga.com',
        role: 'driver',
        name: 'Driver A1',
        organizationId: 'org_a',
        createdAt: now.subtract(const Duration(days: 80)),
      ),
      UserModel(
        id: 'user_a2',
        email: 'driver.a2@orga.com',
        role: 'driver',
        name: 'Driver A2',
        organizationId: 'org_a',
        createdAt: now.subtract(const Duration(days: 70)),
      ),
      UserModel(
        id: 'user_a3',
        email: 'driver.a3@orga.com',
        role: 'driver',
        name: 'Driver A3',
        organizationId: 'org_a',
        createdAt: now.subtract(const Duration(days: 60)),
      ),

      // Organization B users  
      UserModel(
        id: 'admin_b1',
        email: 'admin.b1@orgb.com',
        role: 'admin',
        name: 'Admin B1',
        organizationId: 'org_b',
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      UserModel(
        id: 'user_b1',
        email: 'driver.b1@orgb.com',
        role: 'driver',
        name: 'Driver B1',
        organizationId: 'org_b',
        createdAt: now.subtract(const Duration(days: 50)),
      ),
      UserModel(
        id: 'user_b2',
        email: 'driver.b2@orgb.com',
        role: 'driver',
        name: 'Driver B2',
        organizationId: 'org_b',
        createdAt: now.subtract(const Duration(days: 40)),
      ),
      UserModel(
        id: 'user_b3',
        email: 'driver.b3@orgb.com',
        role: 'driver',
        name: 'Driver B3',
        organizationId: 'org_b',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }

  // Get demo vehicles for different organizations
  static List<VehicleModel> getDemoVehicles() {
    final now = DateTime.now();

    return [
      // Organization A vehicles
      VehicleModel(
        id: 'vehicle_a1',
        name: 'Truck A-001',
        licensePlate: 'AA-001-BB',
        type: VehicleType.truck,
        status: VehicleStatus.available,
        organizationId: 'org_a',
        driverId: 'user_a1',
        driverName: 'Driver A1',
        model: 'Ford F-150',
        year: '2022',
        color: 'White',
        capacity: 1500.0,
        hours: 1250.5,
        km: 45000.0,
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      VehicleModel(
        id: 'vehicle_a2',
        name: 'Van A-002',
        licensePlate: 'AA-002-CC',
        type: VehicleType.van,
        status: VehicleStatus.inUse,
        organizationId: 'org_a',
        driverId: 'user_a2',
        driverName: 'Driver A2',
        model: 'Mercedes Sprinter',
        year: '2021',
        color: 'Blue',
        capacity: 3500.0,
        hours: 890.3,
        km: 32000.0,
        createdAt: now.subtract(const Duration(days: 300)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      VehicleModel(
        id: 'vehicle_a3',
        name: 'Car A-003',
        licensePlate: 'AA-003-DD',
        type: VehicleType.car,
        status: VehicleStatus.available,
        organizationId: 'org_a',
        driverId: 'user_a3',
        driverName: 'Driver A3',
        model: 'Toyota Camry',
        year: '2023',
        color: 'Silver',
        capacity: 500.0,
        hours: 450.0,
        km: 18000.0,
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),

      // Organization B vehicles
      VehicleModel(
        id: 'vehicle_b1',
        name: 'Truck B-001',
        licensePlate: 'BB-001-AA',
        type: VehicleType.truck,
        status: VehicleStatus.maintenance,
        organizationId: 'org_b',
        driverId: 'user_b1',
        driverName: 'Driver B1',
        model: 'Chevrolet Silverado',
        year: '2020',
        color: 'Red',
        capacity: 1800.0,
        hours: 2100.8,
        km: 78000.0,
        createdAt: now.subtract(const Duration(days: 400)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      VehicleModel(
        id: 'vehicle_b2',
        name: 'Van B-002',
        licensePlate: 'BB-002-CC',
        type: VehicleType.van,
        status: VehicleStatus.available,
        organizationId: 'org_b',
        driverId: 'user_b2',
        driverName: 'Driver B2',
        model: 'Ford Transit',
        year: '2022',
        color: 'Yellow',
        capacity: 2500.0,
        hours: 650.5,
        km: 25000.0,
        createdAt: now.subtract(const Duration(days: 250)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      VehicleModel(
        id: 'vehicle_b3',
        name: 'Motorcycle B-003',
        licensePlate: 'BB-003-MM',
        type: VehicleType.motorcycle,
        status: VehicleStatus.inUse,
        organizationId: 'org_b',
        driverId: 'user_b3',
        driverName: 'Driver B3',
        model: 'Honda CBR',
        year: '2023',
        color: 'Black',
        capacity: 200.0,
        hours: 180.2,
        km: 8000.0,
        createdAt: now.subtract(const Duration(days: 150)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
class SimpleMaintenanceItem {
  final String id;
  final String name;
  final String description;
  final String? product;
  final String? adminComments;
  final int? intervalMonths;
  final double? intervalHours;
  final double? intervalKm;
  final bool isActive;

  const SimpleMaintenanceItem({
    required this.id,
    required this.name,
    required this.description,
    this.product,
    this.adminComments,
    this.intervalMonths,
    this.intervalHours,
    this.intervalKm,
    this.isActive = true,
  });

  // Predefined maintenance items
  static const List<SimpleMaintenanceItem> predefinedItems = [
    SimpleMaintenanceItem(
      id: 'engine_oil',
      name: 'Engine Oil',
      description: 'Engine oil change and filter replacement',
      intervalMonths: 3,
      intervalHours: 250,
    ),
    SimpleMaintenanceItem(
      id: 'air_filter',
      name: 'Air Filter',
      description: 'Air filter inspection and replacement',
      intervalMonths: 6,
      intervalHours: 500,
    ),
    SimpleMaintenanceItem(
      id: 'fuel_filters',
      name: 'Fuel Filters',
      description: 'Fuel filter replacement',
      intervalMonths: 12,
      intervalKm: 20000,
    ),
    SimpleMaintenanceItem(
      id: 'fuel_injectors',
      name: 'Fuel Injectors',
      description: 'Fuel injector cleaning and service',
      intervalMonths: 24,
      intervalKm: 50000,
    ),
    SimpleMaintenanceItem(
      id: 'wheel_maintenance',
      name: 'Wheel Maintenance',
      description: 'Wheel alignment, balancing, and tire inspection',
      intervalMonths: 6,
      intervalKm: 10000,
    ),
    SimpleMaintenanceItem(
      id: 'compressor_oil',
      name: 'Compressor Oil Change',
      description: 'Compressor oil change and system check',
      intervalMonths: 6,
      intervalHours: 1000,
    ),
    SimpleMaintenanceItem(
      id: 'compressor_air_filter',
      name: 'Compressor Air Filter',
      description: 'Compressor air filter replacement',
      intervalMonths: 3,
      intervalHours: 500,
    ),
    SimpleMaintenanceItem(
      id: 'hydraulic_fluid',
      name: 'Hydraulic Fluid',
      description: 'Hydraulic fluid change and system inspection',
      intervalMonths: 12,
      intervalHours: 2000,
    ),
  ];

  // Get item by ID
  static SimpleMaintenanceItem? getById(String id) {
    try {
      return predefinedItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get active items
  static List<SimpleMaintenanceItem> getActiveItems() {
    return predefinedItems.where((item) => item.isActive).toList();
  }
}

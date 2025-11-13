import 'package:flutter/material.dart';
import '../services/role_service.dart';

/// A widget that conditionally shows content based on user permissions
class PermissionWidget extends StatefulWidget {
  final bool? allowed;
  final Permission? permission;
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const PermissionWidget({
    Key? key,
    this.allowed,
    this.permission,
    required this.child,
    this.fallback,
    this.showFallback = false,
  }) : super(key: key);

  @override
  State<PermissionWidget> createState() => _PermissionWidgetState();
}

class _PermissionWidgetState extends State<PermissionWidget> {
  final RoleService _roleService = RoleService();
  bool? _hasPermission;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    try {
      bool hasPermission;
      
      if (widget.allowed != null) {
        // Use explicit allowed value
        hasPermission = widget.allowed!;
      } else if (widget.permission != null) {
        // Check permission using role service
        hasPermission = await _roleService.hasPermission(widget.permission!);
      } else {
        // Default to not allowed if neither is provided
        hasPermission = false;
      }

      if (mounted) {
        setState(() {
          _hasPermission = hasPermission;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasPermission = false; // Default to no permission on error
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink(); // Or loading indicator
    }

    if (_hasPermission == true) {
      return widget.child;
    } else if (widget.showFallback && widget.fallback != null) {
      return widget.fallback!;
    } else {
      return const SizedBox.shrink();
    }
  }
}

/// A widget that disables content based on user permissions
class PermissionDisabledWidget extends StatefulWidget {
  final bool? allowed;
  final Permission? permission;
  final Widget child;
  final double disabledOpacity;
  final String? tooltip;

  const PermissionDisabledWidget({
    Key? key,
    this.allowed,
    this.permission,
    required this.child,
    this.disabledOpacity = 0.5,
    this.tooltip,
  }) : super(key: key);

  @override
  State<PermissionDisabledWidget> createState() => _PermissionDisabledWidgetState();
}

class _PermissionDisabledWidgetState extends State<PermissionDisabledWidget> {
  final RoleService _roleService = RoleService();
  bool? _hasPermission;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    try {
      bool hasPermission;
      
      if (widget.allowed != null) {
        hasPermission = widget.allowed!;
      } else if (widget.permission != null) {
        hasPermission = await _roleService.hasPermission(widget.permission!);
      } else {
        hasPermission = false;
      }

      if (mounted) {
        setState(() {
          _hasPermission = hasPermission;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.child;
    }

    if (_hasPermission == true) {
      return widget.child;
    } else {
      Widget disabledChild = Opacity(
        opacity: widget.disabledOpacity,
        child: IgnorePointer(
          child: widget.child,
        ),
      );

      if (widget.tooltip != null) {
        disabledChild = Tooltip(
          message: widget.tooltip!,
          child: disabledChild,
        );
      }

      return disabledChild;
    }
  }
}

/// Helper widget for admin-only content
class AdminOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const AdminOnlyWidget({
    Key? key,
    required this.child,
    this.fallback,
    this.showFallback = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionWidget(
      permission: Permission.viewAdminDashboard,
      child: child,
      fallback: fallback,
      showFallback: showFallback,
    );
  }
}

/// Helper widget for user-only content
class UserOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const UserOnlyWidget({
    Key? key,
    required this.child,
    this.fallback,
    this.showFallback = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: RoleService().isUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final isUser = snapshot.data ?? false;
        if (isUser) {
          return child;
        } else if (showFallback && fallback != null) {
          return fallback!;
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

/// Role-based AppBar actions
class RoleBasedAppBarActions extends StatelessWidget {
  final List<Widget> adminActions;
  final List<Widget> userActions;

  const RoleBasedAppBarActions({
    Key? key,
    required this.adminActions,
    required this.userActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: RoleService().isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final isAdmin = snapshot.data ?? false;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: isAdmin ? adminActions : userActions,
        );
      },
    );
  }
}

/// Role-based navigation drawer
class RoleBasedDrawer extends StatelessWidget {
  final List<Widget> adminItems;
  final List<Widget> userItems;
  final List<Widget> commonItems;

  const RoleBasedDrawer({
    Key? key,
    required this.adminItems,
    required this.userItems,
    required this.commonItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<bool>(
        future: RoleService().isAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final isAdmin = snapshot.data ?? false;
          final roleSpecificItems = isAdmin ? adminItems : userItems;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              ...commonItems,
              ...roleSpecificItems,
            ],
          );
        },
      ),
    );
  }
}

/// Conditional form field based on permissions
class PermissionFormField extends StatelessWidget {
  final bool? allowed;
  final Permission? permission;
  final Widget child;
  final String? disabledMessage;

  const PermissionFormField({
    Key? key,
    this.allowed,
    this.permission,
    required this.child,
    this.disabledMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionDisabledWidget(
      allowed: allowed,
      permission: permission,
      tooltip: disabledMessage ?? 'You do not have permission to edit this field',
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/session_service.dart';
import '../services/user_management_service.dart';

class CreateUserScreen extends StatefulWidget {
  final bool isSuperAdmin;
  final UserModel? prefilledAdmin;

  const CreateUserScreen({
    super.key,
    this.isSuperAdmin = false,
    this.prefilledAdmin,
  });

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserManagementService _service = UserManagementService();
  bool _isSaving = false;

  List<UserModel> _admins = [];
  String? _selectedAdminId;

  @override
  void initState() {
    super.initState();
    if (widget.isSuperAdmin) {
      _loadAdmins();
    } else {
      _selectedAdminId = widget.prefilledAdmin?.id ?? SessionService.instance.currentUser?.id;
    }
  }

  Future<void> _loadAdmins() async {
    final admins = await _service.getAdminsOnce();
    if (!mounted) return;
    setState(() {
      _admins = admins;
      if (_admins.isNotEmpty) {
        _selectedAdminId ??= _admins.first.id;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = widget.isSuperAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSuperAdmin ? 'Create User (Super Admin)' : 'Create User'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Users represent drivers or operators. They log into the mobile/web app to view and update fleet information.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    if (isSuperAdmin) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedAdminId,
                        decoration: const InputDecoration(
                          labelText: 'Assign to Admin',
                          border: OutlineInputBorder(),
                        ),
                        items: _admins
                            .map(
                              (admin) => DropdownMenuItem(
                                value: admin.id,
                                child: Text(admin.name ?? admin.email),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _selectedAdminId = value),
                        validator: (_) {
                          if (_selectedAdminId == null || _selectedAdminId!.isEmpty) {
                            return 'Select an admin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter a name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter an email address';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Temporary Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Create User'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final tempPassword = _passwordController.text.trim();

    try {
      final user = await _service.createUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        tempPassword: tempPassword,
        adminIdOverride: widget.isSuperAdmin ? _selectedAdminId : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User created for admin ${user.adminId}. Share credentials: ${user.email} / $tempPassword',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

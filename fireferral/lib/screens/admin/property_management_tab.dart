import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import 'create_property_screen.dart';

class PropertyManagementTab extends StatefulWidget {
  const PropertyManagementTab({super.key});

  @override
  State<PropertyManagementTab> createState() => _PropertyManagementTabState();
}

class _PropertyManagementTabState extends State<PropertyManagementTab> {
  final AuthService _authService = AuthService();
  List<UserModel> _properties = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);
    
    try {
      final properties = await _authService.getAllProperties();
      
      if (mounted) {
        setState(() {
          _properties = properties;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading properties: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  List<UserModel> get _filteredProperties {
    if (_searchQuery.isEmpty) return _properties;
    
    return _properties.where((property) {
      final name = property.propertyName?.toLowerCase() ?? '';
      final email = property.email.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header with Add Property button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Property Management',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CreatePropertyScreen(),
                      ),
                    );
                    _loadProperties(); // Refresh list after creating
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Property'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A8E6),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search properties...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Properties count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.business,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_filteredProperties.length} ${_filteredProperties.length == 1 ? 'Property' : 'Properties'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Properties list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProperties.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadProperties,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredProperties.length,
                          itemBuilder: (context, index) {
                            final property = _filteredProperties[index];
                            return _buildPropertyCard(property);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(UserModel property) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00A8E6), Color(0xFF0066CC)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.business,
            color: Colors.white,
          ),
        ),
        title: Text(
          property.propertyName ?? 'Unnamed Property',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${property.firstName} ${property.lastName}'),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.email, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(property.email)),
              ],
            ),
            if (property.propertyAddress != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(property.propertyAddress!)),
                ],
              ),
            ],
            if (property.phone != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(property.phone!),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'deactivate':
                _deactivateProperty(property);
                break;
              case 'reset_password':
                _resetPassword(property);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'reset_password',
              child: ListTile(
                leading: Icon(Icons.lock_reset),
                title: Text('Reset Password'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'deactivate',
              child: ListTile(
                leading: Icon(
                  property.isActive ? Icons.block : Icons.check_circle,
                  color: property.isActive ? Colors.red : Colors.green,
                ),
                title: Text(property.isActive ? 'Deactivate' : 'Activate'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No properties yet'
                : 'No properties found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Add your first property to get started'
                : 'Try a different search term',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreatePropertyScreen(),
                  ),
                );
                _loadProperties();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Property'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A8E6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _deactivateProperty(UserModel property) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(property.isActive ? 'Deactivate Property' : 'Activate Property'),
        content: Text(
          property.isActive
              ? 'Are you sure you want to deactivate ${property.propertyName}? They will not be able to log in.'
              : 'Are you sure you want to activate ${property.propertyName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: property.isActive ? Colors.red : Colors.green,
            ),
            child: Text(property.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (property.isActive) {
          await _authService.deactivateUser(property.id);
        } else {
          await _authService.reactivateUser(property.id);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                property.isActive
                    ? 'Property deactivated successfully'
                    : 'Property activated successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _loadProperties();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _resetPassword(UserModel property) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text(
          'Send a password reset email to ${property.email}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Send Email'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _authService.resetPassword(property.email);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset email sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

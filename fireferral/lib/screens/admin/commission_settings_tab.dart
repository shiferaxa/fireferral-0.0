import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/fiber_package.dart';
import '../../services/package_service.dart';

class CommissionSettingsTab extends StatefulWidget {
  const CommissionSettingsTab({super.key});

  @override
  State<CommissionSettingsTab> createState() => _CommissionSettingsTabState();
}

class _CommissionSettingsTabState extends State<CommissionSettingsTab> {
  List<FiberPackage> _packages = [];
  bool _isLoading = true;
  bool _hasChanges = false;
  final Map<String, TextEditingController> _affiliateControllers = {};
  final Map<String, TextEditingController> _associateControllers = {};

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      final packages = await PackageService.getPackages();
      _initializeControllers(packages);
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    } catch (e) {
      final defaultPackages = FiberPackage.getDefaultPackages();
      _initializeControllers(defaultPackages);
      setState(() {
        _packages = defaultPackages;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading packages: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _initializeControllers(List<FiberPackage> packages) {
    // Dispose existing controllers
    for (var controller in _affiliateControllers.values) {
      controller.dispose();
    }
    for (var controller in _associateControllers.values) {
      controller.dispose();
    }
    
    // Create new controllers
    _affiliateControllers.clear();
    _associateControllers.clear();
    
    for (var package in packages) {
      final key = package.speed.name;
      _affiliateControllers[key] = TextEditingController(
        text: package.affiliateCommission.toStringAsFixed(2),
      );
      _associateControllers[key] = TextEditingController(
        text: package.associateCommission.toStringAsFixed(2),
      );
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _affiliateControllers.values) {
      controller.dispose();
    }
    for (var controller in _associateControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    try {
      await PackageService.savePackages(_packages);
      setState(() {
        _hasChanges = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commission rates updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving commission rates: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commission Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_hasChanges)
                  ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          
          // Info card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00A8E6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00A8E6).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF00A8E6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Commission rates can be updated at any time. Changes will apply to new referrals only.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF00A8E6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Packages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _packages.length,
                    itemBuilder: (context, index) {
                      return _buildPackageCard(_packages[index], index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(FiberPackage package, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A8E6), Color(0xFF0066CC)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.speed,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.speed.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        package.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${package.monthlyPrice.toStringAsFixed(2)}/mo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00A8E6),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Commission settings
            Row(
              children: [
                Expanded(
                  child: _buildCommissionField(
                    'Affiliate Commission',
                    _affiliateControllers[package.speed.name]!,
                    (value) {
                      setState(() {
                        _packages[index] = package.copyWith(
                          affiliateCommission: value,
                        );
                      });
                      _markChanged();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCommissionField(
                    'Associate Commission',
                    _associateControllers[package.speed.name]!,
                    (value) {
                      setState(() {
                        _packages[index] = package.copyWith(
                          associateCommission: value,
                        );
                      });
                      _markChanged();
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Features
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: package.features.map((feature) => Chip(
                label: Text(
                  feature,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: const Color(0xFF00A8E6).withValues(alpha: 0.1),
                side: BorderSide(
                  color: const Color(0xFF00A8E6).withValues(alpha: 0.3),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionField(
    String label,
    TextEditingController controller,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            prefixText: '\$',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          onChanged: (value) {
            final doubleValue = double.tryParse(value);
            if (doubleValue != null) {
              onChanged(doubleValue);
            }
          },
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fiber_package.dart';
import '../../models/referral_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/referral_service.dart';
import '../../services/package_service.dart';

class SubmitReferralScreen extends StatefulWidget {
  const SubmitReferralScreen({super.key});

  @override
  State<SubmitReferralScreen> createState() => _SubmitReferralScreenState();
}

class _SubmitReferralScreenState extends State<SubmitReferralScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _notesController = TextEditingController();
  
  FiberSpeed _selectedPackage = FiberSpeed.skip;
  bool _isLoading = false;
  bool _packagesLoading = true;
  int _currentStep = 0;
  
  List<FiberPackage> _packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      final packages = await PackageService.getPackages();
      setState(() {
        _packages = packages;
        _packagesLoading = false;
      });
    } catch (e) {
      setState(() {
        _packages = FiberPackage.getDefaultPackages();
        _packagesLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading packages: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitReferral() async {
    if (!_formKey.currentState!.validate()) {
      // Go back to the step with errors
      setState(() {
        _currentStep = 0; // Go to customer info step
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final referralService = ReferralService();
      
      // Get commission amount based on user role
      final selectedPackageData = _packages.firstWhere(
        (pkg) => pkg.speed == _selectedPackage,
      );
      
      final commissionAmount = user.role == UserRole.associate 
          ? selectedPackageData.associateCommission
          : selectedPackageData.affiliateCommission;
      
      final customerInfo = CustomerInfo(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipCode: _zipController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      
      await referralService.submitReferral(
        submittedBy: user.id,
        customer: customerInfo,
        selectedPackage: _selectedPackage,
        commissionAmount: commissionAmount,
        organizationId: user.organizationId,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Referral submitted successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        
        // Reset form
        _formKey.currentState?.reset();
        setState(() {
          _currentStep = 0;
          _selectedPackage = FiberSpeed.skip;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting referral: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Referral'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A8E6), Color(0xFF0066CC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
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
        child: _packagesLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading packages...'),
                  ],
                ),
              )
            : Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            onStepTapped: (step) => setState(() => _currentStep = step),
            controlsBuilder: (context, details) {
              return Row(
                children: [
                  if (details.stepIndex < 2)
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A8E6),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Next'),
                    ),
                  if (details.stepIndex == 2)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitReferral,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A8E6),
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Submit Referral'),
                    ),
                  const SizedBox(width: 8),
                  if (details.stepIndex > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                ],
              );
            },
            steps: [
              Step(
                title: const Text('Customer Information'),
                content: _buildCustomerInfoStep(),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: const Text('Package Selection'),
                content: _buildPackageSelectionStep(),
                isActive: _currentStep >= 1,
              ),
              Step(
                title: const Text('Review & Submit'),
                content: _buildReviewStep(),
                isActive: _currentStep >= 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfoStep() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter last name';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Street Address',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter state';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _zipController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ZIP Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter ZIP code';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notes (Optional)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageSelectionStep() {
    final skipPackage = _packages.firstWhere((p) => p.speed == FiberSpeed.skip);
    final regularPackages = _packages.where((p) => p.speed != FiberSpeed.skip).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Fiber Package (Optional)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You can skip package selection and let the customer choose during installation.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        
        // Skip option - compact style
        _buildSkipCard(skipPackage),
        const SizedBox(height: 16),
        
        // Divider
        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR CHOOSE A SPECIFIC PACKAGE',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        
        // Regular packages
        ...regularPackages.map((package) => _buildPackageCard(package)),
      ],
    );
  }

  Widget _buildSkipCard(FiberPackage package) {
    final isSelected = _selectedPackage == package.speed;
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser!;
    final commission = user.role == UserRole.associate 
        ? package.associateCommission
        : package.affiliateCommission;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedPackage = package.speed),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<FiberSpeed>(
                value: package.speed,
                groupValue: _selectedPackage,
                onChanged: (value) => setState(() => _selectedPackage = value!),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.schedule,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skip Package Selection',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Theme.of(context).colorScheme.primary : null,
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
                'Commission: \$${commission.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(FiberPackage package) {
    final isSelected = _selectedPackage == package.speed;
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser!;
    final commission = user.role == UserRole.associate 
        ? package.associateCommission
        : package.affiliateCommission;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF00A8E6) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedPackage = package.speed),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<FiberSpeed>(
                value: package.speed,
                groupValue: _selectedPackage,
                onChanged: (value) => setState(() => _selectedPackage = value!),
                activeColor: const Color(0xFF00A8E6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.speed.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF00A8E6) : null,
                      ),
                    ),
                    Text(
                      package.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: package.features.map((feature) => Chip(
                        label: Text(
                          feature,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: isSelected 
                            ? const Color(0xFF00A8E6).withValues(alpha: 0.1)
                            : null,
                      )).toList(),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Speed: ${package.speed.displayName}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Commission: \$${commission.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
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

  Widget _buildReviewStep() {
    final selectedPackage = _packages.firstWhere(
      (pkg) => pkg.speed == _selectedPackage,
    );
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser!;
    final commission = user.role == UserRole.associate 
        ? selectedPackage.associateCommission
        : selectedPackage.affiliateCommission;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Referral Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildReviewRow('Name', '${_firstNameController.text} ${_lastNameController.text}'),
                _buildReviewRow('Email', _emailController.text),
                _buildReviewRow('Phone', _phoneController.text),
                _buildReviewRow('Address', '${_addressController.text}, ${_cityController.text}, ${_stateController.text} ${_zipController.text}'),
                if (_notesController.text.isNotEmpty)
                  _buildReviewRow('Notes', _notesController.text),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Package Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildReviewRow('Package', selectedPackage.speed.displayName),
                _buildReviewRow('Monthly Price', '\$${selectedPackage.monthlyPrice.toStringAsFixed(2)}'),
                _buildReviewRow('Your Commission', '\$${commission.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
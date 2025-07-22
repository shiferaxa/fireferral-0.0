import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/referral_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/referral_service.dart';

class ReferralsListScreen extends StatefulWidget {
  const ReferralsListScreen({super.key});

  @override
  State<ReferralsListScreen> createState() => _ReferralsListScreenState();
}

class _ReferralsListScreenState extends State<ReferralsListScreen> {
  final ReferralService _referralService = ReferralService();
  List<ReferralModel> _referrals = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadReferrals();
  }

  Future<void> _loadReferrals() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser!;
      
      List<ReferralModel> referrals;
      if (user.role == UserRole.admin) {
        referrals = await _referralService.getAllReferrals();
      } else {
        referrals = await _referralService.getReferralsByUser(user.id);
      }
      
      setState(() {
        _referrals = referrals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading referrals: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  List<ReferralModel> get _filteredReferrals {
    if (_selectedFilter == 'All') return _referrals;
    
    final status = ReferralStatus.values.firstWhere(
      (s) => s.displayName == _selectedFilter,
      orElse: () => ReferralStatus.submitted,
    );
    
    return _referrals.where((r) => r.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Referrals'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReferrals,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            // Filter chips
            Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'All',
                    ...ReferralStatus.values.map((s) => s.displayName),
                  ].map((filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: const Color(0xFF00A8E6).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF00A8E6),
                    ),
                  )).toList(),
                ),
              ),
            ),
            
            // Referrals list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredReferrals.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadReferrals,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredReferrals.length,
                            itemBuilder: (context, index) {
                              return _buildReferralCard(_filteredReferrals[index]);
                            },
                          ),
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
            Icons.inbox_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'All' 
                ? 'No referrals yet'
                : 'No $_selectedFilter referrals',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'All'
                ? 'Submit your first referral to get started!'
                : 'Try selecting a different filter',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(ReferralModel referral) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showReferralDetails(referral),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      referral.customer.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(referral.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.speed,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    referral.selectedPackage.displayName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: Colors.green,
                  ),
                  Text(
                    '\$${referral.commissionAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      referral.customer.email,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    _formatDate(referral.submittedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildStatusChip(ReferralStatus status) {
    Color color;
    switch (status) {
      case ReferralStatus.submitted:
        color = Colors.blue;
        break;
      case ReferralStatus.underReview:
        color = Colors.orange;
        break;
      case ReferralStatus.approved:
        color = Colors.green;
        break;
      case ReferralStatus.scheduled:
        color = Colors.purple;
        break;
      case ReferralStatus.installed:
        color = Colors.teal;
        break;
      case ReferralStatus.paid:
        color = Colors.green.shade700;
        break;
      case ReferralStatus.rejected:
        color = Colors.red;
        break;
      case ReferralStatus.cancelled:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  void _showReferralDetails(ReferralModel referral) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Referral Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusChip(referral.status),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection('Customer Information', [
                          _buildDetailRow('Name', referral.customer.fullName),
                          _buildDetailRow('Email', referral.customer.email),
                          _buildDetailRow('Phone', referral.customer.phone),
                          _buildDetailRow('Address', referral.customer.fullAddress),
                          if (referral.customer.notes != null)
                            _buildDetailRow('Notes', referral.customer.notes!),
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('Package & Commission', [
                          _buildDetailRow('Package', referral.selectedPackage.displayName),
                          _buildDetailRow('Commission', '\$${referral.commissionAmount.toStringAsFixed(2)}'),
                          _buildDetailRow('Submitted', _formatDate(referral.submittedAt)),
                          if (referral.approvedAt != null)
                            _buildDetailRow('Approved', _formatDate(referral.approvedAt!)),
                          if (referral.installedAt != null)
                            _buildDetailRow('Installed', _formatDate(referral.installedAt!)),
                          if (referral.paidAt != null)
                            _buildDetailRow('Paid', _formatDate(referral.paidAt!)),
                        ]),
                        if (referral.adminNotes != null) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection('Admin Notes', [
                            Text(referral.adminNotes!),
                          ]),
                        ],
                        if (referral.statusHistory.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection('Status History', 
                            referral.statusHistory.map((history) => 
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  history,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              )
                            ).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
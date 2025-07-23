import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/referral_model.dart';
import '../../models/user_model.dart';
import '../../services/referral_service.dart';
import '../../services/auth_service.dart';
import '../../providers/auth_provider.dart';

class ReferralManagementTab extends StatefulWidget {
  const ReferralManagementTab({super.key});

  @override
  State<ReferralManagementTab> createState() => _ReferralManagementTabState();
}

class _ReferralManagementTabState extends State<ReferralManagementTab> {
  final ReferralService _referralService = ReferralService();
  final AuthService _authService = AuthService();
  List<ReferralModel> _referrals = [];
  Map<String, UserModel> _users = {};
  bool _isLoading = true;
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final Set<String> _selectedReferrals = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser!;
      
      // Load all referrals within organization
      final referrals = await _referralService.getAllReferrals(user.organizationId);

      // Load user data for referral submitters
      final userIds = referrals.map((r) => r.submittedBy).toSet();
      final users = <String, UserModel>{};

      for (final userId in userIds) {
        try {
          final user = await _authService.getUserData(userId);
          if (user != null) {
            users[userId] = user;
          }
        } catch (e) {
          debugPrint('Error loading user $userId: $e');
        }
      }

      setState(() {
        _referrals = referrals;
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading referrals: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<ReferralModel> get _filteredReferrals {
    var filtered = _referrals;

    // Apply status filter
    if (_selectedFilter != 'All') {
      final status = ReferralStatus.values.firstWhere(
        (s) => s.displayName == _selectedFilter,
        orElse: () => ReferralStatus.submitted,
      );
      filtered = filtered.where((r) => r.status == status).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final query = _searchQuery.toLowerCase();
        return r.customer.fullName.toLowerCase().contains(query) ||
            r.customer.email.toLowerCase().contains(query) ||
            r.id.toLowerCase().contains(query) ||
            (_users[r.submittedBy]?.fullName.toLowerCase().contains(query) ??
                false);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText:
                        'Search referrals by customer, email, ID, or affiliate...',
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
                const SizedBox(height: 12),

                // Filter Chips and Bulk Actions
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              [
                                    'All',
                                    ...ReferralStatus.values.map(
                                      (s) => s.displayName,
                                    ),
                                  ]
                                  .map(
                                    (filter) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: FilterChip(
                                        label: Text(filter),
                                        selected: _selectedFilter == filter,
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedFilter = filter;
                                            _selectedReferrals
                                                .clear(); // Clear selection when filter changes
                                          });
                                        },
                                        selectedColor: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                    if (_selectedReferrals.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _showBulkUpdateDialog,
                        icon: const Icon(Icons.edit),
                        label: Text('Update ${_selectedReferrals.length}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Referrals List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredReferrals.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadData,
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
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'All'
                ? 'No referrals found'
                : 'No $_selectedFilter referrals',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filter'
                : 'Referrals will appear here when submitted',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(ReferralModel referral) {
    final submitter = _users[referral.submittedBy];
    final isSelected = _selectedReferrals.contains(referral.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      color: isSelected
          ? Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showReferralDetails(referral),
        onLongPress: () => _toggleSelection(referral.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) => _toggleSelection(referral.id),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            referral.customer.fullName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'ID: ${referral.id.substring(0, 8)}...',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildStatusChip(referral.status),
                ],
              ),
              const SizedBox(height: 12),

              // Details Row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.person_outline,
                      'Affiliate',
                      submitter?.fullName ?? 'Unknown',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.speed,
                      'Package',
                      referral.selectedPackage.displayName,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.attach_money,
                      'Commission',
                      '\$${referral.commissionAmount.toStringAsFixed(2)}',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.calendar_today,
                      'Submitted',
                      _formatDate(referral.submittedAt),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showReferralDetails(referral),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showStatusUpdateDialog(referral),
                    icon: const Icon(Icons.edit),
                    label: const Text('Update Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
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

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
    final submitter = _users[referral.submittedBy];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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

                // Content
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
                          _buildDetailRow(
                            'Address',
                            referral.customer.fullAddress,
                          ),
                          if (referral.customer.notes != null)
                            _buildDetailRow('Notes', referral.customer.notes!),
                        ]),

                        const SizedBox(height: 20),
                        _buildDetailSection('Referral Information', [
                          _buildDetailRow('Referral ID', referral.id),
                          _buildDetailRow(
                            'Package',
                            referral.selectedPackage.displayName,
                          ),
                          _buildDetailRow(
                            'Commission',
                            '\$${referral.commissionAmount.toStringAsFixed(2)}',
                          ),
                          _buildDetailRow(
                            'Submitted By',
                            submitter?.fullName ?? 'Unknown',
                          ),
                          _buildDetailRow(
                            'Submitted',
                            _formatDate(referral.submittedAt),
                          ),
                          if (referral.approvedAt != null)
                            _buildDetailRow(
                              'Approved',
                              _formatDate(referral.approvedAt!),
                            ),
                          if (referral.installedAt != null)
                            _buildDetailRow(
                              'Installed',
                              _formatDate(referral.installedAt!),
                            ),
                          if (referral.paidAt != null)
                            _buildDetailRow(
                              'Paid',
                              _formatDate(referral.paidAt!),
                            ),
                        ]),

                        if (referral.adminNotes != null) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection('Admin Notes', [
                            Text(referral.adminNotes!),
                          ]),
                        ],

                        if (referral.rejectionReason != null) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection('Rejection Reason', [
                            Text(referral.rejectionReason!),
                          ]),
                        ],

                        if (referral.statusHistory.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection(
                            'Status History',
                            referral.statusHistory
                                .map(
                                  (history) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      history,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showStatusUpdateDialog(referral);
                        },
                        child: const Text('Update Status'),
                      ),
                    ),
                  ],
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(ReferralModel referral) {
    ReferralStatus selectedStatus = referral.status;
    final notesController = TextEditingController(
      text: referral.adminNotes ?? '',
    );
    final rejectionController = TextEditingController(
      text: referral.rejectionReason ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Update Referral Status',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  // Scrollable Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Customer Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer: ${referral.customer.fullName}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Current Status: ${referral.status.displayName}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Status Selection
                        Text(
                          'New Status:',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<ReferralStatus>(
                          value: selectedStatus,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          isExpanded: true,
                          items: ReferralStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedStatus = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Rejection Reason (conditional)
                        if (selectedStatus == ReferralStatus.rejected) ...[
                          Text(
                            'Rejection Reason:',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: rejectionController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter reason for rejection...',
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Admin Notes
                        Text(
                          'Admin Notes (Optional):',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: notesController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Add any additional notes...',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _updateReferralStatus(
                                  referral,
                                  selectedStatus,
                                  notesController.text.trim(),
                                  rejectionController.text.trim(),
                                ),
                                child: const Text('Update'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _updateReferralStatus(
    ReferralModel referral,
    ReferralStatus newStatus,
    String adminNotes,
    String rejectionReason,
  ) async {
    Navigator.of(context).pop(); // Close dialog

    try {
      await _referralService.updateReferralStatus(
        referralId: referral.id,
        newStatus: newStatus,
        notes: adminNotes.isEmpty ? null : adminNotes,
        rejectionReason:
            (newStatus == ReferralStatus.rejected && rejectionReason.isNotEmpty)
            ? rejectionReason
            : null,
      );

      // Refresh the data
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Referral status updated to ${newStatus.displayName}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleSelection(String referralId) {
    setState(() {
      if (_selectedReferrals.contains(referralId)) {
        _selectedReferrals.remove(referralId);
      } else {
        _selectedReferrals.add(referralId);
      }
    });
  }

  void _showBulkUpdateDialog() {
    ReferralStatus? selectedStatus;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: 450,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Bulk Update ${_selectedReferrals.length} Referrals',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Warning/Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This will update ${_selectedReferrals.length} selected referrals to the same status.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Status Selection
                        Text(
                          'New Status:',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<ReferralStatus>(
                          value: selectedStatus,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select new status',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          isExpanded: true,
                          items: ReferralStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedStatus = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // Admin Notes
                        Text(
                          'Admin Notes (Optional):',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: notesController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Add notes for all selected referrals...',
                          ),
                          maxLines: 3,
                          minLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedStatus != null
                              ? () => _performBulkUpdate(
                                  selectedStatus!,
                                  notesController.text.trim(),
                                )
                              : null,
                          child: Text(
                            'Update ${_selectedReferrals.length} Referrals',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _performBulkUpdate(
    ReferralStatus newStatus,
    String adminNotes,
  ) async {
    Navigator.of(context).pop(); // Close dialog

    final selectedIds = List<String>.from(_selectedReferrals);
    int successCount = 0;
    int errorCount = 0;

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Updating ${selectedIds.length} referrals...'),
          ],
        ),
      ),
    );

    // Update each referral
    for (final referralId in selectedIds) {
      try {
        await _referralService.updateReferralStatus(
          referralId: referralId,
          newStatus: newStatus,
          notes: adminNotes.isEmpty ? null : adminNotes,
        );
        successCount++;
      } catch (e) {
        errorCount++;
        debugPrint('Error updating referral $referralId: $e');
      }
    }

    // Close progress dialog
    if (mounted) {
      Navigator.of(context).pop();
    }

    // Clear selection and refresh data
    setState(() {
      _selectedReferrals.clear();
    });
    await _loadData();

    // Show result
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorCount == 0
                ? 'Successfully updated $successCount referrals'
                : 'Updated $successCount referrals, $errorCount failed',
          ),
          backgroundColor: errorCount == 0 ? Colors.green : Colors.orange,
        ),
      );
    }
  }
}

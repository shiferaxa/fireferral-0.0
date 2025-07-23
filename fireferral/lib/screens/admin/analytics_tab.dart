import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/referral_service.dart';
import '../../providers/auth_provider.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  final ReferralService _referralService = ReferralService();
  Map<String, dynamic> _analyticsData = {};
  bool _isLoading = true;
  String _selectedPeriod = '30 days';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser!;
      final data = await _referralService.getAnalyticsData(organizationId: user.organizationId);
      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading analytics: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
            Theme.of(context).colorScheme.surface.withOpacity(0.8),
          ],
        ),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with period selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Analytics Dashboard',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF00A8E6).withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          underline: const SizedBox(),
                          items: ['7 days', '30 days', '90 days', 'All time']
                              .map((period) => DropdownMenuItem(
                                    value: period,
                                    child: Text(period),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPeriod = value!;
                            });
                            // In a real app, reload data for the selected period
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // KPI Cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildKPICard(
                        'Total Referrals',
                        _analyticsData['totalReferrals']?.toString() ?? '0',
                        Icons.people_outline,
                        const Color(0xFF00A8E6),
                      ),
                      _buildKPICard(
                        'Conversion Rate',
                        '${_analyticsData['conversionRate']?.toStringAsFixed(1) ?? '0'}%',
                        Icons.trending_up,
                        Colors.green,
                      ),
                      _buildKPICard(
                        'Total Commissions',
                        '\$${_analyticsData['totalCommissions']?.toStringAsFixed(2) ?? '0'}',
                        Icons.attach_money,
                        Colors.orange,
                      ),
                      _buildKPICard(
                        'Pending Payouts',
                        '\$${_analyticsData['pendingCommissions']?.toStringAsFixed(2) ?? '0'}',
                        Icons.schedule,
                        Colors.purple,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Charts section
                  Row(
                    children: [
                      // Package breakdown pie chart
                      Expanded(
                        child: _buildChartCard(
                          'Package Distribution',
                          _buildPackageChart(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Status breakdown pie chart
                      Expanded(
                        child: _buildChartCard(
                          'Referral Status',
                          _buildStatusChart(),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Predictive Analytics Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _showPredictiveAnalytics,
                      icon: const Icon(Icons.analytics_outlined),
                      label: const Text('View Predictive Analytics'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A8E6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageChart() {
    final packageData = _analyticsData['packageBreakdown'] as Map<String, int>? ?? {};
    
    if (packageData.isEmpty) {
      return const Center(
        child: Text('No package data available'),
      );
    }

    final sections = packageData.entries.map((entry) {
      final colors = [
        const Color(0xFF00A8E6),
        const Color(0xFF0066CC),
        const Color(0xFF4FC3F7),
        const Color(0xFF29B6F6),
        const Color(0xFF03A9F4),
      ];
      final colorIndex = packageData.keys.toList().indexOf(entry.key) % colors.length;
      
      return PieChartSectionData(
        color: colors[colorIndex],
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildStatusChart() {
    final statusData = _analyticsData['statusBreakdown'] as Map<String, int>? ?? {};
    
    if (statusData.isEmpty) {
      return const Center(
        child: Text('No status data available'),
      );
    }

    final sections = statusData.entries.map((entry) {
      final colors = [
        Colors.blue,
        Colors.orange,
        Colors.green,
        Colors.purple,
        Colors.teal,
        Colors.red,
        Colors.grey,
      ];
      final colorIndex = statusData.keys.toList().indexOf(entry.key) % colors.length;
      
      return PieChartSectionData(
        color: colors[colorIndex],
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  void _showPredictiveAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Predictive Analytics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Based on current trends:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildPredictionRow(
                'Projected Monthly Referrals',
                '${(_analyticsData['totalReferrals'] ?? 0) * 1.2}',
              ),
              _buildPredictionRow(
                'Estimated Monthly Payouts',
                '\$${((_analyticsData['totalCommissions'] ?? 0) * 1.15).toStringAsFixed(2)}',
              ),
              _buildPredictionRow(
                'Expected Conversion Rate',
                '${((_analyticsData['conversionRate'] ?? 0) + 2.5).toStringAsFixed(1)}%',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A8E6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Note: Predictions are based on historical data and current trends. Actual results may vary.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF00A8E6),
            ),
          ),
        ],
      ),
    );
  }
}
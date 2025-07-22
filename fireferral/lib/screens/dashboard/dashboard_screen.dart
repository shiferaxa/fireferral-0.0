import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00A8E6), Color(0xFF0066CC)], // AT&T Blues
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00A8E6).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
            title: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Text(
                  themeProvider.getAppTitle(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                );
              },
            ),
            actions: [
              // Theme Toggle
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: Colors.white,
                      ),
                      onPressed: () => themeProvider.toggleDarkMode(),
                    ),
                  );
                },
              ),
              // Profile Menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      _showProfileDialog(user);
                      break;
                    case 'settings':
                      if (authProvider.isAdmin) {
                        _showSettingsDialog();
                      }
                      break;
                    case 'logout':
                      _handleLogout();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (authProvider.isAdmin)
                    const PopupMenuItem(
                      value: 'settings',
                      child: ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Settings'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          user.firstName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.firstName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            user.role.name.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: _buildBody(user),
          bottomNavigationBar: _buildBottomNavigation(user),
        );
      },
    );
  }

  Widget _buildBody(UserModel user) {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab(user);
      case 1:
        return _buildReferralsTab(user);
      case 2:
        return _buildSubmitTab(user);
      case 3:
        if (user.role == UserRole.admin) {
          return _buildAdminTab();
        } else if (user.role == UserRole.associate) {
          return _buildTeamTab();
        } else {
          return _buildProfileTab(user);
        }
      default:
        return _buildDashboardTab(user);
    }
  }

  Widget _buildBottomNavigation(UserModel user) {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.list),
        label: 'Referrals',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.add_circle),
        label: 'Submit',
      ),
    ];

    // Add role-specific tab
    if (user.role == UserRole.admin) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.admin_panel_settings),
        label: 'Admin',
      ));
    } else if (user.role == UserRole.associate) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.group),
        label: 'Team',
      ));
    } else {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ));
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: items,
      ),
    );
  }

  Widget _buildDashboardTab(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withOpacity(0.8),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header with Avatar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00A8E6), Color(0xFF0066CC)], // AT&T Blues
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00A8E6).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        user.firstName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          user.firstName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.role.name.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.notifications_outlined,
                    color: Colors.white.withOpacity(0.8),
                    size: 28,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Stats Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildModernStatCard(
                  'Total Referrals',
                  '12',
                  Icons.people_outline,
                  const Color(0xFF00A8E6), // AT&T Blue
                  const Color(0xFF0066CC), // AT&T Dark Blue
                ),
                _buildModernStatCard(
                  'This Month',
                  '3',
                  Icons.calendar_today_outlined,
                  const Color(0xFFFF6900), // AT&T Orange
                  const Color(0xFFFF8A50), // Light Orange
                ),
                _buildModernStatCard(
                  'Conversion Rate',
                  '75%',
                  Icons.trending_up_outlined,
                  const Color(0xFF4FC3F7), // AT&T Light Blue
                  const Color(0xFF00A8E6), // AT&T Blue
                ),
                _buildModernStatCard(
                  'Total Earnings',
                  '\$1,250',
                  Icons.attach_money_outlined,
                  const Color(0xFF00C853), // Success Green
                  const Color(0xFF4CAF50), // Light Green
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Recent Activity Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Recent Activity',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timeline_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Recent referrals will appear here',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStatCard(String title, String value, IconData icon, Color startColor, Color endColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Add tap animation or navigation
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Icon(
                      Icons.arrow_upward,
                      color: Colors.white.withOpacity(0.8),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReferralsTab(UserModel user) {
    return const Center(
      child: Text('Referrals Tab - Coming Soon'),
    );
  }

  Widget _buildSubmitTab(UserModel user) {
    return const Center(
      child: Text('Submit Referral Tab - Coming Soon'),
    );
  }

  Widget _buildAdminTab() {
    return const Center(
      child: Text('Admin Panel - Coming Soon'),
    );
  }

  Widget _buildTeamTab() {
    return const Center(
      child: Text('Team Management - Coming Soon'),
    );
  }

  Widget _buildProfileTab(UserModel user) {
    return const Center(
      child: Text('Profile Tab - Coming Soon'),
    );
  }

  void _showProfileDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user.fullName}'),
            Text('Email: ${user.email}'),
            Text('Role: ${user.role.name.toUpperCase()}'),
            Text('Member since: ${user.createdAt.toString().split(' ')[0]}'),
          ],
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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings panel coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../themes/app_themes.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _companyNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _companyNameController.text = themeProvider.companyName ?? '';
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Branding Section
            _buildSection(
              'App Branding',
              [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Company Name',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _companyNameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter your company name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _updateCompanyName,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Update Company Name'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Theme Preview Section
            _buildSection(
              'Theme Preview',
              [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Theme: ${AppThemes.getThemeName(themeProvider.currentTheme)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _testAllThemes(themeProvider),
                              child: const Text('Test All Themes'),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Primary',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Secondary',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.tertiary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Tertiary',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onTertiary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Theme Settings Section
            _buildSection(
              'Theme Settings',
              [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Card(
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Dark Mode'),
                            subtitle: const Text('Toggle between light and dark theme'),
                            value: themeProvider.isDarkMode,
                            onChanged: (value) => themeProvider.setDarkMode(value),
                            secondary: Icon(
                              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                            ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'App Theme',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...themeProvider.getAvailableThemes().map((theme) {
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    elevation: theme['isSelected'] ? 4 : 1,
                                    color: theme['isSelected'] 
                                        ? Theme.of(context).colorScheme.primaryContainer
                                        : null,
                                    child: RadioListTile<AppThemeType>(
                                      title: Text(
                                        theme['name'],
                                        style: TextStyle(
                                          fontWeight: theme['isSelected'] 
                                              ? FontWeight.bold 
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      subtitle: Text(_getThemeDescription(theme['type'])),
                                      value: theme['type'],
                                      groupValue: themeProvider.currentTheme,
                                      onChanged: (AppThemeType? value) {
                                        if (value != null) {
                                          themeProvider.setTheme(value);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Theme changed to ${theme['name']}'),
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        }
                                      },
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                      secondary: _getThemeIcon(theme['type']),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Account Settings Section
            _buildSection(
              'Account Settings',
              [
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final user = authProvider.currentUser;
                    if (user == null) return const SizedBox.shrink();
                    
                    return Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text('Profile Information'),
                            subtitle: Text('${user.fullName} (${user.email})'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const EditProfileScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.security),
                            title: const Text('Change Password'),
                            subtitle: const Text('Update your account password'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ChangePasswordScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // App Information Section
            _buildSection(
              'App Information',
              [
                Card(
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.info),
                        title: Text('Version'),
                        subtitle: Text('1.0.0+1'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text('Help & Support'),
                        subtitle: const Text('Get help with using the app'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Help & Support coming soon'),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip),
                        title: const Text('Privacy Policy'),
                        subtitle: const Text('View our privacy policy'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Privacy Policy coming soon'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Future<void> _updateCompanyName() async {
    if (_companyNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a company name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.setCompanyBranding(
        companyName: _companyNameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company name updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating company name: $e'),
            backgroundColor: Colors.red,
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

  String _getThemeDescription(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.corporate:
        return 'Professional blue theme for business use';
      case AppThemeType.modern:
        return 'Contemporary purple theme with rounded corners';
      case AppThemeType.minimal:
        return 'Clean and simple gray theme';
      case AppThemeType.vibrant:
        return 'Colorful red theme with high contrast';
      case AppThemeType.classic:
        return 'Traditional navy theme with gold accents';
    }
  }

  Widget _getThemeIcon(AppThemeType theme) {
    Color iconColor;
    IconData iconData;
    
    switch (theme) {
      case AppThemeType.corporate:
        iconColor = const Color(0xFF00A8E6);
        iconData = Icons.business;
        break;
      case AppThemeType.modern:
        iconColor = const Color(0xFF8B5CF6);
        iconData = Icons.auto_awesome;
        break;
      case AppThemeType.minimal:
        iconColor = const Color(0xFF374151);
        iconData = Icons.minimize;
        break;
      case AppThemeType.vibrant:
        iconColor = const Color(0xFFEF4444);
        iconData = Icons.colorize;
        break;
      case AppThemeType.classic:
        iconColor = const Color(0xFF1E3A8A);
        iconData = Icons.account_balance;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  void _testAllThemes(ThemeProvider themeProvider) async {
    final themes = AppThemeType.values;
    final originalTheme = themeProvider.currentTheme;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Testing all themes...'),
        duration: Duration(seconds: 1),
      ),
    );
    
    for (int i = 0; i < themes.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        themeProvider.setTheme(themes[i]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme: ${AppThemes.getThemeName(themes[i])}'),
            duration: const Duration(milliseconds: 600),
          ),
        );
      }
    }
    
    // Return to original theme
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      themeProvider.setTheme(originalTheme);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Theme test complete!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}
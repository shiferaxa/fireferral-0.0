import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

class AppStateService {
  static AppStateService? _instance;
  static AppStateService get instance => _instance ??= AppStateService._();
  
  AppStateService._();
  
  ThemeProvider? _themeProvider;
  AuthProvider? _authProvider;
  String? _lastOrganizationId;
  
  void initialize(ThemeProvider themeProvider, AuthProvider authProvider) {
    _themeProvider = themeProvider;
    _authProvider = authProvider;
    
    // Listen to auth changes
    authProvider.addListener(_onAuthChanged);
  }
  
  void _onAuthChanged() {
    final currentUser = _authProvider?.currentUser;
    final currentOrgId = currentUser?.organizationId;
    
    // Only update if organization changed
    if (_lastOrganizationId != currentOrgId) {
      _lastOrganizationId = currentOrgId;
      
      if (currentOrgId != null && _themeProvider != null) {
        // Load organization settings
        _themeProvider!.loadOrganizationSettings(currentOrgId);
      } else if (_themeProvider != null) {
        // Clear settings when logged out
        _themeProvider!.clearSettings();
      }
    }
  }
  
  void dispose() {
    _authProvider?.removeListener(_onAuthChanged);
    _themeProvider = null;
    _authProvider = null;
    _lastOrganizationId = null;
  }
}
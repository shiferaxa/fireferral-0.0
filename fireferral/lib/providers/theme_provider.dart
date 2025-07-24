import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../themes/app_themes.dart';

class ThemeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  AppThemeType _currentTheme = AppThemeType.corporate;
  bool _isDarkMode = false;
  String? _companyName;
  String? _companyLogo;
  String? _currentOrganizationId;

  AppThemeType get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;
  String? get companyName => _companyName;
  String? get companyLogo => _companyLogo;

  ThemeProvider() {
    _loadThemePreferences();
  }

  Future<void> _loadThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme type
      final themeIndex = prefs.getInt('theme_type') ?? 0;
      if (themeIndex < AppThemeType.values.length) {
        _currentTheme = AppThemeType.values[themeIndex];
      }
      debugPrint('🎨 Loaded theme from preferences: ${_currentTheme.name} (index: $themeIndex)');
      
      // Load dark mode preference
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false; // Changed default to false (light mode)
      debugPrint('🎨 Loaded dark mode from preferences: $_isDarkMode');
      
      // Load company branding
      _companyName = prefs.getString('company_name');
      _companyLogo = prefs.getString('company_logo');
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
    }
  }

  Future<void> setTheme(AppThemeType theme) async {
    if (_currentTheme != theme) {
      debugPrint('🎨 Changing theme from ${_currentTheme.name} to ${theme.name}');
      _currentTheme = theme;
      notifyListeners();
      
      // Save to local preferences for quick loading
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('theme_type', theme.index);
        debugPrint('🎨 Theme saved to preferences: ${theme.index}');
      } catch (e) {
        debugPrint('Error saving theme preference: $e');
      }
      
      // Save to Firestore for organization-specific settings
      if (_currentOrganizationId != null) {
        try {
          await _firestore.collection('organization_settings').doc(_currentOrganizationId!).set({
            'themeType': theme.index,
            'updatedAt': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('Error saving theme to Firestore: $e');
        }
      }
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
      
      // Save to local preferences for quick loading
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_dark_mode', isDark);
      } catch (e) {
        debugPrint('Error saving dark mode preference: $e');
      }
      
      // Save to Firestore for organization-specific settings
      if (_currentOrganizationId != null) {
        try {
          await _firestore.collection('organization_settings').doc(_currentOrganizationId!).set({
            'isDarkMode': isDark,
            'updatedAt': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('Error saving dark mode to Firestore: $e');
        }
      }
    }
  }

  Future<void> toggleDarkMode() async {
    await setDarkMode(!_isDarkMode);
  }

  // Load organization-specific settings
  Future<void> loadOrganizationSettings(String organizationId) async {
    if (_currentOrganizationId == organizationId) return; // Already loaded
    
    _currentOrganizationId = organizationId;
    
    try {
      final doc = await _firestore.collection('organization_settings').doc(organizationId).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        _companyName = data['companyName'];
        _companyLogo = data['companyLogo'];
        
        // Load theme settings if available
        if (data['themeType'] != null) {
          final themeIndex = data['themeType'] as int;
          if (themeIndex < AppThemeType.values.length) {
            _currentTheme = AppThemeType.values[themeIndex];
          }
        }
        
        if (data['isDarkMode'] != null) {
          _isDarkMode = data['isDarkMode'] as bool;
        }
      } else {
        // No settings found, use defaults
        _companyName = null;
        _companyLogo = null;
        _currentTheme = AppThemeType.corporate;
        _isDarkMode = false;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading organization settings: $e');
    }
  }

  Future<void> setCompanyBranding({
    String? companyName,
    String? companyLogo,
  }) async {
    if (_currentOrganizationId == null) {
      debugPrint('Warning: Cannot save company branding without organization ID');
      return;
    }
    
    bool changed = false;
    
    if (companyName != null && _companyName != companyName) {
      _companyName = companyName;
      changed = true;
    }
    
    if (companyLogo != null && _companyLogo != companyLogo) {
      _companyLogo = companyLogo;
      changed = true;
    }
    
    if (changed) {
      notifyListeners();
      
      try {
        final Map<String, dynamic> updateData = {};
        if (companyName != null) {
          updateData['companyName'] = companyName;
        }
        if (companyLogo != null) {
          updateData['companyLogo'] = companyLogo;
        }
        updateData['updatedAt'] = DateTime.now().toIso8601String();
        
        await _firestore.collection('organization_settings').doc(_currentOrganizationId!).set(
          updateData,
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('Error saving company branding: $e');
      }
    }
  }

  Future<void> clearCompanyBranding() async {
    if (_currentOrganizationId == null) return;
    
    _companyName = null;
    _companyLogo = null;
    notifyListeners();
    
    try {
      await _firestore.collection('organization_settings').doc(_currentOrganizationId!).update({
        'companyName': FieldValue.delete(),
        'companyLogo': FieldValue.delete(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error clearing company branding: $e');
    }
  }

  // Clear settings when user logs out or switches organizations
  void clearSettings() {
    _currentOrganizationId = null;
    _companyName = null;
    _companyLogo = null;
    _currentTheme = AppThemeType.corporate;
    _isDarkMode = false;
    notifyListeners();
  }

  String getAppTitle() {
    return _companyName ?? 'Fireferral';
  }

  // Get all available themes for admin selection
  List<Map<String, dynamic>> getAvailableThemes() {
    return AppThemeType.values.map((theme) => {
      'type': theme,
      'name': AppThemes.getThemeName(theme),
      'isSelected': theme == _currentTheme,
    }).toList();
  }
}
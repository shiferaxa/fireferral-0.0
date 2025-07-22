import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_themes.dart';

class ThemeProvider extends ChangeNotifier {
  AppThemeType _currentTheme = AppThemeType.corporate;
  bool _isDarkMode = false;
  String? _companyName;
  String? _companyLogo;

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
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('theme_type', theme.index);
        debugPrint('🎨 Theme saved to preferences: ${theme.index}');
      } catch (e) {
        debugPrint('Error saving theme preference: $e');
      }
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_dark_mode', isDark);
      } catch (e) {
        debugPrint('Error saving dark mode preference: $e');
      }
    }
  }

  Future<void> toggleDarkMode() async {
    await setDarkMode(!_isDarkMode);
  }

  Future<void> setCompanyBranding({
    String? companyName,
    String? companyLogo,
  }) async {
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
        final prefs = await SharedPreferences.getInstance();
        if (companyName != null) {
          await prefs.setString('company_name', companyName);
        }
        if (companyLogo != null) {
          await prefs.setString('company_logo', companyLogo);
        }
      } catch (e) {
        debugPrint('Error saving company branding: $e');
      }
    }
  }

  Future<void> clearCompanyBranding() async {
    _companyName = null;
    _companyLogo = null;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('company_name');
      await prefs.remove('company_logo');
    } catch (e) {
      debugPrint('Error clearing company branding: $e');
    }
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
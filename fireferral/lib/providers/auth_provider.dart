import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;
  AuthService get authService => _authService;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        try {
          _currentUser = await _authService.getUserData(user.uid);
          _errorMessage = null;
        } catch (e) {
          _errorMessage = e.toString();
          _currentUser = null;
        }
      } else {
        _currentUser = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signInWithEmailAndPassword(email, password);
      
      if (_currentUser != null) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Sign in failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    // Temporarily disable Google Sign-In on iOS to prevent crashes
    if (Platform.isIOS) {
      _errorMessage = 'Google Sign-In is temporarily disabled on iOS. Please use email/password login.';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signInWithGoogle();
      
      if (_currentUser != null) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Google sign in failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Google sign-up is disabled - property accounts must be created by Invision admin
  
  // Create property account (Invision admin only)
  Future<bool> createPropertyAccount({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String propertyName,
    String? propertyAddress,
    String? phone,
  }) async {
    try {
      _errorMessage = null;
      
      final newUser = await _authService.createPropertyAccount(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        propertyName: propertyName,
        propertyAddress: propertyAddress,
        phone: phone,
      );
      
      if (newUser != null) {
        return true;
      } else {
        _errorMessage = 'Property account creation failed';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> hasInvisionAdmin() async {
    try {
      return await _authService.hasInvisionAdmin();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _errorMessage = null;
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshUserData() async {
    if (_currentUser != null) {
      try {
        _currentUser = await _authService.getUserData(_currentUser!.id);
        notifyListeners();
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  // Helper methods for role checking
  bool get isInvisionAdmin => _currentUser?.role == UserRole.invisionAdmin;
  bool get isProperty => _currentUser?.role == UserRole.property;
  
  // Only Invision admin has these permissions
  bool canManageProperties() => isInvisionAdmin;
  bool canViewAllReferrals() => isInvisionAdmin;
  bool canViewStatistics() => isInvisionAdmin;
  bool canUpdateCommissions() => isInvisionAdmin;
  
  // For backward compatibility (will be removed)
  bool get isAdmin => isInvisionAdmin;
}
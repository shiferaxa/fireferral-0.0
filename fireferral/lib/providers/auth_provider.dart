import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<bool> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    required String organizationId,
    String? associateId,
  }) async {
    try {
      _errorMessage = null;
      
      final newUser = await _authService.createUserAccount(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
        organizationId: organizationId,
        associateId: associateId,
      );
      
      if (newUser != null) {
        return true;
      } else {
        _errorMessage = 'User creation failed';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createFirstAdmin({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String organizationId,
  }) async {
    try {
      _errorMessage = null;
      
      final newUser = await _authService.createFirstAdminAccount(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        organizationId: organizationId,
      );
      
      if (newUser != null) {
        return true;
      } else {
        _errorMessage = 'Admin creation failed';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> hasAdminUser() async {
    try {
      return await _authService.hasAdminUser();
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
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isAssociate => _currentUser?.role == UserRole.associate;
  bool get isAffiliate => _currentUser?.role == UserRole.affiliate;
  
  bool canManageUsers() => isAdmin;
  bool canManageAffiliates() => isAdmin || isAssociate;
  bool canViewAllReferrals() => isAdmin;
  bool canUpdateCommissions() => isAdmin;
}
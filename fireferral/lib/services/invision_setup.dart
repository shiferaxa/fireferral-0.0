import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Service to set up the single Invision admin account
/// This should only be run once during initial setup
class InvisionSetupService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create the single Invision admin account
  /// This is the only admin account that will exist in the system
  Future<UserModel?> createInvisionAdminAccount({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // Check if Invision admin already exists
      final hasAdmin = await _hasInvisionAdmin();
      
      if (hasAdmin) {
        throw Exception('Invision admin account already exists. Only one admin account is allowed.');
      }

      // Create Firebase Auth user
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Create user model
        final userModel = UserModel(
          id: result.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          role: UserRole.invisionAdmin,
          createdAt: DateTime.now(),
        );

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(userModel.toMap());

        // Create a system config document to mark that admin has been created
        await _firestore.collection('system_config').doc('invision').set({
          'adminCreated': true,
          'adminId': result.user!.uid,
          'createdAt': DateTime.now().toIso8601String(),
        });

        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to create Invision admin: ${e.toString()}');
    }
  }

  /// Check if Invision admin account exists
  Future<bool> _hasInvisionAdmin() async {
    try {
      // Check system config first (faster)
      final configDoc = await _firestore
          .collection('system_config')
          .doc('invision')
          .get();
      
      if (configDoc.exists && configDoc.data()?['adminCreated'] == true) {
        return true;
      }

      // Fallback: check users collection
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: UserRole.invisionAdmin.name)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      // If we can't check, assume no admin exists to allow setup
      return false;
    }
  }

  /// Get the Invision admin user
  Future<UserModel?> getInvisionAdmin() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: UserRole.invisionAdmin.name)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get Invision admin: ${e.toString()}');
    }
  }

  /// Check if the system is ready (admin account exists)
  Future<bool> isSystemReady() async {
    return await _hasInvisionAdmin();
  }
}

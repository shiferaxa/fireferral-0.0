import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Update last login time
        await _firestore.collection('users').doc(result.user!.uid).update({
          'lastLoginAt': DateTime.now().toIso8601String(),
        });

        // Get user data
        return await getUserData(result.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      if (result.user != null) {
        // Check if user exists in our database
        final existingUser = await getUserData(result.user!.uid);

        if (existingUser != null) {
          // Update last login time
          await _firestore.collection('users').doc(result.user!.uid).update({
            'lastLoginAt': DateTime.now().toIso8601String(),
          });
          return existingUser;
        } else {
          // This is a new Google user, they need to complete organization setup
          // We'll return null to indicate they need to go through the signup flow
          await _auth.signOut();
          await _googleSignIn.signOut();
          throw Exception(
            'Account not found. Please complete the signup process first.',
          );
        }
      }
      return null;
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  // Note: Google sign-up is disabled. Property accounts must be created by Invision admin.

  // Create property account (Invision Admin only)
  Future<UserModel?> createPropertyAccount({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String propertyName,
    String? propertyAddress,
    String? phone,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        final userModel = UserModel(
          id: result.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          role: UserRole.property,
          propertyName: propertyName,
          propertyAddress: propertyAddress,
          phone: phone,
          createdAt: DateTime.now(),
        );

        // Save user data to Firestore
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(userModel.toMap());

        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Property account creation failed: ${e.toString()}');
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user data: ${e.toString()}');
    }
  }

  // Get all property accounts
  Future<List<UserModel>> getAllProperties() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: UserRole.property.name)
          .where('isActive', isEqualTo: true)
          .orderBy('propertyName')
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get properties: ${e.toString()}');
    }
  }

  // Search properties by name
  Future<List<UserModel>> searchProperties(String searchTerm) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: UserRole.property.name)
          .where('isActive', isEqualTo: true)
          .get();

      // Filter by property name (Firestore doesn't support case-insensitive search)
      final properties = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) => 
              user.propertyName?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false)
          .toList();

      return properties;
    } catch (e) {
      throw Exception('Failed to search properties: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Deactivate user account
  Future<void> deactivateUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({'isActive': false});
    } catch (e) {
      throw Exception('Failed to deactivate user: ${e.toString()}');
    }
  }

  // Reactivate user account
  Future<void> reactivateUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({'isActive': true});
    } catch (e) {
      throw Exception('Failed to reactivate user: ${e.toString()}');
    }
  }

  // Check if Invision admin exists
  Future<bool> hasInvisionAdmin() async {
    try {
      // Check system config first
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
      return false;
    }
  }
}

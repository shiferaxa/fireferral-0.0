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

  // Sign up with Google (for new users)
  Future<UserModel?> signUpWithGoogle({
    required String firstName,
    required String lastName,
    required UserRole role,
    required String organizationId,
    String? associateId,
  }) async {
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
        // Check if user already exists
        final existingUser = await getUserData(result.user!.uid);

        if (existingUser != null) {
          throw Exception(
            'Account already exists. Please use sign in instead.',
          );
        }

        // Create new user record
        final userModel = UserModel(
          id: result.user!.uid,
          email: result.user!.email!,
          firstName: firstName,
          lastName: lastName,
          role: role,
          organizationId: organizationId,
          associateId: associateId,
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
      throw Exception('Google sign up failed: ${e.toString()}');
    }
  }

  // Create user account (Admin only)
  Future<UserModel?> createUserAccount({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    required String organizationId,
    String? associateId,
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
          role: role,
          organizationId: organizationId,
          associateId: associateId,
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
      throw Exception('Account creation failed: ${e.toString()}');
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

  // Get users by role within organization
  Future<List<UserModel>> getUsersByRole(
    UserRole role,
    String organizationId,
  ) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role.name)
          .where('organizationId', isEqualTo: organizationId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get users: ${e.toString()}');
    }
  }

  // Get affiliates by associate within organization
  Future<List<UserModel>> getAffiliatesByAssociate(
    String associateId,
    String organizationId,
  ) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: UserRole.affiliate.name)
          .where('associateId', isEqualTo: associateId)
          .where('organizationId', isEqualTo: organizationId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get affiliates: ${e.toString()}');
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

  // Check if any admin exists (for initial setup)
  Future<bool> hasAdminUser() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: UserRole.admin.name)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      final hasAdmin = snapshot.docs.isNotEmpty;
      return hasAdmin;
    } catch (e) {
      // If we can't check, assume no admin exists to allow signup
      return false;
    }
  }

  // Create first admin account (no authentication required)
  Future<UserModel?> createFirstAdminAccount({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String organizationId,
  }) async {
    try {
      // Check if admin already exists
      final hasAdmin = await hasAdminUser();

      if (hasAdmin) {
        throw Exception('Admin account already exists');
      }

      final result = await createUserAccount(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: UserRole.admin,
        organizationId: organizationId,
      );

      return result;
    } catch (e) {
      throw Exception('Failed to create first admin: ${e.toString()}');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fiber_package.dart';
import 'auth_service.dart';

class PackageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final AuthService _authService = AuthService();

  // Get packages for current organization
  static Future<List<FiberPackage>> getPackages() async {
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final organizationId = userDoc.data()?['organizationId'] as String?;
      
      if (organizationId == null) throw Exception('User not associated with organization');

      final packagesDoc = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('settings')
          .doc('packages')
          .get();

      if (packagesDoc.exists) {
        final data = packagesDoc.data()!;
        final packagesData = data['packages'] as List<dynamic>? ?? [];
        return packagesData
            .map((packageData) => FiberPackage.fromMap(packageData as Map<String, dynamic>))
            .toList();
      } else {
        // Return default packages if none exist
        return FiberPackage.getDefaultPackages();
      }
    } catch (e) {
      print('Error loading packages: $e');
      // Return default packages on error
      return FiberPackage.getDefaultPackages();
    }
  }

  // Save packages for current organization
  static Future<void> savePackages(List<FiberPackage> packages) async {
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final organizationId = userDoc.data()?['organizationId'] as String?;
      
      if (organizationId == null) throw Exception('User not associated with organization');

      final packagesData = packages.map((package) => package.toMap()).toList();

      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('settings')
          .doc('packages')
          .set({
        'packages': packagesData,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': user.uid,
      });
    } catch (e) {
      print('Error saving packages: $e');
      rethrow;
    }
  }

  // Get a specific package by speed
  static Future<FiberPackage?> getPackageBySpeed(FiberSpeed speed) async {
    final packages = await getPackages();
    try {
      return packages.firstWhere((package) => package.speed == speed);
    } catch (e) {
      return null;
    }
  }
}
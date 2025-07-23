import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/organization_model.dart';

class OrganizationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Create a new organization
  Future<OrganizationModel> createOrganization({
    required String name,
    required String createdBy,
    String? description,
    String? website,
    String? phone,
    String? email,
    String? address,
  }) async {
    try {
      final String orgId = _uuid.v4();
      
      final organization = OrganizationModel(
        id: orgId,
        name: name,
        description: description,
        website: website,
        phone: phone,
        email: email,
        address: address,
        createdAt: DateTime.now(),
        createdBy: createdBy,
      );

      await _firestore.collection('organizations').doc(orgId).set(organization.toMap());
      
      return organization;
    } catch (e) {
      throw Exception('Failed to create organization: ${e.toString()}');
    }
  }

  // Get organization by ID
  Future<OrganizationModel?> getOrganizationById(String orgId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('organizations').doc(orgId).get();
      if (doc.exists) {
        return OrganizationModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get organization: ${e.toString()}');
    }
  }

  // Update organization
  Future<void> updateOrganization(String orgId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('organizations').doc(orgId).update(data);
    } catch (e) {
      throw Exception('Failed to update organization: ${e.toString()}');
    }
  }

  // Check if organization name is available
  Future<bool> isOrganizationNameAvailable(String name) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('organizations')
          .where('name', isEqualTo: name)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      return snapshot.docs.isEmpty;
    } catch (e) {
      throw Exception('Failed to check organization name: ${e.toString()}');
    }
  }

  // Get all organizations (super admin only)
  Future<List<OrganizationModel>> getAllOrganizations() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('organizations')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => OrganizationModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get organizations: ${e.toString()}');
    }
  }

  // Deactivate organization
  Future<void> deactivateOrganization(String orgId) async {
    try {
      await _firestore.collection('organizations').doc(orgId).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Failed to deactivate organization: ${e.toString()}');
    }
  }
}
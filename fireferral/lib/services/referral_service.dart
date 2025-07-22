import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/referral_model.dart';

import '../models/fiber_package.dart';

class ReferralService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Submit new referral
  Future<String> submitReferral({
    required String submittedBy,
    required CustomerInfo customer,
    required FiberSpeed selectedPackage,
    required double commissionAmount,
    String? notes,
  }) async {
    try {
      final String referralId = _uuid.v4();
      
      final referral = ReferralModel(
        id: referralId,
        submittedBy: submittedBy,
        customer: customer,
        selectedPackage: selectedPackage,
        commissionAmount: commissionAmount,
        status: ReferralStatus.submitted,
        submittedAt: DateTime.now(),
        statusHistory: ['${DateTime.now().toIso8601String()}: Referral submitted'],
      );

      await _firestore.collection('referrals').doc(referralId).set(referral.toMap());
      
      return referralId;
    } catch (e) {
      throw Exception('Failed to submit referral: ${e.toString()}');
    }
  }

  // Get referrals by user
  Future<List<ReferralModel>> getReferralsByUser(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('referrals')
          .where('submittedBy', isEqualTo: userId)
          .orderBy('submittedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => ReferralModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get referrals: ${e.toString()}');
    }
  }

  // Get all referrals (Admin only)
  Future<List<ReferralModel>> getAllReferrals() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('referrals')
          .orderBy('submittedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => ReferralModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get all referrals: ${e.toString()}');
    }
  }

  // Get referrals by associate's affiliates
  Future<List<ReferralModel>> getReferralsByAssociateTeam(String associateId, List<String> affiliateIds) async {
    try {
      if (affiliateIds.isEmpty) return [];
      
      final QuerySnapshot snapshot = await _firestore
          .collection('referrals')
          .where('submittedBy', whereIn: affiliateIds)
          .orderBy('submittedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => ReferralModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get team referrals: ${e.toString()}');
    }
  }

  // Update referral status
  Future<void> updateReferralStatus({
    required String referralId,
    required ReferralStatus newStatus,
    String? notes,
    String? rejectionReason,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'status': newStatus.name,
      };

      // Add timestamp fields based on status
      switch (newStatus) {
        case ReferralStatus.approved:
          updateData['approvedAt'] = DateTime.now().toIso8601String();
          break;
        case ReferralStatus.installed:
          updateData['installedAt'] = DateTime.now().toIso8601String();
          break;
        case ReferralStatus.paid:
          updateData['paidAt'] = DateTime.now().toIso8601String();
          break;
        case ReferralStatus.rejected:
          if (rejectionReason != null) {
            updateData['rejectionReason'] = rejectionReason;
          }
          break;
        default:
          break;
      }

      if (notes != null) {
        updateData['adminNotes'] = notes;
      }

      // Add to status history
      final String historyEntry = '${DateTime.now().toIso8601String()}: Status changed to ${newStatus.displayName}';
      updateData['statusHistory'] = FieldValue.arrayUnion([historyEntry]);

      await _firestore.collection('referrals').doc(referralId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update referral status: ${e.toString()}');
    }
  }

  // Get referral by ID
  Future<ReferralModel?> getReferralById(String referralId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('referrals').doc(referralId).get();
      if (doc.exists) {
        return ReferralModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get referral: ${e.toString()}');
    }
  }

  // Get referrals by status
  Future<List<ReferralModel>> getReferralsByStatus(ReferralStatus status) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('referrals')
          .where('status', isEqualTo: status.name)
          .orderBy('submittedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => ReferralModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get referrals by status: ${e.toString()}');
    }
  }

  // Get referrals in date range
  Future<List<ReferralModel>> getReferralsInDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  }) async {
    try {
      Query query = _firestore.collection('referrals')
          .where('submittedAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('submittedAt', isLessThanOrEqualTo: endDate.toIso8601String());

      if (userId != null) {
        query = query.where('submittedBy', isEqualTo: userId);
      }

      final QuerySnapshot snapshot = await query.orderBy('submittedAt', descending: true).get();

      return snapshot.docs.map((doc) => ReferralModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get referrals in date range: ${e.toString()}');
    }
  }

  // Get analytics data
  Future<Map<String, dynamic>> getAnalyticsData({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
  }) async {
    try {
      List<ReferralModel> referrals;
      
      if (startDate != null && endDate != null) {
        referrals = await getReferralsInDateRange(
          startDate: startDate,
          endDate: endDate,
          userId: userId,
        );
      } else if (userId != null) {
        referrals = await getReferralsByUser(userId);
      } else {
        referrals = await getAllReferrals();
      }

      final totalReferrals = referrals.length;
      final installedReferrals = referrals.where((r) => r.status == ReferralStatus.installed || r.status == ReferralStatus.paid).length;
      final paidReferrals = referrals.where((r) => r.status == ReferralStatus.paid).length;
      final rejectedReferrals = referrals.where((r) => r.status == ReferralStatus.rejected).length;
      
      final double conversionRate = totalReferrals > 0 ? (installedReferrals / totalReferrals) * 100 : 0.0;
      final double totalCommissions = referrals.where((r) => r.isPaid).fold(0.0, (total, r) => total + r.commissionAmount);
      final double pendingCommissions = referrals.where((r) => r.status == ReferralStatus.installed).fold(0.0, (total, r) => total + r.commissionAmount);

      // Package breakdown
      final Map<String, int> packageBreakdown = {};
      for (final referral in referrals) {
        final packageName = referral.selectedPackage.displayName;
        packageBreakdown[packageName] = (packageBreakdown[packageName] ?? 0) + 1;
      }

      // Status breakdown
      final Map<String, int> statusBreakdown = {};
      for (final referral in referrals) {
        final statusName = referral.status.displayName;
        statusBreakdown[statusName] = (statusBreakdown[statusName] ?? 0) + 1;
      }

      return {
        'totalReferrals': totalReferrals,
        'installedReferrals': installedReferrals,
        'paidReferrals': paidReferrals,
        'rejectedReferrals': rejectedReferrals,
        'conversionRate': conversionRate,
        'totalCommissions': totalCommissions,
        'pendingCommissions': pendingCommissions,
        'packageBreakdown': packageBreakdown,
        'statusBreakdown': statusBreakdown,
        'averageDaysInPipeline': referrals.isNotEmpty 
            ? referrals.map((r) => r.daysInPipeline).reduce((a, b) => a + b) / referrals.length 
            : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get analytics data: ${e.toString()}');
    }
  }

  // Stream referrals for real-time updates
  Stream<List<ReferralModel>> streamReferralsByUser(String userId) {
    return _firestore
        .collection('referrals')
        .where('submittedBy', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ReferralModel.fromFirestore(doc)).toList());
  }

  Stream<List<ReferralModel>> streamAllReferrals() {
    return _firestore
        .collection('referrals')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ReferralModel.fromFirestore(doc)).toList());
  }
}
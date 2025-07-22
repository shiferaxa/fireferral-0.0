import 'package:cloud_firestore/cloud_firestore.dart';
import 'fiber_package.dart';

enum ReferralStatus {
  submitted('Submitted', 'Just submitted by affiliate'),
  underReview('Under Review', 'Being reviewed by admin/associate'),
  approved('Approved', 'Approved for installation'),
  scheduled('Scheduled', 'Installation scheduled'),
  installed('Installed', 'Service installed and active'),
  paid('Paid', 'Commission paid out'),
  rejected('Rejected', 'Referral rejected'),
  cancelled('Cancelled', 'Customer cancelled');

  const ReferralStatus(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

class CustomerInfo {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String? notes;

  CustomerInfo({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    this.notes,
  });

  String get fullName => '$firstName $lastName';
  String get fullAddress => '$address, $city, $state $zipCode';

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'notes': notes,
    };
  }

  factory CustomerInfo.fromMap(Map<String, dynamic> map) {
    return CustomerInfo(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      notes: map['notes'],
    );
  }
}

class ReferralModel {
  final String id;
  final String submittedBy; // User ID who submitted
  final CustomerInfo customer;
  final FiberSpeed selectedPackage;
  final double commissionAmount; // Locked at submission time
  final ReferralStatus status;
  final DateTime submittedAt;
  final DateTime? approvedAt;
  final DateTime? installedAt;
  final DateTime? paidAt;
  final String? rejectionReason;
  final String? adminNotes;
  final List<String> statusHistory; // Track status changes

  ReferralModel({
    required this.id,
    required this.submittedBy,
    required this.customer,
    required this.selectedPackage,
    required this.commissionAmount,
    this.status = ReferralStatus.submitted,
    required this.submittedAt,
    this.approvedAt,
    this.installedAt,
    this.paidAt,
    this.rejectionReason,
    this.adminNotes,
    this.statusHistory = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'submittedBy': submittedBy,
      'customer': customer.toMap(),
      'selectedPackage': selectedPackage.name,
      'commissionAmount': commissionAmount,
      'status': status.name,
      'submittedAt': submittedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'installedAt': installedAt?.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'adminNotes': adminNotes,
      'statusHistory': statusHistory,
    };
  }

  factory ReferralModel.fromMap(Map<String, dynamic> map) {
    return ReferralModel(
      id: map['id'] ?? '',
      submittedBy: map['submittedBy'] ?? '',
      customer: CustomerInfo.fromMap(map['customer'] ?? {}),
      selectedPackage: FiberSpeed.values.firstWhere(
        (e) => e.name == map['selectedPackage'],
        orElse: () => FiberSpeed.speed300mb,
      ),
      commissionAmount: (map['commissionAmount'] ?? 0.0).toDouble(),
      status: ReferralStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReferralStatus.submitted,
      ),
      submittedAt: DateTime.parse(map['submittedAt']),
      approvedAt: map['approvedAt'] != null 
          ? DateTime.parse(map['approvedAt']) 
          : null,
      installedAt: map['installedAt'] != null 
          ? DateTime.parse(map['installedAt']) 
          : null,
      paidAt: map['paidAt'] != null 
          ? DateTime.parse(map['paidAt']) 
          : null,
      rejectionReason: map['rejectionReason'],
      adminNotes: map['adminNotes'],
      statusHistory: List<String>.from(map['statusHistory'] ?? []),
    );
  }

  factory ReferralModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReferralModel.fromMap({...data, 'id': doc.id});
  }

  ReferralModel copyWith({
    String? id,
    String? submittedBy,
    CustomerInfo? customer,
    FiberSpeed? selectedPackage,
    double? commissionAmount,
    ReferralStatus? status,
    DateTime? submittedAt,
    DateTime? approvedAt,
    DateTime? installedAt,
    DateTime? paidAt,
    String? rejectionReason,
    String? adminNotes,
    List<String>? statusHistory,
  }) {
    return ReferralModel(
      id: id ?? this.id,
      submittedBy: submittedBy ?? this.submittedBy,
      customer: customer ?? this.customer,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      installedAt: installedAt ?? this.installedAt,
      paidAt: paidAt ?? this.paidAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      adminNotes: adminNotes ?? this.adminNotes,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }

  // Helper methods
  bool get isPaid => status == ReferralStatus.paid;
  bool get isActive => ![ReferralStatus.rejected, ReferralStatus.cancelled].contains(status);
  int get daysInPipeline => DateTime.now().difference(submittedAt).inDays;
}
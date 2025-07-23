import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationModel {
  final String id;
  final String name;
  final String? description;
  final String? website;
  final String? phone;
  final String? email;
  final String? address;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy; // Admin who created the organization
  final Map<String, dynamic>? settings;

  OrganizationModel({
    required this.id,
    required this.name,
    this.description,
    this.website,
    this.phone,
    this.email,
    this.address,
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
    this.settings,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'website': website,
      'phone': phone,
      'email': email,
      'address': address,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'settings': settings ?? {},
    };
  }

  factory OrganizationModel.fromMap(Map<String, dynamic> map) {
    return OrganizationModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      website: map['website'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'] ?? '',
      settings: map['settings'] as Map<String, dynamic>?,
    );
  }

  factory OrganizationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrganizationModel.fromMap({...data, 'id': doc.id});
  }

  OrganizationModel copyWith({
    String? id,
    String? name,
    String? description,
    String? website,
    String? phone,
    String? email,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    String? createdBy,
    Map<String, dynamic>? settings,
  }) {
    return OrganizationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      settings: settings ?? this.settings,
    );
  }
}
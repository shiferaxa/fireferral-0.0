import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, associate, affiliate }

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? associateId; // For affiliates - which associate manages them
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.associateId,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.name,
      'associateId': associateId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.affiliate,
      ),
      associateId: map['associateId'],
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      lastLoginAt: map['lastLoginAt'] != null 
          ? DateTime.parse(map['lastLoginAt']) 
          : null,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap({...data, 'id': doc.id});
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? associateId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      associateId: associateId ?? this.associateId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
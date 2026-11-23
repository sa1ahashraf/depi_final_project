import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_fields.dart';
import '../enums/user_role.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? photoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.photoUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    return UserModel(
      id: documentId,
      name: map[FirestoreFields.name] as String,
      email: map[FirestoreFields.email] as String,
      phone: map[FirestoreFields.phone] as String,
      role: UserRole.values.firstWhere(
        (e) => e.value == map[FirestoreFields.role],
      ),
      photoUrl: map[FirestoreFields.photoUrl] as String?,
      isActive: map[FirestoreFields.isActive] as bool,
      createdAt: (map[FirestoreFields.createdAt] as Timestamp).toDate(),
      updatedAt: (map[FirestoreFields.updatedAt] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.name: name,
      FirestoreFields.email: email,
      FirestoreFields.phone: phone,
      FirestoreFields.role: role.value,
      FirestoreFields.photoUrl: photoUrl,
      FirestoreFields.isActive: isActive,
      FirestoreFields.createdAt: Timestamp.fromDate(createdAt),
      FirestoreFields.updatedAt: Timestamp.fromDate(updatedAt),
    };
  }
}

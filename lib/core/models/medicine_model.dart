import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_fields.dart';
import '../enums/medicine_form.dart';

class MedicineModel {
  final String id;
  final String name;
  final String genericName;
  final String strength;
  final MedicineForm form;
  final String category;
  final String description;
  final String? imageUrl;
  final bool isActive;
  final List<String> searchKeywords;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MedicineModel({
    required this.id,
    required this.name,
    required this.genericName,
    required this.strength,
    required this.form,
    required this.category,
    required this.description,
    this.imageUrl,
    required this.isActive,
    required this.searchKeywords,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicineModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    return MedicineModel(
      id: documentId,
      name: map[FirestoreFields.name] as String,
      genericName: map[FirestoreFields.genericName] as String,
      strength: map[FirestoreFields.strength] as String,
      form: MedicineForm.values.firstWhere(
        (e) => e.value == map[FirestoreFields.form],
      ),
      category: map[FirestoreFields.category] as String,
      description: map[FirestoreFields.description] as String,
      imageUrl: map[FirestoreFields.imageUrl] as String?,
      isActive: map[FirestoreFields.isActive] as bool,
      searchKeywords: List<String>.from(
        map[FirestoreFields.searchKeywords] ?? [],
      ),
      createdAt: (map[FirestoreFields.createdAt] as Timestamp).toDate(),
      updatedAt: (map[FirestoreFields.updatedAt] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.name: name,
      FirestoreFields.genericName: genericName,
      FirestoreFields.strength: strength,
      FirestoreFields.form: form.value,
      FirestoreFields.category: category,
      FirestoreFields.description: description,
      FirestoreFields.imageUrl: imageUrl,
      FirestoreFields.isActive: isActive,
      FirestoreFields.searchKeywords: searchKeywords,
      FirestoreFields.createdAt: Timestamp.fromDate(createdAt),
      FirestoreFields.updatedAt: Timestamp.fromDate(updatedAt),
    };
  }
}

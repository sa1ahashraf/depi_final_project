import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depi_final_project/core/enums/medicine_form.dart';

enum MedicineIconType { tablets, capsule, vitamin, syrup }

class PharmacyInventoryItemModel {
  final String id;
  final String pharmacyId;
  final String medicineId;
  final String name;
  final String genericName;
  final String description;
  final String category;
  final double price;
  final int quantity;
  final String unitDescription;
  final MedicineForm form;
  final MedicineIconType iconType;
  final bool isAvailable;
  final bool publicVisible;
  final DateTime updatedAt;

  const PharmacyInventoryItemModel({
    required this.id,
    required this.pharmacyId,
    required this.medicineId,
    required this.name,
    required this.genericName,
    required this.description,
    required this.category,
    required this.price,
    required this.quantity,
    required this.unitDescription,
    this.form = MedicineForm.tablet,
    this.iconType = MedicineIconType.tablets,
    required this.isAvailable,
    required this.publicVisible,
    required this.updatedAt,
  });

  factory PharmacyInventoryItemModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    final formString = map['form'] as String? ?? 'tablet';
    final form = MedicineForm.values.firstWhere(
      (e) => e.value == formString,
      orElse: () => MedicineForm.tablet,
    );

    final iconString = map['iconType'] as String? ?? 'tablets';
    final iconType = MedicineIconType.values.firstWhere(
      (e) => e.name == iconString,
      orElse: () {
        if (form == MedicineForm.capsule) return MedicineIconType.capsule;
        if (form == MedicineForm.syrup) return MedicineIconType.syrup;
        return MedicineIconType.tablets;
      },
    );

    return PharmacyInventoryItemModel(
      id: documentId,
      pharmacyId: map['pharmacyId'] as String? ?? '',
      medicineId: map['medicineId'] as String? ?? documentId,
      name: map['name'] as String? ?? map['medicineName'] as String? ?? '',
      genericName: map['genericName'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'جميع الأدوية',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      unitDescription: map['unitDescription'] as String? ?? '20 قرص',
      form: form,
      iconType: iconType,
      isAvailable: map['isAvailable'] as bool? ?? true,
      publicVisible: map['publicVisible'] as bool? ?? true,
      updatedAt:
          map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pharmacyId': pharmacyId,
      'medicineId': medicineId,
      'name': name,
      'genericName': genericName,
      'description': description,
      'category': category,
      'price': price,
      'quantity': quantity,
      'unitDescription': unitDescription,
      'form': form.value,
      'iconType': iconType.name,
      'isAvailable': isAvailable,
      'publicVisible': publicVisible,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  PharmacyInventoryItemModel copyWith({
    String? id,
    String? pharmacyId,
    String? medicineId,
    String? name,
    String? genericName,
    String? description,
    String? category,
    double? price,
    int? quantity,
    String? unitDescription,
    MedicineForm? form,
    MedicineIconType? iconType,
    bool? isAvailable,
    bool? publicVisible,
    DateTime? updatedAt,
  }) {
    return PharmacyInventoryItemModel(
      id: id ?? this.id,
      pharmacyId: pharmacyId ?? this.pharmacyId,
      medicineId: medicineId ?? this.medicineId,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unitDescription: unitDescription ?? this.unitDescription,
      form: form ?? this.form,
      iconType: iconType ?? this.iconType,
      isAvailable: isAvailable ?? this.isAvailable,
      publicVisible: publicVisible ?? this.publicVisible,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

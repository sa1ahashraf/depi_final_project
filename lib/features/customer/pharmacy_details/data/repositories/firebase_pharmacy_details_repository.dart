import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depi_final_project/core/constants/firestore_collections.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/repositories/pharmacy_details_repository.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/repositories/sample_medicines_data.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/data/repositories/firebase_pharmacy_search_repository.dart';

class FirebasePharmacyDetailsRepository implements PharmacyDetailsRepository {
  final FirebaseFirestore _firestore;

  FirebasePharmacyDetailsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static final PharmacyDetailModel defaultPharmacy = PharmacyDetailModel(
    id: 'pharmacy_al_nour',
    name: 'صيدلية النور',
    address: 'شارع النصر، أمام مستشفى المعادي، عمارة 24',
    rating: 4.8,
    distanceKm: 1.2,
    isOpen: true,
    isVerified: true,
    deliveryTime: '20-30 دقيقة',
    paymentMethods: const [
      'إكسترا باي InstaPay',
      'فودافون كاش',
      'دفع عند الاستلام',
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final List<PharmacyInventoryItemModel> defaultInventory =
      generate120Medicines();

  static PharmacyDetailModel getPharmacyById(String pharmacyId) {
    for (final p in FirebasePharmacySearchRepository.defaultPharmacies) {
      if (p.id == pharmacyId) return p;
    }
    return defaultPharmacy.copyWith(id: pharmacyId);
  }

  static List<PharmacyInventoryItemModel> getInventoryForPharmacy(
    String pharmacyId,
  ) {
    final multi =
        FirebasePharmacySearchRepository.generateMultiPharmacyInventory();
    return multi[pharmacyId] ?? defaultInventory;
  }

  @override
  Stream<PharmacyDetailModel> getPharmacyDetailsStream(String pharmacyId) async* {
    final initial = getPharmacyById(pharmacyId);
    yield initial;
    yield* _firestore
        .collection(FirestoreCollections.pharmacies)
        .doc(pharmacyId)
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return PharmacyDetailModel.fromMap(
              doc.data()!,
              documentId: doc.id,
            );
          }
          return initial;
        })
        .handleError((dynamic error) {
          return initial;
        });
  }

  @override
  Stream<List<PharmacyInventoryItemModel>> getPharmacyInventoryStream(
    String pharmacyId,
  ) async* {
    final items = getInventoryForPharmacy(pharmacyId);
    yield items;
    yield* _firestore
        .collection(FirestoreCollections.inventory)
        .where('pharmacyId', isEqualTo: pharmacyId)
        .where('publicVisible', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return snapshot.docs
                .map(
                  (doc) => PharmacyInventoryItemModel.fromMap(
                    doc.data(),
                    documentId: doc.id,
                  ),
                )
                .toList();
          }
          return items;
        })
        .handleError((dynamic error) {
          return items;
        });
  }

  @override
  Future<void> seedDefaultPharmacyData(String pharmacyId) async {
    try {
      final pharmacyDoc = _firestore
          .collection(FirestoreCollections.pharmacies)
          .doc(pharmacyId);

      final snapshot = await pharmacyDoc.get();
      if (!snapshot.exists) {
        await pharmacyDoc.set(defaultPharmacy.toMap());
      }

      final batch = _firestore.batch();
      for (final item in defaultInventory) {
        final itemDoc = _firestore
            .collection(FirestoreCollections.inventory)
            .doc(item.id);
        batch.set(itemDoc, item.toMap(), SetOptions(merge: true));
      }
      await batch.commit();
    } catch (_) {
      // Ignore network / offline seeding issues
    }
  }
}

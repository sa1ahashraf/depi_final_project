import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depi_final_project/core/constants/firestore_collections.dart';
import 'package:depi_final_project/core/constants/firestore_fields.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/repositories/sample_medicines_data.dart';
import 'pharmacy_search_repository.dart';

class FirebasePharmacySearchRepository implements PharmacySearchRepository {
  final FirebaseFirestore _firestore;

  FirebasePharmacySearchRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static final List<PharmacyDetailModel> defaultPharmacies = [
    PharmacyDetailModel(
      id: 'pharmacy_al_amal',
      name: 'صيدلية الأمل الحديثة',
      address: 'تقاطع شارع 9 مع شارع دمشق، المعادي',
      rating: 4.9,
      distanceKm: 0.5,
      isOpen: true,
      isVerified: true,
      deliveryTime: '15-20 دقيقة',
      paymentMethods: const [
        'إكسترا باي InstaPay',
        'دفع عند الاستلام',
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    PharmacyDetailModel(
      id: 'pharmacy_al_nour',
      name: 'صيدلية النور',
      address: 'شارع النصر، أمام مستشفى المعادي، عمارة 24',
      rating: 4.8,
      distanceKm: 0.8,
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
    ),
    PharmacyDetailModel(
      id: 'pharmacy_el_ezaby',
      name: 'صيدليات العزبي',
      address: 'ميدان الحرية، دجلة، المعادي',
      rating: 4.7,
      distanceKm: 1.4,
      isOpen: true,
      isVerified: true,
      deliveryTime: '25-35 دقيقة',
      paymentMethods: const [
        'إكسترا باي InstaPay',
        'فودافون كاش',
        'دفع عند الاستلام',
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    PharmacyDetailModel(
      id: 'pharmacy_misr',
      name: 'صيدلية مصر',
      address: 'شارع اللاسلكي، المعادي الجديدة',
      rating: 4.6,
      distanceKm: 1.9,
      isOpen: true,
      isVerified: true,
      deliveryTime: '30-40 دقيقة',
      paymentMethods: const [
        'فودافون كاش',
        'دفع عند الاستلام',
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    PharmacyDetailModel(
      id: 'pharmacy_seif',
      name: 'صيدليات سيف',
      address: 'كورنيش المعادي، بجوار أبراج عثمان',
      rating: 4.8,
      distanceKm: 2.3,
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
    ),
    PharmacyDetailModel(
      id: 'pharmacy_19011',
      name: 'صيدلية 19011',
      address: 'أوتوستراد المعادي، صقر قريش',
      rating: 4.5,
      distanceKm: 3.1,
      isOpen: false, // Closed for testing open-only filter
      isVerified: false, // Unverified for testing verified-only filter
      deliveryTime: '35-45 دقيقة',
      paymentMethods: const [
        'دفع عند الاستلام',
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static Map<String, List<PharmacyInventoryItemModel>> generateMultiPharmacyInventory() {
    final baseMedicines = generate120Medicines();
    final result = <String, List<PharmacyInventoryItemModel>>{};

    for (final pharmacy in defaultPharmacies) {
      final pharmacyItems = <PharmacyInventoryItemModel>[];
      for (int i = 0; i < baseMedicines.length; i++) {
        final original = baseMedicines[i];
        
        // Vary price and quantity slightly between pharmacies to make comparisons realistic
        double price = original.price;
        if (pharmacy.id == 'pharmacy_al_amal') {
          // Slightly discounted prices at Al-Amal
          price = (original.price * 0.95).roundToDouble();
          if (price < 1.0) price = original.price;
        } else if (pharmacy.id == 'pharmacy_misr') {
          price = original.price + 1.0;
        }

        // Vary stock
        int quantity = original.quantity;
        if (pharmacy.id == 'pharmacy_19011' && i % 4 == 0) {
          quantity = 0; // Out of stock for testing
        }

        pharmacyItems.add(
          original.copyWith(
            id: '${pharmacy.id}_${original.id}',
            pharmacyId: pharmacy.id,
            price: price,
            quantity: quantity,
            isAvailable: quantity > 0,
          ),
        );
      }
      result[pharmacy.id] = pharmacyItems;
    }
    return result;
  }

  @override
  Stream<List<PharmacyDetailModel>> getPharmaciesStream() async* {
    yield defaultPharmacies;

    try {
      final snapshots = _firestore
          .collection(FirestoreCollections.pharmacies)
          .where(FirestoreFields.isActive, isEqualTo: true)
          .snapshots();

      await for (final snapshot in snapshots) {
        if (snapshot.docs.isNotEmpty) {
          final loaded = snapshot.docs.map((doc) {
            return PharmacyDetailModel.fromMap(
              doc.data(),
              documentId: doc.id,
            );
          }).toList();
          yield loaded;
        }
      }
    } catch (_) {
      // Fallback kept
    }
  }

  @override
  Stream<List<PharmacyInventoryItemModel>> getAllInventoriesStream() async* {
    final multiInventory = generateMultiPharmacyInventory();
    final allItems = multiInventory.values.expand((list) => list).toList();
    yield allItems;

    try {
      final snapshots = _firestore
          .collection(FirestoreCollections.inventory)
          .where(FirestoreFields.isAvailable, isEqualTo: true)
          .snapshots();

      await for (final snapshot in snapshots) {
        if (snapshot.docs.isNotEmpty) {
          final loaded = snapshot.docs.map((doc) {
            return PharmacyInventoryItemModel.fromMap(
              doc.data(),
              documentId: doc.id,
            );
          }).toList();
          yield loaded;
        }
      }
    } catch (_) {
      // Fallback kept
    }
  }

  @override
  Future<List<PharmacyDetailModel>> getPharmacies() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.pharmacies)
          .where(FirestoreFields.isActive, isEqualTo: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          return PharmacyDetailModel.fromMap(doc.data(), documentId: doc.id);
        }).toList();
      }
    } catch (_) {}
    return defaultPharmacies;
  }

  @override
  Future<List<PharmacyInventoryItemModel>> getInventoryForPharmacy(
    String pharmacyId,
  ) async {
    final multiInventory = generateMultiPharmacyInventory();
    return multiInventory[pharmacyId] ?? generate120Medicines();
  }
}

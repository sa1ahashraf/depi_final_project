import 'package:flutter_test/flutter_test.dart';
import 'package:depi_final_project/core/enums/medicine_form.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/cart_item_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';

void main() {
  group('PharmacyDetailModel Tests', () {
    test('creates and converts to/from Map correctly', () {
      final now = DateTime.now();
      final model = PharmacyDetailModel(
        id: 'pharmacy_123',
        name: 'صيدلية النور',
        address: 'شارع النصر، أمام مستشفى المعادي، عمارة 24',
        rating: 4.8,
        distanceKm: 1.2,
        isOpen: true,
        isVerified: true,
        deliveryTime: '20-30 دقيقة',
        createdAt: now,
        updatedAt: now,
      );

      expect(model.id, 'pharmacy_123');
      expect(model.name, 'صيدلية النور');
      expect(model.rating, 4.8);
      expect(model.distanceKm, 1.2);
      expect(model.isOpen, true);
      expect(model.isVerified, true);
      expect(model.deliveryTime, '20-30 دقيقة');

      final map = model.toMap();
      expect(map['name'], 'صيدلية النور');
      expect(map['rating'], 4.8);
      expect(map['deliveryTime'], '20-30 دقيقة');

      final fromMap = PharmacyDetailModel.fromMap(
        map,
        documentId: 'pharmacy_123',
      );
      expect(fromMap.id, 'pharmacy_123');
      expect(fromMap.name, 'صيدلية النور');
      expect(fromMap.rating, 4.8);
    });

    test('copyWith updates fields appropriately', () {
      final model = PharmacyDetailModel(
        id: '1',
        name: 'صيدلية القديمة',
        address: 'عنوان',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = model.copyWith(name: 'صيدلية النور', rating: 4.9);
      expect(updated.name, 'صيدلية النور');
      expect(updated.rating, 4.9);
      expect(updated.id, '1');
    });
  });

  group('PharmacyInventoryItemModel Tests', () {
    test('instantiates and calculates correctly', () {
      final item = PharmacyInventoryItemModel(
        id: 'inv_1',
        pharmacyId: 'ph_1',
        medicineId: 'med_1',
        name: 'Panadol Extra',
        genericName: 'باراسيتامول + كافيين',
        description: 'باراسيتامول + كافيين (مسكن للصداع والآلام)',
        category: 'مسكنات وحرارة',
        price: 45.0,
        quantity: 18,
        unitDescription: '24 قرص',
        form: MedicineForm.tablet,
        iconType: MedicineIconType.tablets,
        isAvailable: true,
        publicVisible: true,
        updatedAt: DateTime.now(),
      );

      expect(item.name, 'Panadol Extra');
      expect(item.price, 45.0);
      expect(item.quantity, 18);
      expect(item.unitDescription, '24 قرص');
    });
  });

  group('CartItemModel Tests', () {
    test('computes totalPrice based on quantity and item price', () {
      final item = PharmacyInventoryItemModel(
        id: 'inv_1',
        pharmacyId: 'ph_1',
        medicineId: 'med_1',
        name: 'Panadol Extra',
        genericName: 'باراسيتامول + كافيين',
        description: 'مسكن',
        category: 'مسكنات',
        price: 45.0,
        quantity: 18,
        unitDescription: '24 قرص',
        isAvailable: true,
        publicVisible: true,
        updatedAt: DateTime.now(),
      );

      final cartItem = CartItemModel(
        item: item,
        quantity: 2,
        pharmacyId: 'ph_1',
        pharmacyName: 'صيدلية النور',
        pharmacyAddress: 'المعادي',
      );
      expect(cartItem.totalPrice, 90.0);
      expect(cartItem.effectivePharmacyId, 'ph_1');
      expect(cartItem.effectivePharmacyName, 'صيدلية النور');

      final map = cartItem.toMap();
      expect(map['pharmacyName'], 'صيدلية النور');
      expect(map['totalPrice'], 90.0);

      final singleCartItem = CartItemModel(item: item, quantity: 1);
      expect(singleCartItem.totalPrice, 45.0);
    });
  });
}

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/repositories/firebase_pharmacy_details_repository.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/repositories/pharmacy_details_repository.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/logic/cubits/pharmacy_details_cubit.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/logic/cubits/pharmacy_details_state.dart';

import 'package:depi_final_project/features/customer/pharmacy_details/data/repositories/sample_medicines_data.dart';

class MockPharmacyDetailsRepository implements PharmacyDetailsRepository {
  final _pharmacyController = StreamController<PharmacyDetailModel>.broadcast();
  final _inventoryController =
      StreamController<List<PharmacyInventoryItemModel>>.broadcast();

  final PharmacyDetailModel testPharmacy = PharmacyDetailModel(
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

  final List<PharmacyInventoryItemModel> testInventory =
      generate120Medicines();

  @override
  Stream<PharmacyDetailModel> getPharmacyDetailsStream(String pharmacyId) async* {
    if (pharmacyId == 'pharmacy_al_nour') {
      yield testPharmacy;
    } else {
      yield FirebasePharmacyDetailsRepository.getPharmacyById(pharmacyId);
    }
    yield* _pharmacyController.stream;
  }

  @override
  Stream<List<PharmacyInventoryItemModel>> getPharmacyInventoryStream(
    String pharmacyId,
  ) async* {
    yield testInventory;
    yield* _inventoryController.stream;
  }

  @override
  Future<void> seedDefaultPharmacyData(String pharmacyId) async {}

  void dispose() {
    _pharmacyController.close();
    _inventoryController.close();
  }
}

void main() {
  late MockPharmacyDetailsRepository repository;
  late PharmacyDetailsCubit cubit;

  setUp(() {
    repository = MockPharmacyDetailsRepository();
    cubit = PharmacyDetailsCubit(repository: repository);
  });

  tearDown(() {
    cubit.close();
    repository.dispose();
  });

  test('initial state is correct', () {
    expect(cubit.state.status, PharmacyDetailsStatus.loaded);
    expect(cubit.state.pharmacy?.name, 'صيدلية النور');
    expect(cubit.state.cartTotal, 0.0);
    expect(cubit.state.cartItemCount, 0);
  });

  test('initialSearchQuery filters items on start and allows clearing', () {
    final searchCubit = PharmacyDetailsCubit(
      repository: repository,
      initialSearchQuery: 'Panadol',
    );
    expect(searchCubit.state.searchQuery, 'Panadol');
    expect(
      searchCubit.state.filteredItems.every((item) => item.name.contains('Panadol')),
      true,
    );

    searchCubit.clearSearch();
    expect(searchCubit.state.searchQuery, '');
    expect(searchCubit.state.filteredItems.length > 1, true);

    searchCubit.close();
  });

  test('loadPharmacyDetails loads pharmacy and inventory correctly', () async {
    cubit.loadPharmacyDetails('pharmacy_al_nour');

    await pumpEventQueue();

    expect(cubit.state.status, PharmacyDetailsStatus.loaded);
    expect(cubit.state.pharmacy?.name, 'صيدلية النور');
    expect(cubit.state.allItems.length, 120);
    expect(cubit.state.allItems.first.name, 'Panadol Extra');
  });

  test('category selection filters items properly', () async {
    cubit.loadPharmacyDetails('pharmacy_al_nour');
    await pumpEventQueue();

    // Select category 'مسكنات وحرارة'
    cubit.selectCategory('مسكنات وحرارة');
    expect(cubit.state.selectedCategory, 'مسكنات وحرارة');
    expect(cubit.state.filteredItems.isNotEmpty, true);
    expect(cubit.state.filteredItems.first.name, 'Panadol Extra');

    // Select 'جميع الأدوية'
    cubit.selectCategory('جميع الأدوية (120)');
    expect(cubit.state.selectedCategory, 'جميع الأدوية');
    expect(cubit.state.filteredItems.length, 120);
  });

  test('searching medicines filters by name, generic name, and description', () async {
    cubit.loadPharmacyDetails('pharmacy_al_nour');
    await pumpEventQueue();

    // Search by English name
    cubit.updateSearchQuery('Panadol');
    expect(cubit.state.searchQuery, 'Panadol');
    expect(
      cubit.state.filteredItems.any((item) => item.name == 'Panadol Extra'),
      true,
    );

    // Search by Arabic generic name
    cubit.updateSearchQuery('باراسيتامول');
    expect(
      cubit.state.filteredItems.any((item) => item.name == 'Panadol Extra'),
      true,
    );
    expect(
      cubit.state.filteredItems.any((item) => item.name == 'Congestal Tablets'),
      true,
    );

    // Clear search restores full inventory
    cubit.clearSearch();
    expect(cubit.state.searchQuery, '');
    expect(cubit.state.filteredItems.length, 120);
  });

  test('adding to cart updates total amount and item count', () async {
    cubit.loadPharmacyDetails('pharmacy_al_nour');
    await pumpEventQueue();

    final panadol = cubit.state.allItems[0]; // 45 EGP
    final congestal = cubit.state.allItems[1]; // 31 EGP

    cubit.addToCart(panadol);
    expect(cubit.state.cartItemCount, 1);
    expect(cubit.state.cartTotal, 45.0);

    cubit.addToCart(congestal);
    // 45 + 31 = 76 EGP, count = 2 (Exact values seen in screenshot!)
    expect(cubit.state.cartItemCount, 2);
    expect(cubit.state.cartTotal, 76.0);
    expect(cubit.state.cart[panadol.id]?.effectivePharmacyName, 'صيدلية النور');
  });

  test('cannot add out of stock items to cart', () async {
    cubit.loadPharmacyDetails('pharmacy_al_nour');
    await pumpEventQueue();

    final outOfStockItem = cubit.state.allItems[0].copyWith(
      quantity: 0,
      isAvailable: false,
    );

    final added = cubit.addToCart(outOfStockItem);
    expect(added, false);
    expect(cubit.state.cartItemCount, 0);
    expect(cubit.state.cartTotal, 0.0);
  });

  test('removing from cart updates total and clears when empty', () async {
    cubit.loadPharmacyDetails('pharmacy_al_nour');
    await pumpEventQueue();

    final panadol = cubit.state.allItems[0];
    cubit.addToCart(panadol);
    cubit.addToCart(panadol);
    expect(cubit.state.cart[panadol.id]?.quantity, 2);
    expect(cubit.state.cartTotal, 90.0);

    cubit.removeFromCart(panadol);
    expect(cubit.state.cart[panadol.id]?.quantity, 1);
    expect(cubit.state.cartTotal, 45.0);

    cubit.removeFromCart(panadol);
    expect(cubit.state.cart.containsKey(panadol.id), false);
    expect(cubit.state.cartItemCount, 0);
    expect(cubit.state.cartTotal, 0.0);
  });

  test('setCartPreloadedForDemo sets exact cart state from screenshot', () async {
    cubit.loadPharmacyDetails('pharmacy_al_nour');
    await pumpEventQueue();

    cubit.setCartPreloadedForDemo();
    expect(cubit.state.cartItemCount, 2);
    expect(cubit.state.cartTotal, 76.0);
  });
}

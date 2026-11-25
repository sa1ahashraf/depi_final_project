import 'package:flutter_test/flutter_test.dart';
import 'package:depi_final_project/features/customer/cart/logic/cubits/customer_cart_cubit.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/data/repositories/firebase_pharmacy_search_repository.dart';

void main() {
  late CustomerCartCubit cartCubit;
  late PharmacyDetailModel pharmacyAlNour;
  late PharmacyDetailModel pharmacyAlAmal;
  late PharmacyDetailModel pharmacy19011;

  setUp(() {
    cartCubit = CustomerCartCubit();
    pharmacyAlNour = FirebasePharmacySearchRepository.defaultPharmacies.firstWhere(
      (p) => p.id == 'pharmacy_al_nour',
    );
    pharmacyAlAmal = FirebasePharmacySearchRepository.defaultPharmacies.firstWhere(
      (p) => p.id == 'pharmacy_al_amal',
    );
    pharmacy19011 = FirebasePharmacySearchRepository.defaultPharmacies.firstWhere(
      (p) => p.id == 'pharmacy_19011',
    );
  });

  tearDown(() {
    cartCubit.close();
  });

  test('initial cart is empty', () {
    expect(cartCubit.state.isEmpty, true);
    expect(cartCubit.state.grandTotal, 0.0);
    expect(cartCubit.state.totalItemCount, 0);
    expect(cartCubit.state.pharmacyGroups.isEmpty, true);
  });

  test('adding items from multiple pharmacies attributes each to its own pharmacy and groups properly', () {
    final panadolFromAlNour = PharmacyInventoryItemModel(
      id: 'inv_1',
      pharmacyId: 'pharmacy_al_nour',
      medicineId: 'med_1',
      name: 'Panadol Extra',
      genericName: 'باراسيتامول',
      description: 'مسكن',
      category: 'مسكنات',
      price: 45.0,
      quantity: 10,
      unitDescription: '24 قرص',
      isAvailable: true,
      publicVisible: true,
      updatedAt: DateTime.now(),
    );

    final congestalFromAlAmal = PharmacyInventoryItemModel(
      id: 'inv_2',
      pharmacyId: 'pharmacy_al_amal',
      medicineId: 'med_2',
      name: 'Congestal Tablets',
      genericName: 'سودوإيفيدرين',
      description: 'برد',
      category: 'برد',
      price: 30.0,
      quantity: 15,
      unitDescription: '20 قرص',
      isAvailable: true,
      publicVisible: true,
      updatedAt: DateTime.now(),
    );

    // 1. Add Panadol from Al-Nour
    final added1 = cartCubit.addToCart(panadolFromAlNour, pharmacyAlNour);
    expect(added1, true);

    // 2. Add Congestal from Al-Amal
    final added2 = cartCubit.addToCart(congestalFromAlAmal, pharmacyAlAmal);
    expect(added2, true);

    // Cart should have 2 items and 2 distinct pharmacy groups!
    expect(cartCubit.state.totalItemCount, 2);
    expect(cartCubit.state.grandTotal, 75.0);
    expect(cartCubit.state.pharmacyGroups.length, 2);

    final alNourGroup = cartCubit.state.pharmacyGroups.firstWhere(
      (g) => g.pharmacyId == 'pharmacy_al_nour',
    );
    expect(alNourGroup.pharmacyName, 'صيدلية النور');
    expect(alNourGroup.items.first.item.name, 'Panadol Extra');
    expect(alNourGroup.subtotal, 45.0);

    final alAmalGroup = cartCubit.state.pharmacyGroups.firstWhere(
      (g) => g.pharmacyId == 'pharmacy_al_amal',
    );
    expect(alAmalGroup.pharmacyName, 'صيدلية الأمل الحديثة');
    expect(alAmalGroup.items.first.item.name, 'Congestal Tablets');
    expect(alAmalGroup.subtotal, 30.0);
  });

  test('cannot add out of stock items from any pharmacy', () {
    final outOfStockFrom19011 = PharmacyInventoryItemModel(
      id: 'inv_out',
      pharmacyId: 'pharmacy_19011',
      medicineId: 'med_out',
      name: 'Panadol Extra',
      genericName: 'باراسيتامول',
      description: 'مسكن',
      category: 'مسكنات',
      price: 45.0,
      quantity: 0,
      unitDescription: '24 قرص',
      isAvailable: false,
      publicVisible: true,
      updatedAt: DateTime.now(),
    );

    final added = cartCubit.addToCart(outOfStockFrom19011, pharmacy19011);
    expect(added, false);
    expect(cartCubit.state.isEmpty, true);
  });

  test('selective checkout: select only one pharmacy or multiple or all', () {
    final item1 = PharmacyInventoryItemModel(
      id: 'inv_1',
      pharmacyId: 'pharmacy_al_nour',
      medicineId: 'med_1',
      name: 'Panadol Extra',
      genericName: 'باراسيتامول',
      description: 'مسكن',
      category: 'مسكنات',
      price: 50.0,
      quantity: 10,
      unitDescription: '24 قرص',
      isAvailable: true,
      publicVisible: true,
      updatedAt: DateTime.now(),
    );

    final item2 = PharmacyInventoryItemModel(
      id: 'inv_2',
      pharmacyId: 'pharmacy_al_amal',
      medicineId: 'med_2',
      name: 'Congestal',
      genericName: 'برد',
      description: 'برد',
      category: 'برد',
      price: 30.0,
      quantity: 10,
      unitDescription: '20 قرص',
      isAvailable: true,
      publicVisible: true,
      updatedAt: DateTime.now(),
    );

    cartCubit.addToCart(item1, pharmacyAlNour);
    cartCubit.addToCart(item2, pharmacyAlAmal);

    // By default, both are selected
    expect(cartCubit.state.isAllSelected, true);
    expect(cartCubit.state.selectedTotal, 80.0);
    expect(cartCubit.state.selectedPharmacyCount, 2);

    // Option: Select only Al-Nour (أتم الشراء بتاع الصيدلية كذا لوحدها)
    cartCubit.selectOnlyPharmacy('pharmacy_al_nour');
    expect(cartCubit.state.selectedPharmacyIds, {'pharmacy_al_nour'});
    expect(cartCubit.state.selectedTotal, 50.0);
    expect(cartCubit.state.selectedItemCount, 1);
    expect(cartCubit.state.selectedPharmacyCount, 1);

    // Option: Toggle Al-Amal back (أو كذا واحدة مع بعض)
    cartCubit.togglePharmacySelection('pharmacy_al_amal');
    expect(cartCubit.state.selectedPharmacyCount, 2);
    expect(cartCubit.state.selectedTotal, 80.0);

    // Option: Select All (أو كلهم)
    cartCubit.selectAllPharmacies();
    expect(cartCubit.state.isAllSelected, true);

    // Option: Deselect all
    cartCubit.deselectAllPharmacies();
    expect(cartCubit.state.selectedTotal, 0.0);
    expect(cartCubit.state.selectedPharmacyCount, 0);
  });
}

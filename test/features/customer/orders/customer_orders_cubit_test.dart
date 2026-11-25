import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:depi_final_project/core/constants/firestore_fields.dart';
import 'package:depi_final_project/core/enums/medicine_form.dart';
import 'package:depi_final_project/core/enums/order_status.dart';
import 'package:depi_final_project/core/models/order_model.dart';
import 'package:depi_final_project/features/customer/cart/logic/cubits/customer_cart_cubit.dart';
import 'package:depi_final_project/features/customer/orders/data/repositories/firebase_customer_order_repository.dart';
import 'package:depi_final_project/features/customer/orders/logic/cubits/customer_orders_cubit.dart';
import 'package:depi_final_project/features/customer/orders/logic/cubits/customer_orders_state.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';

void main() {
  late FirebaseCustomerOrderRepository repository;
  late CustomerOrdersCubit ordersCubit;
  late CustomerCartCubit cartCubit;

  final now = DateTime(2026, 11, 25, 12, 0);

  final pharmacyAlNour = PharmacyDetailModel(
    id: 'pharmacy_al_nour',
    name: 'صيدلية النور',
    address: 'شارع النصر، المعادي',
    rating: 4.8,
    distanceKm: 0.8,
    isOpen: true,
    isVerified: true,
    deliveryTime: '20-30 دقيقة',
    paymentMethods: const ['دفع عند الاستلام'],
    createdAt: now,
    updatedAt: now,
  );

  final pharmacyElEzaby = PharmacyDetailModel(
    id: 'pharmacy_el_ezaby',
    name: 'صيدليات العزبي',
    address: 'ميدان الحرية، المعادي',
    rating: 4.7,
    distanceKm: 1.4,
    isOpen: true,
    isVerified: true,
    deliveryTime: '25-35 دقيقة',
    paymentMethods: const ['دفع عند الاستلام'],
    createdAt: now,
    updatedAt: now,
  );

  final panadol = PharmacyInventoryItemModel(
    id: 'pharmacy_al_nour_inv_1',
    pharmacyId: 'pharmacy_al_nour',
    medicineId: 'med_1',
    name: 'Panadol Extra',
    genericName: 'باراسيتامول',
    description: 'مسكن للصداع',
    category: 'مسكنات وحرارة',
    price: 45.0,
    quantity: 10,
    unitDescription: '24 قرص',
    form: MedicineForm.tablet,
    isAvailable: true,
    publicVisible: true,
    updatedAt: now,
  );

  final congestal = PharmacyInventoryItemModel(
    id: 'pharmacy_el_ezaby_inv_2',
    pharmacyId: 'pharmacy_el_ezaby',
    medicineId: 'med_2',
    name: 'Congestal Tablets',
    genericName: 'باراسيتامول + سودوإيفيدرين',
    description: 'للبرد والاحتقان',
    category: 'البرد والإنفلونزا',
    price: 31.0,
    quantity: 8,
    unitDescription: '20 قرص',
    form: MedicineForm.tablet,
    isAvailable: true,
    publicVisible: true,
    updatedAt: now,
  );

  setUp(() async {
    repository = FirebaseCustomerOrderRepository(
      customerIdOverride: 'test_customer_1',
      enableFirestoreSync: false,
      seedDemoData: true,
    );
    ordersCubit = CustomerOrdersCubit(repository: repository);
    cartCubit = CustomerCartCubit();
    await ordersCubit.loadInitialData();
  });

  tearDown(() async {
    await ordersCubit.close();
    await cartCubit.close();
    repository.dispose();
  });

  test('creates orders adhering strictly to OrderModel contract and clears only selected pharmacies', () async {
    cartCubit.addToCart(panadol, pharmacyAlNour);
    cartCubit.addToCart(panadol, pharmacyAlNour); // quantity 2 -> 90.0
    cartCubit.addToCart(congestal, pharmacyElEzaby); // quantity 1 -> 31.0

    // Select only Al-Nour for checkout
    cartCubit.selectOnlyPharmacy(pharmacyAlNour.id);
    final selectedGroups = cartCubit.state.pharmacyGroups
        .where((g) => g.isSelected)
        .toList();

    final createdOrders = await ordersCubit.placeOrdersFromCart(
      cartCubit: cartCubit,
      selectedGroups: selectedGroups,
      deliveryFeePerPharmacy: 15.0,
    );

    expect(createdOrders.length, 1);
    final order = createdOrders.first;

    // Verify agreed OrderModel contract fields
    expect(order.customerId, 'test_customer_1');
    expect(order.pharmacyId, 'pharmacy_al_nour');
    expect(order.status, OrderStatus.pending);
    expect(order.rejectionReason, isNull);
    expect(order.deliveryFee, 15.0);
    expect(order.totalPrice, 105.0); // 90 items + 15 delivery
    expect(order.items.length, 1);
    expect(order.items.first.medicineId, 'med_1');
    expect(order.items.first.medicineName, 'Panadol Extra');
    expect(order.items.first.strength, '24 قرص');
    expect(order.items.first.quantity, 2);
    expect(order.items.first.unitPrice, 45.0);
    expect(order.items.first.subtotal, 90.0);
    expect(order.deliveryAddress[FirestoreFields.label], 'المنزل');
    expect(order.deliveryAddress[FirestoreFields.phone], '01012345678');

    // Verify Firestore roundtrip via toMap / fromMap
    final serialized = order.toMap();
    expect(serialized[FirestoreFields.status], 'pending');
    expect(serialized[FirestoreFields.createdAt], isA<Timestamp>());
    final deserialized = OrderModel.fromMap(serialized, documentId: order.id);
    expect(deserialized.id, order.id);
    expect(deserialized.items.first.subtotal, 90.0);

    // Verify El-Ezaby stayed in cart while Al-Nour was cleared
    expect(cartCubit.state.pharmacyGroups.length, 1);
    expect(cartCubit.state.pharmacyGroups.first.pharmacyId, 'pharmacy_el_ezaby');
  });

  test('multi-pharmacy checkout creates one order per selected pharmacy', () async {
    cartCubit.addToCart(panadol, pharmacyAlNour);
    cartCubit.addToCart(congestal, pharmacyElEzaby);
    cartCubit.selectAllPharmacies();

    final createdOrders = await ordersCubit.placeOrdersFromCart(
      cartCubit: cartCubit,
      selectedGroups: cartCubit.state.pharmacyGroups,
      deliveryFeePerPharmacy: 15.0,
    );

    expect(createdOrders.length, 2);
    expect(
      createdOrders.map((o) => o.pharmacyId).toSet(),
      {'pharmacy_al_nour', 'pharmacy_el_ezaby'},
    );
    expect(cartCubit.state.isEmpty, true);
  });

  test('cancelling pending order updates status to cancelled and filters work', () async {
    cartCubit.addToCart(panadol, pharmacyAlNour);
    final created = await ordersCubit.placeOrdersFromCart(
      cartCubit: cartCubit,
      selectedGroups: cartCubit.state.pharmacyGroups,
    );
    final orderId = created.first.id;

    final ok = await ordersCubit.cancelOrder(orderId);
    expect(ok, true);
    await pumpEventQueue();

    final updated = ordersCubit.state.orders.firstWhere((o) => o.id == orderId);
    expect(updated.status, OrderStatus.cancelled);

    ordersCubit.setFilter(OrderHistoryFilter.closed);
    expect(
      ordersCubit.state.filteredOrders.any((o) => o.id == orderId),
      true,
    );
  });

  test('reorderToCart adds items back into CustomerCartCubit', () {
    final completedOrder = ordersCubit.state.orders.firstWhere(
      (o) => o.status == OrderStatus.completed,
    );

    final addedCount = ordersCubit.reorderToCart(completedOrder, cartCubit);
    expect(addedCount, greaterThan(0));
    expect(cartCubit.state.isNotEmpty, true);
  });

  test('addOrUpdateAddress saves and selects new delivery address', () async {
    final saved = await ordersCubit.addOrUpdateAddress(
      label: 'الشركة',
      addressLine: 'كورنيش المعادي، برج السلام',
      phone: '01099887766',
    );

    expect(saved, isNotNull);
    expect(ordersCubit.state.selectedAddress?.label, 'الشركة');
    expect(
      ordersCubit.state.selectedAddressMap?[FirestoreFields.phone],
      '01099887766',
    );
  });
}

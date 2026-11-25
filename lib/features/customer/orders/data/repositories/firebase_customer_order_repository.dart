import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:depi_final_project/core/constants/firestore_collections.dart';
import 'package:depi_final_project/core/constants/firestore_fields.dart';
import 'package:depi_final_project/core/enums/order_status.dart';
import 'package:depi_final_project/core/models/address_model.dart';
import 'package:depi_final_project/core/models/order_item_model.dart';
import 'package:depi_final_project/core/models/order_model.dart';
import 'package:depi_final_project/features/customer/cart/data/models/cart_pharmacy_group.dart';
import 'customer_order_repository.dart';

class FirebaseCustomerOrderRepository implements CustomerOrderRepository {
  final FirebaseFirestore? _firestoreOverride;
  final FirebaseAuth? _authOverride;
  final String? customerIdOverride;
  final bool enableFirestoreSync;

  final List<OrderModel> _localOrders = [];
  final List<AddressModel> _localAddresses = [];
  final StreamController<List<OrderModel>> _ordersController =
      StreamController<List<OrderModel>>.broadcast();

  static const String defaultGuestCustomerId = 'customer_maadi_guest';

  FirebaseCustomerOrderRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    this.customerIdOverride,
    this.enableFirestoreSync = true,
    bool seedDemoData = true,
  }) : _firestoreOverride = firestore,
       _authOverride = auth {
    if (seedDemoData) {
      _seedInitialDemoData();
    }
  }

  FirebaseFirestore? _tryGetFirestore() {
    if (!enableFirestoreSync) return null;
    if (_firestoreOverride != null) return _firestoreOverride;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseAuth? _tryGetAuth() {
    if (!enableFirestoreSync) return null;
    if (_authOverride != null) return _authOverride;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  String get currentCustomerId {
    if (customerIdOverride != null && customerIdOverride!.isNotEmpty) {
      return customerIdOverride!;
    }
    final uid = _tryGetAuth()?.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      return uid;
    }
    return defaultGuestCustomerId;
  }

  void _seedInitialDemoData() {
    final now = DateTime.now();
    final customerId = currentCustomerId;

    _localAddresses.addAll([
      AddressModel(
        id: 'addr_home_1',
        userId: customerId,
        label: 'المنزل',
        address: 'شارع 9، عمارة 14، الدور الثالث، المعادي',
        phone: '01012345678',
        latitude: 29.9602,
        longitude: 31.2569,
        isDefault: true,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      AddressModel(
        id: 'addr_work_2',
        userId: customerId,
        label: 'العمل',
        address: 'شارع اللاسلكي، برج النخيل، الدور الخامس، المعادي الجديدة',
        phone: '01122334455',
        latitude: 29.9721,
        longitude: 31.2755,
        isDefault: false,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ]);

    final defaultAddrMap = _addressToDeliveryMap(_localAddresses.first);

    _localOrders.addAll([
      OrderModel(
        id: 'ORD-20261125-01',
        customerId: customerId,
        pharmacyId: 'pharmacy_al_nour',
        items: const [
          OrderItemModel(
            medicineId: 'med_1',
            medicineName: 'Panadol Extra',
            strength: '24 قرص',
            quantity: 1,
            unitPrice: 45.0,
            subtotal: 45.0,
          ),
          OrderItemModel(
            medicineId: 'med_2',
            medicineName: 'Congestal Tablets',
            strength: '20 قرص',
            quantity: 1,
            unitPrice: 31.0,
            subtotal: 31.0,
          ),
        ],
        totalPrice: 91.0,
        deliveryFee: 15.0,
        deliveryAddress: defaultAddrMap,
        status: OrderStatus.preparing,
        createdAt: now.subtract(const Duration(minutes: 18)),
        updatedAt: now.subtract(const Duration(minutes: 6)),
      ),
      OrderModel(
        id: 'ORD-20261123-02',
        customerId: customerId,
        pharmacyId: 'pharmacy_al_amal',
        items: const [
          OrderItemModel(
            medicineId: 'med_3',
            medicineName: 'C-Retard 500mg',
            strength: '10 كبسولات',
            quantity: 2,
            unitPrice: 27.0,
            subtotal: 54.0,
          ),
        ],
        totalPrice: 69.0,
        deliveryFee: 15.0,
        deliveryAddress: defaultAddrMap,
        status: OrderStatus.completed,
        createdAt: now.subtract(const Duration(days: 2, hours: 3)),
        updatedAt: now.subtract(const Duration(days: 2, hours: 2)),
      ),
    ]);
  }

  static Map<String, dynamic> _addressToDeliveryMap(AddressModel address) {
    return {
      FirestoreFields.label: address.label,
      FirestoreFields.address: address.address,
      FirestoreFields.phone: address.phone,
      FirestoreFields.latitude: address.latitude,
      FirestoreFields.longitude: address.longitude,
    };
  }

  @override
  Future<List<OrderModel>> createOrdersFromCart({
    required List<CartPharmacyGroup> pharmacyGroups,
    required Map<String, dynamic> deliveryAddress,
    double deliveryFeePerPharmacy = 15.0,
  }) async {
    if (pharmacyGroups.isEmpty) {
      throw ArgumentError('لا يمكن إنشاء طلب بدون اختيار صيدلية واحدة على الأقل.');
    }

    final now = DateTime.now();
    final customerId = currentCustomerId;
    final firestore = _tryGetFirestore();
    final createdOrders = <OrderModel>[];

    for (int i = 0; i < pharmacyGroups.length; i++) {
      final group = pharmacyGroups[i];
      if (group.items.isEmpty) continue;

      final orderItems = group.items.map((cartItem) {
        final unitPrice = cartItem.item.price;
        final quantity = cartItem.quantity;
        return OrderItemModel(
          medicineId: cartItem.item.medicineId,
          medicineName: cartItem.item.name,
          strength: cartItem.item.unitDescription.isNotEmpty
              ? cartItem.item.unitDescription
              : cartItem.item.form.value,
          quantity: quantity,
          unitPrice: unitPrice,
          subtotal: unitPrice * quantity,
        );
      }).toList();

      final itemsSubtotal = orderItems.fold<double>(
        0.0,
        (acc, item) => acc + item.subtotal,
      );
      final totalPrice = itemsSubtotal + deliveryFeePerPharmacy;

      final docId = firestore != null
          ? firestore.collection(FirestoreCollections.orders).doc().id
          : 'ORD-${now.millisecondsSinceEpoch}-${i + 1}';

      final order = OrderModel(
        id: docId,
        customerId: customerId,
        pharmacyId: group.pharmacyId,
        items: orderItems,
        totalPrice: totalPrice,
        deliveryFee: deliveryFeePerPharmacy,
        deliveryAddress: Map<String, dynamic>.from(deliveryAddress),
        status: OrderStatus.pending,
        rejectionReason: null,
        createdAt: now,
        updatedAt: now,
      );

      if (firestore != null) {
        try {
          await firestore
              .collection(FirestoreCollections.orders)
              .doc(order.id)
              .set(order.toMap())
              .timeout(const Duration(seconds: 4));
        } catch (_) {
          // Graceful fallback to local reactive store when offline or unauthenticated
        }
      }

      _upsertLocalOrder(order);
      createdOrders.add(order);
    }

    _emitLocalOrders();
    return createdOrders;
  }

  @override
  Stream<List<OrderModel>> watchCustomerOrders([String? customerId]) {
    final targetCustomerId = customerId ?? currentCustomerId;
    final firestore = _tryGetFirestore();

    if (firestore == null) {
      return _localOrdersStream(targetCustomerId);
    }

    late final StreamController<List<OrderModel>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? firestoreSub;
    StreamSubscription<List<OrderModel>>? localSub;

    List<OrderModel> remoteOrders = [];

    void emitMerged() {
      if (controller.isClosed) return;
      final merged = _mergeOrders(
        remoteOrders,
        _sortedLocalOrders(targetCustomerId),
      );
      controller.add(merged);
    }

    controller = StreamController<List<OrderModel>>(
      onListen: () {
        emitMerged();
        localSub = _ordersController.stream.listen((_) => emitMerged());

        try {
          firestoreSub = firestore
              .collection(FirestoreCollections.orders)
              .where(FirestoreFields.customerId, isEqualTo: targetCustomerId)
              .snapshots()
              .listen(
                (snapshot) {
                  remoteOrders = snapshot.docs
                      .map(
                        (doc) => OrderModel.fromMap(
                          doc.data(),
                          documentId: doc.id,
                        ),
                      )
                      .toList();
                  emitMerged();
                },
                onError: (_) {
                  // Keep local orders active if Firestore stream fails
                  emitMerged();
                },
              );
        } catch (_) {
          emitMerged();
        }
      },
      onCancel: () async {
        await firestoreSub?.cancel();
        await localSub?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Stream<OrderModel?> watchOrderById(String orderId) {
    return watchCustomerOrders().map((orders) {
      for (final order in orders) {
        if (order.id == orderId) return order;
      }
      return null;
    });
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    final now = DateTime.now();
    final idx = _localOrders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final existing = _localOrders[idx];
      if (existing.status != OrderStatus.pending) {
        throw StateError('يمكن إلغاء الطلبات التي مازالت قيد الانتظار فقط.');
      }
      _localOrders[idx] = OrderModel(
        id: existing.id,
        customerId: existing.customerId,
        pharmacyId: existing.pharmacyId,
        items: existing.items,
        totalPrice: existing.totalPrice,
        deliveryFee: existing.deliveryFee,
        deliveryAddress: existing.deliveryAddress,
        status: OrderStatus.cancelled,
        rejectionReason: existing.rejectionReason,
        createdAt: existing.createdAt,
        updatedAt: now,
      );
      _emitLocalOrders();
    }

    final firestore = _tryGetFirestore();
    if (firestore != null) {
      try {
        await firestore
            .collection(FirestoreCollections.orders)
            .doc(orderId)
            .update({
              FirestoreFields.status: OrderStatus.cancelled.value,
              FirestoreFields.updatedAt: Timestamp.fromDate(now),
            })
            .timeout(const Duration(seconds: 4));
      } catch (_) {
        // Already updated in local store
      }
    }
  }

  /// Updates an order's status in local reactive cache (useful for testing
  /// live tracking updates).
  void updateLocalOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? rejectionReason,
  }) {
    final idx = _localOrders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final existing = _localOrders[idx];
    _localOrders[idx] = OrderModel(
      id: existing.id,
      customerId: existing.customerId,
      pharmacyId: existing.pharmacyId,
      items: existing.items,
      totalPrice: existing.totalPrice,
      deliveryFee: existing.deliveryFee,
      deliveryAddress: existing.deliveryAddress,
      status: newStatus,
      rejectionReason: rejectionReason ?? existing.rejectionReason,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    _emitLocalOrders();
  }

  @override
  Future<List<AddressModel>> getSavedAddresses([String? customerId]) async {
    final targetId = customerId ?? currentCustomerId;
    final firestore = _tryGetFirestore();
    if (firestore != null) {
      try {
        final snapshot = await firestore
            .collection(FirestoreCollections.addresses)
            .where(FirestoreFields.userId, isEqualTo: targetId)
            .get()
            .timeout(const Duration(seconds: 3));
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map(
                (doc) => AddressModel.fromMap(doc.data(), documentId: doc.id),
              )
              .toList();
        }
      } catch (_) {
        // Fallback to local addresses
      }
    }
    return _localAddresses.where((a) => a.userId == targetId).toList();
  }

  @override
  Future<AddressModel> saveAddress(AddressModel address) async {
    final now = DateTime.now();
    final customerId = currentCustomerId;
    final firestore = _tryGetFirestore();

    final newId = address.id.isNotEmpty
        ? address.id
        : (firestore != null
            ? firestore.collection(FirestoreCollections.addresses).doc().id
            : 'addr_${now.millisecondsSinceEpoch}');

    final saved = AddressModel(
      id: newId,
      userId: customerId,
      label: address.label,
      address: address.address,
      phone: address.phone,
      latitude: address.latitude,
      longitude: address.longitude,
      isDefault: address.isDefault,
      createdAt: address.createdAt,
      updatedAt: now,
    );

    if (saved.isDefault) {
      for (int i = 0; i < _localAddresses.length; i++) {
        final existing = _localAddresses[i];
        if (existing.isDefault) {
          _localAddresses[i] = AddressModel(
            id: existing.id,
            userId: existing.userId,
            label: existing.label,
            address: existing.address,
            phone: existing.phone,
            latitude: existing.latitude,
            longitude: existing.longitude,
            isDefault: false,
            createdAt: existing.createdAt,
            updatedAt: existing.updatedAt,
          );
        }
      }
    }

    final idx = _localAddresses.indexWhere((a) => a.id == saved.id);
    if (idx != -1) {
      _localAddresses[idx] = saved;
    } else {
      _localAddresses.insert(0, saved);
    }

    if (firestore != null) {
      try {
        await firestore
            .collection(FirestoreCollections.addresses)
            .doc(saved.id)
            .set(saved.toMap())
            .timeout(const Duration(seconds: 4));
      } catch (_) {
        // Saved locally
      }
    }

    return saved;
  }

  void _upsertLocalOrder(OrderModel order) {
    final idx = _localOrders.indexWhere((o) => o.id == order.id);
    if (idx != -1) {
      _localOrders[idx] = order;
    } else {
      _localOrders.insert(0, order);
    }
  }

  List<OrderModel> _sortedLocalOrders(String customerId) {
    final list =
        _localOrders.where((o) => o.customerId == customerId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<OrderModel> _mergeOrders(
    List<OrderModel> remote,
    List<OrderModel> local,
  ) {
    final byId = <String, OrderModel>{};
    for (final o in local) {
      byId[o.id] = o;
    }
    for (final o in remote) {
      byId[o.id] = o;
    }
    final merged = byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  Stream<List<OrderModel>> _localOrdersStream(String customerId) async* {
    yield _sortedLocalOrders(customerId);
    yield* _ordersController.stream.map((_) => _sortedLocalOrders(customerId));
  }

  void _emitLocalOrders() {
    if (!_ordersController.isClosed) {
      _ordersController.add(List.unmodifiable(_localOrders));
    }
  }

  void dispose() {
    _ordersController.close();
  }
}

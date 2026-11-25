import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:depi_final_project/core/enums/medicine_form.dart';
import 'package:depi_final_project/core/models/address_model.dart';
import 'package:depi_final_project/core/models/order_model.dart';
import 'package:depi_final_project/features/customer/cart/data/models/cart_pharmacy_group.dart';
import 'package:depi_final_project/features/customer/cart/logic/cubits/customer_cart_cubit.dart';
import 'package:depi_final_project/features/customer/orders/data/repositories/customer_order_repository.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/repositories/firebase_pharmacy_details_repository.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/data/repositories/firebase_pharmacy_search_repository.dart';
import 'customer_orders_state.dart';

class CustomerOrdersCubit extends Cubit<CustomerOrdersState> {
  final CustomerOrderRepository repository;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  CustomerOrdersCubit({required this.repository})
    : super(const CustomerOrdersState());

  Future<void> loadInitialData() async {
    emit(state.copyWith(status: CustomerOrdersStatus.loading, clearError: true));

    _ordersSubscription?.cancel();
    _ordersSubscription = repository.watchCustomerOrders().listen(
      (orders) {
        emit(
          state.copyWith(
            orders: orders,
            status: state.status == CustomerOrdersStatus.submitting
                ? CustomerOrdersStatus.submitting
                : CustomerOrdersStatus.loaded,
            clearError: true,
          ),
        );
      },
      onError: (dynamic error) {
        emit(
          state.copyWith(
            status: CustomerOrdersStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );

    try {
      final addresses = await repository.getSavedAddresses();
      AddressModel? defaultAddr;
      if (addresses.isNotEmpty) {
        defaultAddr = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
      }
      emit(
        state.copyWith(
          savedAddresses: addresses,
          selectedAddress: state.selectedAddress ?? defaultAddr,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void setFilter(OrderHistoryFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  void selectAddress(AddressModel address) {
    emit(state.copyWith(selectedAddress: address));
  }

  Future<AddressModel?> addOrUpdateAddress({
    required String label,
    required String addressLine,
    required String phone,
    double latitude = 29.9602,
    double longitude = 31.2569,
    bool makeDefault = true,
  }) async {
    final now = DateTime.now();
    final newAddress = AddressModel(
      id: '',
      userId: repository.currentCustomerId,
      label: label.trim(),
      address: addressLine.trim(),
      phone: phone.trim(),
      latitude: latitude,
      longitude: longitude,
      isDefault: makeDefault,
      createdAt: now,
      updatedAt: now,
    );

    try {
      final saved = await repository.saveAddress(newAddress);
      final refreshed = await repository.getSavedAddresses();
      emit(
        state.copyWith(
          savedAddresses: refreshed,
          selectedAddress: saved,
          clearError: true,
        ),
      );
      return saved;
    } catch (error) {
      emit(
        state.copyWith(
          status: CustomerOrdersStatus.error,
          errorMessage: error.toString(),
        ),
      );
      return null;
    }
  }

  Future<List<OrderModel>> placeOrdersFromCart({
    required CustomerCartCubit cartCubit,
    required List<CartPharmacyGroup> selectedGroups,
    double deliveryFeePerPharmacy = 15.0,
  }) async {
    final addressMap = state.selectedAddressMap;
    if (selectedGroups.isEmpty) {
      emit(
        state.copyWith(
          status: CustomerOrdersStatus.error,
          errorMessage: 'يرجى تحديد صيدلية واحدة على الأقل لإتمام الطلب.',
        ),
      );
      return [];
    }
    if (addressMap == null) {
      emit(
        state.copyWith(
          status: CustomerOrdersStatus.error,
          errorMessage: 'يرجى اختيار أو إضافة عنوان التوصيل أولاً.',
        ),
      );
      return [];
    }

    emit(
      state.copyWith(
        status: CustomerOrdersStatus.submitting,
        clearError: true,
      ),
    );

    try {
      final createdOrders = await repository.createOrdersFromCart(
        pharmacyGroups: selectedGroups,
        deliveryAddress: addressMap,
        deliveryFeePerPharmacy: deliveryFeePerPharmacy,
      );

      for (final group in selectedGroups) {
        cartCubit.clearPharmacy(group.pharmacyId);
      }

      emit(
        state.copyWith(
          status: CustomerOrdersStatus.loaded,
          lastCreatedOrders: createdOrders,
          clearError: true,
        ),
      );
      return createdOrders;
    } catch (error) {
      emit(
        state.copyWith(
          status: CustomerOrdersStatus.error,
          errorMessage: error.toString(),
        ),
      );
      return [];
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      await repository.cancelOrder(orderId);
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          errorMessage: error.toString(),
        ),
      );
      return false;
    }
  }

  /// Adds all items from a previous [OrderModel] back into the customer's cart.
  int reorderToCart(OrderModel order, CustomerCartCubit cartCubit) {
    final pharmacy = _resolvePharmacy(order.pharmacyId);
    final inventory =
        FirebasePharmacyDetailsRepository.getInventoryForPharmacy(
          order.pharmacyId,
        );

    int addedCount = 0;
    for (final orderItem in order.items) {
      PharmacyInventoryItemModel? matchedItem;
      for (final inv in inventory) {
        if (inv.medicineId == orderItem.medicineId ||
            inv.name == orderItem.medicineName) {
          matchedItem = inv;
          break;
        }
      }

      final itemToAdd =
          matchedItem ??
          PharmacyInventoryItemModel(
            id: '${order.pharmacyId}_${orderItem.medicineId}',
            pharmacyId: order.pharmacyId,
            medicineId: orderItem.medicineId,
            name: orderItem.medicineName,
            genericName: orderItem.medicineName,
            description: orderItem.strength,
            category: 'جميع الأدوية',
            price: orderItem.unitPrice,
            quantity: orderItem.quantity > 0 ? orderItem.quantity : 1,
            unitDescription: orderItem.strength,
            form: MedicineForm.tablet,
            isAvailable: true,
            publicVisible: true,
            updatedAt: DateTime.now(),
          );

      if (!itemToAdd.isAvailable || itemToAdd.quantity <= 0) {
        continue;
      }

      for (int i = 0; i < orderItem.quantity; i++) {
        if (cartCubit.addToCart(itemToAdd, pharmacy)) {
          addedCount++;
        }
      }
    }
    return addedCount;
  }

  PharmacyDetailModel _resolvePharmacy(String pharmacyId) {
    for (final p in FirebasePharmacySearchRepository.defaultPharmacies) {
      if (p.id == pharmacyId) return p;
    }
    return FirebasePharmacyDetailsRepository.getPharmacyById(pharmacyId);
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}

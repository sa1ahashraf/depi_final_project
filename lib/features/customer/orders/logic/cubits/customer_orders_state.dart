import 'package:depi_final_project/core/constants/firestore_fields.dart';
import 'package:depi_final_project/core/enums/order_status.dart';
import 'package:depi_final_project/core/models/address_model.dart';
import 'package:depi_final_project/core/models/order_model.dart';

enum CustomerOrdersStatus { initial, loading, loaded, submitting, error }

enum OrderHistoryFilter {
  all('الكل'),
  active('النشطة'),
  completed('المكتملة'),
  closed('الملغاة والمرفوضة');

  final String arabicLabel;
  const OrderHistoryFilter(this.arabicLabel);
}

class CustomerOrdersState {
  final CustomerOrdersStatus status;
  final List<OrderModel> orders;
  final OrderHistoryFilter filter;
  final List<AddressModel> savedAddresses;
  final AddressModel? selectedAddress;
  final List<OrderModel> lastCreatedOrders;
  final String? errorMessage;

  const CustomerOrdersState({
    this.status = CustomerOrdersStatus.initial,
    this.orders = const [],
    this.filter = OrderHistoryFilter.all,
    this.savedAddresses = const [],
    this.selectedAddress,
    this.lastCreatedOrders = const [],
    this.errorMessage,
  });

  int get activeOrdersCount =>
      orders.where((o) => !o.status.isFinal).length;

  List<OrderModel> get filteredOrders {
    switch (filter) {
      case OrderHistoryFilter.all:
        return orders;
      case OrderHistoryFilter.active:
        return orders.where((o) => !o.status.isFinal).toList();
      case OrderHistoryFilter.completed:
        return orders
            .where((o) => o.status == OrderStatus.completed)
            .toList();
      case OrderHistoryFilter.closed:
        return orders
            .where(
              (o) =>
                  o.status == OrderStatus.cancelled ||
                  o.status == OrderStatus.rejected,
            )
            .toList();
    }
  }

  Map<String, dynamic>? get selectedAddressMap {
    final addr = selectedAddress;
    if (addr == null) return null;
    return {
      FirestoreFields.label: addr.label,
      FirestoreFields.address: addr.address,
      FirestoreFields.phone: addr.phone,
      FirestoreFields.latitude: addr.latitude,
      FirestoreFields.longitude: addr.longitude,
    };
  }

  CustomerOrdersState copyWith({
    CustomerOrdersStatus? status,
    List<OrderModel>? orders,
    OrderHistoryFilter? filter,
    List<AddressModel>? savedAddresses,
    AddressModel? selectedAddress,
    List<OrderModel>? lastCreatedOrders,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CustomerOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      filter: filter ?? this.filter,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      lastCreatedOrders: lastCreatedOrders ?? this.lastCreatedOrders,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

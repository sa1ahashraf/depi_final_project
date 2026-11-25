import 'package:depi_final_project/core/models/address_model.dart';
import 'package:depi_final_project/core/models/order_model.dart';
import 'package:depi_final_project/features/customer/cart/data/models/cart_pharmacy_group.dart';

/// Contract for customer-side order creation, tracking, and saved addresses.
abstract class CustomerOrderRepository {
  String get currentCustomerId;

  /// Creates one [OrderModel] per selected [CartPharmacyGroup] using the
  /// agreed order contract ([OrderModel] / [OrderItemModel]).
  Future<List<OrderModel>> createOrdersFromCart({
    required List<CartPharmacyGroup> pharmacyGroups,
    required Map<String, dynamic> deliveryAddress,
    double deliveryFeePerPharmacy = 15.0,
  });

  /// Live stream of all orders belonging to [customerId], newest first.
  Stream<List<OrderModel>> watchCustomerOrders([String? customerId]);

  /// Live stream of a single order by [orderId].
  Stream<OrderModel?> watchOrderById(String orderId);

  /// Cancels an order when it is still in `pending` state.
  Future<void> cancelOrder(String orderId);

  /// Returns saved delivery addresses for the customer.
  Future<List<AddressModel>> getSavedAddresses([String? customerId]);

  /// Persists or updates a delivery address for the customer.
  Future<AddressModel> saveAddress(AddressModel address);
}

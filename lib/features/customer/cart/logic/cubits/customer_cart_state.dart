import 'package:depi_final_project/features/customer/cart/data/models/cart_pharmacy_group.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/cart_item_model.dart';

class CustomerCartState {
  final Map<String, CartItemModel> items;
  final Set<String> selectedPharmacyIds;

  const CustomerCartState({
    this.items = const {},
    this.selectedPharmacyIds = const {},
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  int get totalItemCount =>
      items.values.fold(0, (sum, item) => sum + item.quantity);

  double get grandTotal =>
      items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  List<CartPharmacyGroup> get pharmacyGroups {
    final Map<String, List<CartItemModel>> grouped = {};
    for (final cartItem in items.values) {
      final phId = cartItem.effectivePharmacyId;
      grouped.putIfAbsent(phId, () => []).add(cartItem);
    }

    return grouped.entries.map((entry) {
      final firstItem = entry.value.first;
      final phId = entry.key;
      return CartPharmacyGroup(
        pharmacyId: phId,
        pharmacyName: firstItem.effectivePharmacyName,
        pharmacyAddress: firstItem.pharmacyAddress,
        pharmacyDeliveryTime: firstItem.pharmacyDeliveryTime,
        pharmacy: firstItem.pharmacy,
        items: entry.value,
        isSelected: selectedPharmacyIds.contains(phId),
      );
    }).toList();
  }

  double get selectedTotal {
    double total = 0.0;
    for (final group in pharmacyGroups) {
      if (group.isSelected) {
        total += group.subtotal;
      }
    }
    return total;
  }

  int get selectedItemCount {
    int count = 0;
    for (final group in pharmacyGroups) {
      if (group.isSelected) {
        count += group.itemCount;
      }
    }
    return count;
  }

  int get selectedPharmacyCount {
    return pharmacyGroups.where((g) => g.isSelected).length;
  }

  bool get isAllSelected {
    if (pharmacyGroups.isEmpty) return false;
    return pharmacyGroups.every((g) => g.isSelected);
  }

  CustomerCartState copyWith({
    Map<String, CartItemModel>? items,
    Set<String>? selectedPharmacyIds,
  }) {
    return CustomerCartState(
      items: items ?? this.items,
      selectedPharmacyIds: selectedPharmacyIds ?? this.selectedPharmacyIds,
    );
  }
}

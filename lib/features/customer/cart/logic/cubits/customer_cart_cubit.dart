import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/cart_item_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';
import 'customer_cart_state.dart';

class CustomerCartCubit extends Cubit<CustomerCartState> {
  CustomerCartCubit({CustomerCartState? initialState})
    : super(initialState ?? const CustomerCartState());

  bool addToCart(
    PharmacyInventoryItemModel item,
    PharmacyDetailModel pharmacy,
  ) {
    if (!item.isAvailable || item.quantity <= 0) {
      return false;
    }

    final key = '${pharmacy.id}_${item.id}';
    final updatedItems = Map<String, CartItemModel>.from(state.items);
    final currentQuantity = updatedItems[key]?.quantity ?? 0;

    updatedItems[key] = CartItemModel(
      item: item,
      quantity: currentQuantity + 1,
      pharmacyId: pharmacy.id,
      pharmacyName: pharmacy.name,
      pharmacyAddress: pharmacy.address,
      pharmacyDeliveryTime: pharmacy.deliveryTime,
      pharmacy: pharmacy,
    );

    final updatedSelections = Set<String>.from(state.selectedPharmacyIds)
      ..add(pharmacy.id);

    emit(
      state.copyWith(
        items: updatedItems,
        selectedPharmacyIds: updatedSelections,
      ),
    );
    return true;
  }

  void incrementQuantity(String cartKey) {
    final existing = state.items[cartKey];
    if (existing == null) return;

    final updatedItems = Map<String, CartItemModel>.from(state.items);
    updatedItems[cartKey] = existing.copyWith(
      quantity: existing.quantity + 1,
    );

    emit(state.copyWith(items: updatedItems));
  }

  void decrementQuantity(String cartKey) {
    final existing = state.items[cartKey];
    if (existing == null) return;

    final updatedItems = Map<String, CartItemModel>.from(state.items);

    if (existing.quantity <= 1) {
      updatedItems.remove(cartKey);
    } else {
      updatedItems[cartKey] = existing.copyWith(
        quantity: existing.quantity - 1,
      );
    }

    // If no more items from this pharmacy, remove from selections
    final remainingPharmacies =
        updatedItems.values.map((e) => e.effectivePharmacyId).toSet();
    final updatedSelections = Set<String>.from(state.selectedPharmacyIds)
      ..retainAll(remainingPharmacies);

    emit(
      state.copyWith(
        items: updatedItems,
        selectedPharmacyIds: updatedSelections,
      ),
    );
  }

  void removeFromCart(String cartKey) {
    final existing = state.items[cartKey];
    if (existing == null) return;

    final updatedItems = Map<String, CartItemModel>.from(state.items);
    updatedItems.remove(cartKey);

    final remainingPharmacies =
        updatedItems.values.map((e) => e.effectivePharmacyId).toSet();
    final updatedSelections = Set<String>.from(state.selectedPharmacyIds)
      ..retainAll(remainingPharmacies);

    emit(
      state.copyWith(
        items: updatedItems,
        selectedPharmacyIds: updatedSelections,
      ),
    );
  }

  void togglePharmacySelection(String pharmacyId) {
    final updatedSelections = Set<String>.from(state.selectedPharmacyIds);
    if (updatedSelections.contains(pharmacyId)) {
      updatedSelections.remove(pharmacyId);
    } else {
      updatedSelections.add(pharmacyId);
    }

    emit(state.copyWith(selectedPharmacyIds: updatedSelections));
  }

  void selectOnlyPharmacy(String pharmacyId) {
    emit(state.copyWith(selectedPharmacyIds: {pharmacyId}));
  }

  void selectAllPharmacies() {
    final allPharmacies =
        state.items.values.map((e) => e.effectivePharmacyId).toSet();
    emit(state.copyWith(selectedPharmacyIds: allPharmacies));
  }

  void setSelectedPharmacies(Set<String> pharmacyIds) {
    final validIds =
        state.items.values.map((e) => e.effectivePharmacyId).toSet();
    final filtered = pharmacyIds.where(validIds.contains).toSet();
    emit(state.copyWith(selectedPharmacyIds: filtered));
  }

  void deselectAllPharmacies() {
    emit(state.copyWith(selectedPharmacyIds: {}));
  }

  void clearPharmacy(String pharmacyId) {
    final updatedItems = Map<String, CartItemModel>.from(state.items)
      ..removeWhere((key, item) => item.effectivePharmacyId == pharmacyId);

    final updatedSelections = Set<String>.from(state.selectedPharmacyIds)
      ..remove(pharmacyId);

    emit(
      state.copyWith(
        items: updatedItems,
        selectedPharmacyIds: updatedSelections,
      ),
    );
  }

  void clearCart() {
    emit(const CustomerCartState());
  }
}

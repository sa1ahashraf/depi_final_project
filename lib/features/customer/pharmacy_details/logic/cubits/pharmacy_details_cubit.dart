import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/cart_item_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/repositories/firebase_pharmacy_details_repository.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/repositories/pharmacy_details_repository.dart';
import 'pharmacy_details_state.dart';

class PharmacyDetailsCubit extends Cubit<PharmacyDetailsState> {
  final PharmacyDetailsRepository repository;
  StreamSubscription<PharmacyDetailModel>? _pharmacySubscription;
  StreamSubscription<List<PharmacyInventoryItemModel>>? _inventorySubscription;

  PharmacyDetailsCubit({
    required this.repository,
    String pharmacyId = 'pharmacy_al_nour',
    PharmacyDetailModel? initialPharmacy,
    String initialSearchQuery = '',
  }) : super(
        PharmacyDetailsState(
          status: PharmacyDetailsStatus.loaded,
          pharmacy: initialPharmacy ??
              FirebasePharmacyDetailsRepository.getPharmacyById(pharmacyId),
          allItems:
              FirebasePharmacyDetailsRepository.getInventoryForPharmacy(pharmacyId),
          filteredItems: _filterItems(
            FirebasePharmacyDetailsRepository.getInventoryForPharmacy(pharmacyId),
            'جميع الأدوية',
            initialSearchQuery,
          ),
          searchQuery: initialSearchQuery,
          categories: const [
            'جميع الأدوية (120)',
            'مسكنات وحرارة',
            'البرد والإنفلونزا',
            'فيتامينات ومناعة',
            'أدوية الجهاز الهضمي',
          ],
        ),
      );

  void loadPharmacyDetails(String pharmacyId) {
    emit(state.copyWith(status: PharmacyDetailsStatus.loading));

    _pharmacySubscription?.cancel();
    _inventorySubscription?.cancel();

    _pharmacySubscription = repository
        .getPharmacyDetailsStream(pharmacyId)
        .listen(
          (pharmacy) {
            emit(
              state.copyWith(
                pharmacy: pharmacy,
                status: PharmacyDetailsStatus.loaded,
              ),
            );
          },
          onError: (dynamic error) {
            emit(
              state.copyWith(
                status: PharmacyDetailsStatus.error,
                errorMessage: error.toString(),
              ),
            );
          },
        );

    _inventorySubscription = repository
        .getPharmacyInventoryStream(pharmacyId)
        .listen(
          (items) {
            final categories = _extractCategories(items);
            final filtered = _filterItems(
              items,
              state.selectedCategory,
              state.searchQuery,
            );
            emit(
              state.copyWith(
                allItems: items,
                filteredItems: filtered,
                categories: categories,
                status: PharmacyDetailsStatus.loaded,
              ),
            );
          },
          onError: (dynamic error) {
            emit(
              state.copyWith(
                status: PharmacyDetailsStatus.error,
                errorMessage: error.toString(),
              ),
            );
          },
        );
  }

  void selectCategory(String category) {
    // Clean string comparison (strip counts like "(120)")
    final cleanCategory = _cleanCategoryName(category);
    final filtered = _filterItems(
      state.allItems,
      cleanCategory,
      state.searchQuery,
    );
    emit(
      state.copyWith(
        selectedCategory: cleanCategory,
        filteredItems: filtered,
      ),
    );
  }

  void updateSearchQuery(String query) {
    final filtered = _filterItems(
      state.allItems,
      state.selectedCategory,
      query,
    );
    emit(
      state.copyWith(
        searchQuery: query,
        filteredItems: filtered,
      ),
    );
  }

  void clearSearch() {
    updateSearchQuery('');
  }

  bool addToCart(PharmacyInventoryItemModel item) {
    if (!item.isAvailable || item.quantity <= 0) {
      return false; // Out of stock cannot be added
    }

    final updatedCart = Map<String, CartItemModel>.from(state.cart);
    final currentQuantity = updatedCart[item.id]?.quantity ?? 0;
    final pharmacy = state.pharmacy;
    final phId = item.pharmacyId.isNotEmpty
        ? item.pharmacyId
        : (pharmacy?.id ?? 'pharmacy_al_nour');
    final phName = pharmacy?.name ?? 'صيدلية النور';

    updatedCart[item.id] = CartItemModel(
      item: item,
      quantity: currentQuantity + 1,
      pharmacyId: phId,
      pharmacyName: phName,
      pharmacyAddress: pharmacy?.address,
      pharmacyDeliveryTime: pharmacy?.deliveryTime,
      pharmacy: pharmacy,
    );

    _emitCartUpdated(updatedCart);
    return true;
  }

  void removeFromCart(PharmacyInventoryItemModel item) {
    final updatedCart = Map<String, CartItemModel>.from(state.cart);
    final existing = updatedCart[item.id];
    if (existing == null) return;

    if (existing.quantity <= 1) {
      updatedCart.remove(item.id);
    } else {
      updatedCart[item.id] = existing.copyWith(
        quantity: existing.quantity - 1,
      );
    }

    _emitCartUpdated(updatedCart);
  }

  void clearCart() {
    _emitCartUpdated({});
  }

  void setCartPreloadedForDemo() {
    // For exact match to screenshot:
    // Screenshot shows:
    // Cart total = 76 EGP
    // Cart badge = 2
    // Which matches Panadol Extra (45 EGP) + Congestal Tablets (31 EGP) = 76 EGP!
    final items =
        state.allItems.isNotEmpty
            ? state.allItems
            : FirebasePharmacyDetailsRepository.defaultInventory;
    final panadol = items.firstWhere(
      (e) => e.name.contains('Panadol'),
      orElse: () => items.first,
    );
    final congestal = items.firstWhere(
      (e) => e.name.contains('Congestal'),
      orElse: () => items.length > 1 ? items[1] : items.first,
    );
    final pharmacy = state.pharmacy;
    final phId = pharmacy?.id ?? 'pharmacy_al_nour';
    final phName = pharmacy?.name ?? 'صيدلية النور';

    final updatedCart = <String, CartItemModel>{
      panadol.id: CartItemModel(
        item: panadol,
        quantity: 1,
        pharmacyId: phId,
        pharmacyName: phName,
        pharmacyAddress: pharmacy?.address,
        pharmacyDeliveryTime: pharmacy?.deliveryTime,
        pharmacy: pharmacy,
      ),
      congestal.id: CartItemModel(
        item: congestal,
        quantity: 1,
        pharmacyId: phId,
        pharmacyName: phName,
        pharmacyAddress: pharmacy?.address,
        pharmacyDeliveryTime: pharmacy?.deliveryTime,
        pharmacy: pharmacy,
      ),
    };
    _emitCartUpdated(updatedCart);
  }

  void _emitCartUpdated(Map<String, CartItemModel> updatedCart) {
    double total = 0.0;
    int count = 0;
    for (final cartItem in updatedCart.values) {
      total += cartItem.totalPrice;
      count += cartItem.quantity;
    }

    emit(
      state.copyWith(
        cart: updatedCart,
        cartTotal: total,
        cartItemCount: count,
      ),
    );
  }

  List<String> _extractCategories(List<PharmacyInventoryItemModel> items) {
    // Dynamic count for all medicines
    final count = items.length;
    final allCategoryTitle = 'جميع الأدوية ($count)';
    final baseCategories = <String>[
      allCategoryTitle,
      'مسكنات وحرارة',
      'البرد والإنفلونزا',
      'فيتامينات ومناعة',
      'أدوية الجهاز الهضمي',
    ];

    final foundCategories = items.map((e) => e.category).toSet();
    for (final cat in foundCategories) {
      if (cat.isNotEmpty && !baseCategories.any((b) => b.contains(cat))) {
        baseCategories.add(cat);
      }
    }
    return baseCategories;
  }

  String _cleanCategoryName(String raw) {
    if (raw.startsWith('جميع الأدوية')) return 'جميع الأدوية';
    return raw.trim();
  }

  static List<PharmacyInventoryItemModel> _filterItems(
    List<PharmacyInventoryItemModel> items,
    String category,
    String query,
  ) {
    var result = items;
    if (category != 'جميع الأدوية' && !category.startsWith('جميع الأدوية')) {
      result = result.where((item) => item.category.trim() == category).toList();
    }
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isNotEmpty) {
      result = result.where((item) {
        final name = item.name.toLowerCase();
        final generic = item.genericName.toLowerCase();
        final desc = item.description.toLowerCase();
        return name.contains(cleanQuery) ||
            generic.contains(cleanQuery) ||
            desc.contains(cleanQuery);
      }).toList();
    }
    return result;
  }

  @override
  Future<void> close() {
    _pharmacySubscription?.cancel();
    _inventorySubscription?.cancel();
    return super.close();
  }
}

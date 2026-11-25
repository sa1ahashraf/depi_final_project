import 'package:equatable/equatable.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/cart_item_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';

enum PharmacyDetailsStatus { initial, loading, loaded, error }

class PharmacyDetailsState extends Equatable {
  final PharmacyDetailsStatus status;
  final PharmacyDetailModel? pharmacy;
  final List<PharmacyInventoryItemModel> allItems;
  final List<PharmacyInventoryItemModel> filteredItems;
  final List<String> categories;
  final String selectedCategory;
  final String searchQuery;
  final Map<String, CartItemModel> cart;
  final double cartTotal;
  final int cartItemCount;
  final String? errorMessage;

  const PharmacyDetailsState({
    this.status = PharmacyDetailsStatus.initial,
    this.pharmacy,
    this.allItems = const [],
    this.filteredItems = const [],
    this.categories = const ['جميع الأدوية (120)'],
    this.selectedCategory = 'جميع الأدوية',
    this.searchQuery = '',
    this.cart = const {},
    this.cartTotal = 0.0,
    this.cartItemCount = 0,
    this.errorMessage,
  });

  PharmacyDetailsState copyWith({
    PharmacyDetailsStatus? status,
    PharmacyDetailModel? pharmacy,
    List<PharmacyInventoryItemModel>? allItems,
    List<PharmacyInventoryItemModel>? filteredItems,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
    Map<String, CartItemModel>? cart,
    double? cartTotal,
    int? cartItemCount,
    String? errorMessage,
  }) {
    return PharmacyDetailsState(
      status: status ?? this.status,
      pharmacy: pharmacy ?? this.pharmacy,
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      cart: cart ?? this.cart,
      cartTotal: cartTotal ?? this.cartTotal,
      cartItemCount: cartItemCount ?? this.cartItemCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    pharmacy,
    allItems,
    filteredItems,
    categories,
    selectedCategory,
    searchQuery,
    cart,
    cartTotal,
    cartItemCount,
    errorMessage,
  ];
}

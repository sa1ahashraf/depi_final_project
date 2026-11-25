import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:depi_final_project/core/enums/medicine_form.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';
import '../../data/models/pharmacy_search_result_model.dart';
import '../../data/models/pharmacy_sort_option.dart';
import '../../data/models/search_filter_options.dart';
import '../../data/repositories/firebase_pharmacy_search_repository.dart';
import '../../data/repositories/pharmacy_search_repository.dart';
import 'pharmacy_search_state.dart';

class PharmacySearchCubit extends Cubit<PharmacySearchState> {
  final PharmacySearchRepository repository;
  StreamSubscription<List<PharmacyDetailModel>>? _pharmaciesSubscription;
  StreamSubscription<List<PharmacyInventoryItemModel>>? _inventoriesSubscription;

  PharmacySearchCubit({required this.repository})
    : super(
        PharmacySearchState(
          status: PharmacySearchStatus.loaded,
          allPharmacies: FirebasePharmacySearchRepository.defaultPharmacies,
          allInventories:
              FirebasePharmacySearchRepository.generateMultiPharmacyInventory()
                  .values
                  .expand((list) => list)
                  .toList(),
        ),
      ) {
    // Process initial results immediately
    final initialResults = _computeResults(
      state.allPharmacies,
      state.allInventories,
      state.searchQuery,
      state.sortOption,
      state.filters,
    );
    emit(state.copyWith(results: initialResults));
  }

  void loadData() {
    emit(state.copyWith(status: PharmacySearchStatus.loading));

    _pharmaciesSubscription?.cancel();
    _inventoriesSubscription?.cancel();

    _pharmaciesSubscription = repository.getPharmaciesStream().listen(
      (pharmacies) {
        final categories = _extractCategories(state.allInventories);
        final results = _computeResults(
          pharmacies,
          state.allInventories,
          state.searchQuery,
          state.sortOption,
          state.filters,
        );
        emit(
          state.copyWith(
            allPharmacies: pharmacies,
            results: results,
            categories: categories,
            status: PharmacySearchStatus.loaded,
          ),
        );
      },
      onError: (dynamic error) {
        emit(
          state.copyWith(
            status: PharmacySearchStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );

    _inventoriesSubscription = repository.getAllInventoriesStream().listen(
      (inventories) {
        final categories = _extractCategories(inventories);
        final results = _computeResults(
          state.allPharmacies,
          inventories,
          state.searchQuery,
          state.sortOption,
          state.filters,
        );
        emit(
          state.copyWith(
            allInventories: inventories,
            results: results,
            categories: categories,
            status: PharmacySearchStatus.loaded,
          ),
        );
      },
      onError: (dynamic error) {
        emit(
          state.copyWith(
            status: PharmacySearchStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  void updateSearchQuery(String query) {
    final results = _computeResults(
      state.allPharmacies,
      state.allInventories,
      query,
      state.sortOption,
      state.filters,
    );
    emit(state.copyWith(searchQuery: query, results: results));
  }

  void clearSearch() {
    updateSearchQuery('');
  }

  void updateSortOption(PharmacySortOption option) {
    final results = _computeResults(
      state.allPharmacies,
      state.allInventories,
      state.searchQuery,
      option,
      state.filters,
    );
    emit(state.copyWith(sortOption: option, results: results));
  }

  void updateFilters(SearchFilterOptions filters) {
    final results = _computeResults(
      state.allPharmacies,
      state.allInventories,
      state.searchQuery,
      state.sortOption,
      filters,
    );
    emit(state.copyWith(filters: filters, results: results));
  }

  void resetFilters() {
    updateFilters(const SearchFilterOptions());
  }

  void selectCategory(String category) {
    final newFilters = state.filters.copyWith(selectedCategory: category);
    updateFilters(newFilters);
  }

  static List<PharmacySearchResultModel> _computeResults(
    List<PharmacyDetailModel> pharmacies,
    List<PharmacyInventoryItemModel> inventories,
    String query,
    PharmacySortOption sortOption,
    SearchFilterOptions filters,
  ) {
    final cleanQuery = query.trim().toLowerCase();
    final results = <PharmacySearchResultModel>[];

    // Group inventories by pharmacyId
    final inventoryByPharmacy = <String, List<PharmacyInventoryItemModel>>{};
    for (final item in inventories) {
      inventoryByPharmacy.putIfAbsent(item.pharmacyId, () => []).add(item);
    }

    for (final pharmacy in pharmacies) {
      // 1. Pharmacy-level filtering
      if (filters.openOnly && !pharmacy.isOpen) continue;
      if (filters.verifiedOnly && !pharmacy.isVerified) continue;

      final deliveryMinutes = _parseDeliveryMinutes(pharmacy.deliveryTime);
      if (filters.fastDeliveryOnly && deliveryMinutes > 30) continue;

      if (filters.digitalPaymentOnly) {
        final hasDigital = pharmacy.paymentMethods.any(
          (p) =>
              p.contains('InstaPay') ||
              p.contains('إكسترا باي') ||
              p.contains('فودافون كاش'),
        );
        if (!hasDigital) continue;
      }

      final pharmacyItems = inventoryByPharmacy[pharmacy.id] ?? [];

      // 2. Medicine-level filtering
      // By default, matched items only include medicines that are in stock and available
      var matched = pharmacyItems
          .where((item) => item.isAvailable && item.quantity > 0)
          .toList();

      // Category filter
      if (filters.selectedCategory != 'الكل') {
        matched =
            matched
                .where(
                  (item) =>
                      item.category.trim() == filters.selectedCategory.trim(),
                )
                .toList();
      }

      // Stock filter
      if (filters.inStockOnly) {
        matched =
            matched.where((item) => item.isAvailable && item.quantity > 0).toList();
      }

      // Dosage Form filter
      if (filters.medicineForm != null && filters.medicineForm!.isNotEmpty) {
        final formName = filters.medicineForm!;
        matched =
            matched.where((item) {
              if (formName.contains('أقراص') && item.form == MedicineForm.tablet) {
                return true;
              }
              if (formName.contains('كبسول') && item.form == MedicineForm.capsule) {
                return true;
              }
              if (formName.contains('شراب') && item.form == MedicineForm.syrup) {
                return true;
              }
              return item.unitDescription.contains(formName) ||
                  item.name.contains(formName);
            }).toList();
      }

      // Query filter: Verify medicine is available in stock before returning pharmacy
      if (cleanQuery.isNotEmpty) {
        final matchesPharmacyName = pharmacy.name.toLowerCase().contains(cleanQuery);
        if (!matchesPharmacyName) {
          matched =
              matched.where((item) {
                // Must be available in stock in this pharmacy
                if (!item.isAvailable || item.quantity <= 0) return false;

                final name = item.name.toLowerCase();
                final generic = item.genericName.toLowerCase();
                final desc = item.description.toLowerCase();
                return name.contains(cleanQuery) ||
                    generic.contains(cleanQuery) ||
                    desc.contains(cleanQuery);
              }).toList();
          // If query was medicine specific and no in-stock medicine matched, skip pharmacy
          if (matched.isEmpty) continue;
        }
      }

      // If user filtered by category, form, or inStockOnly and 0 medicines matched, skip pharmacy
      if ((filters.selectedCategory != 'الكل' ||
              (filters.medicineForm != null && filters.medicineForm!.isNotEmpty) ||
              filters.inStockOnly) &&
          matched.isEmpty) {
        continue;
      }

      // Compute lowest price
      double? lowestPrice;
      if (matched.isNotEmpty) {
        lowestPrice = matched.map((e) => e.price).reduce((a, b) => a < b ? a : b);
      }

      results.add(
        PharmacySearchResultModel(
          pharmacy: pharmacy,
          matchedMedicines: matched,
          totalMedicineCount: pharmacyItems.length,
          lowestPrice: lowestPrice,
          deliveryMinutes: deliveryMinutes,
        ),
      );
    }

    // 3. Sorting
    switch (sortOption) {
      case PharmacySortOption.nearest:
        results.sort(
          (a, b) => a.pharmacy.distanceKm.compareTo(b.pharmacy.distanceKm),
        );
        break;
      case PharmacySortOption.highestRating:
        results.sort((a, b) => b.pharmacy.rating.compareTo(a.pharmacy.rating));
        break;
      case PharmacySortOption.fastestDelivery:
        results.sort((a, b) => a.deliveryMinutes.compareTo(b.deliveryMinutes));
        break;
      case PharmacySortOption.lowestPrice:
        results.sort((a, b) {
          final priceA = a.lowestPrice ?? double.infinity;
          final priceB = b.lowestPrice ?? double.infinity;
          if (priceA != priceB) {
            return priceA.compareTo(priceB);
          }
          return a.pharmacy.distanceKm.compareTo(b.pharmacy.distanceKm);
        });
        break;
    }

    return results;
  }

  static int _parseDeliveryMinutes(String raw) {
    final matches = RegExp(r'\d+').allMatches(raw).map((m) => int.parse(m.group(0)!)).toList();
    if (matches.isEmpty) return 30;
    if (matches.length == 1) return matches.first;
    // Average or upper bound (e.g. 20-30 -> 25)
    return ((matches[0] + matches[1]) / 2).round();
  }

  static List<String> _extractCategories(
    List<PharmacyInventoryItemModel> items,
  ) {
    final list = <String>[
      'الكل',
      'مسكنات وحرارة',
      'البرد والإنفلونزا',
      'فيتامينات ومناعة',
      'أدوية الجهاز الهضمي',
      'مضادات حيوية',
    ];
    for (final item in items) {
      if (item.category.isNotEmpty && !list.contains(item.category)) {
        list.add(item.category);
      }
    }
    return list;
  }

  @override
  Future<void> close() {
    _pharmaciesSubscription?.cancel();
    _inventoriesSubscription?.cancel();
    return super.close();
  }
}

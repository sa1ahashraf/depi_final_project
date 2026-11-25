import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';
import '../../data/models/pharmacy_search_result_model.dart';
import '../../data/models/pharmacy_sort_option.dart';
import '../../data/models/search_filter_options.dart';

enum PharmacySearchStatus {
  initial,
  loading,
  loaded,
  error,
}

class PharmacySearchState {
  final PharmacySearchStatus status;
  final String searchQuery;
  final PharmacySortOption sortOption;
  final SearchFilterOptions filters;
  final List<PharmacyDetailModel> allPharmacies;
  final List<PharmacyInventoryItemModel> allInventories;
  final List<PharmacySearchResultModel> results;
  final List<String> categories;
  final String? errorMessage;

  const PharmacySearchState({
    this.status = PharmacySearchStatus.initial,
    this.searchQuery = '',
    this.sortOption = PharmacySortOption.nearest,
    this.filters = const SearchFilterOptions(),
    this.allPharmacies = const [],
    this.allInventories = const [],
    this.results = const [],
    this.categories = const [
      'الكل',
      'مسكنات وحرارة',
      'البرد والإنفلونزا',
      'فيتامينات ومناعة',
      'أدوية الجهاز الهضمي',
      'مضادات حيوية',
    ],
    this.errorMessage,
  });

  PharmacySearchState copyWith({
    PharmacySearchStatus? status,
    String? searchQuery,
    PharmacySortOption? sortOption,
    SearchFilterOptions? filters,
    List<PharmacyDetailModel>? allPharmacies,
    List<PharmacyInventoryItemModel>? allInventories,
    List<PharmacySearchResultModel>? results,
    List<String>? categories,
    String? errorMessage,
  }) {
    return PharmacySearchState(
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      filters: filters ?? this.filters,
      allPharmacies: allPharmacies ?? this.allPharmacies,
      allInventories: allInventories ?? this.allInventories,
      results: results ?? this.results,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

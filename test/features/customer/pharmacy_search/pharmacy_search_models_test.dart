import 'package:flutter_test/flutter_test.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/data/models/pharmacy_search_result_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/data/models/pharmacy_sort_option.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/data/models/search_filter_options.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/data/repositories/firebase_pharmacy_search_repository.dart';

void main() {
  group('PharmacySortOption Tests', () {
    test('has valid labels and icons for all options', () {
      for (final option in PharmacySortOption.values) {
        expect(option.label.isNotEmpty, true);
        expect(option.icon, isNotNull);
      }
      expect(PharmacySortOption.nearest.label, 'الأقرب إليك');
      expect(PharmacySortOption.highestRating.label, 'الأعلى تقييماً');
      expect(PharmacySortOption.fastestDelivery.label, 'الأسرع توصيلاً');
      expect(PharmacySortOption.lowestPrice.label, 'الأقل سعراً');
    });
  });

  group('SearchFilterOptions Tests', () {
    test('default state has 0 active filters', () {
      const filters = SearchFilterOptions();
      expect(filters.activeCount, 0);
      expect(filters.selectedCategory, 'الكل');
      expect(filters.inStockOnly, false);
      expect(filters.openOnly, false);
      expect(filters.verifiedOnly, false);
      expect(filters.fastDeliveryOnly, false);
      expect(filters.digitalPaymentOnly, false);
      expect(filters.medicineForm, isNull);
    });

    test('activeCount increments when non-default filters are set', () {
      var filters = const SearchFilterOptions(
        selectedCategory: 'مسكنات وحرارة',
        openOnly: true,
        verifiedOnly: true,
      );
      expect(filters.activeCount, 3);

      filters = filters.copyWith(fastDeliveryOnly: true, inStockOnly: true);
      expect(filters.activeCount, 5);

      final reset = filters.reset();
      expect(reset.activeCount, 0);
    });
  });

  group('PharmacySearchResultModel Tests', () {
    test('copyWith updates properties properly', () {
      final pharmacy = FirebasePharmacySearchRepository.defaultPharmacies.first;
      final result = PharmacySearchResultModel(
        pharmacy: pharmacy,
        matchedMedicines: const [],
        totalMedicineCount: 120,
        lowestPrice: 45.0,
        deliveryMinutes: 20,
      );

      final updated = result.copyWith(
        lowestPrice: 40.0,
        deliveryMinutes: 15,
      );

      expect(updated.lowestPrice, 40.0);
      expect(updated.deliveryMinutes, 15);
      expect(updated.pharmacy.name, pharmacy.name);
    });
  });
}

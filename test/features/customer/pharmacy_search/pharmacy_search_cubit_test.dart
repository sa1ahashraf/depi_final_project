import 'package:flutter_test/flutter_test.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/data/models/pharmacy_sort_option.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/data/models/search_filter_options.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/data/repositories/firebase_pharmacy_search_repository.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/data/repositories/pharmacy_search_repository.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/logic/cubits/pharmacy_search_cubit.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/logic/cubits/pharmacy_search_state.dart';

class MockPharmacySearchRepository implements PharmacySearchRepository {
  @override
  Stream<List<PharmacyDetailModel>> getPharmaciesStream() async* {
    yield FirebasePharmacySearchRepository.defaultPharmacies;
  }

  @override
  Stream<List<PharmacyInventoryItemModel>> getAllInventoriesStream() async* {
    final multiInventory =
        FirebasePharmacySearchRepository.generateMultiPharmacyInventory();
    yield multiInventory.values.expand((list) => list).toList();
  }

  @override
  Future<List<PharmacyDetailModel>> getPharmacies() async {
    return FirebasePharmacySearchRepository.defaultPharmacies;
  }

  @override
  Future<List<PharmacyInventoryItemModel>> getInventoryForPharmacy(
    String pharmacyId,
  ) async {
    final multiInventory =
        FirebasePharmacySearchRepository.generateMultiPharmacyInventory();
    return multiInventory[pharmacyId] ?? [];
  }
}

void main() {
  late MockPharmacySearchRepository repository;
  late PharmacySearchCubit cubit;

  setUp(() {
    repository = MockPharmacySearchRepository();
    cubit = PharmacySearchCubit(repository: repository);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state sorts by nearest by default', () {
    expect(cubit.state.status, PharmacySearchStatus.loaded);
    expect(cubit.state.sortOption, PharmacySortOption.nearest);
    expect(cubit.state.results.isNotEmpty, true);

    // Verify distance is ascending in default sort
    for (int i = 0; i < cubit.state.results.length - 1; i++) {
      expect(
        cubit.state.results[i].pharmacy.distanceKm <=
            cubit.state.results[i + 1].pharmacy.distanceKm,
        true,
      );
    }
  });

  test('sorting by highestRating orders pharmacies correctly', () {
    cubit.updateSortOption(PharmacySortOption.highestRating);
    expect(cubit.state.sortOption, PharmacySortOption.highestRating);

    // First should be Al-Amal (4.9 rating)
    expect(cubit.state.results.first.pharmacy.rating, 4.9);
    for (int i = 0; i < cubit.state.results.length - 1; i++) {
      expect(
        cubit.state.results[i].pharmacy.rating >=
            cubit.state.results[i + 1].pharmacy.rating,
        true,
      );
    }
  });

  test('sorting by fastestDelivery orders pharmacies by delivery time', () {
    cubit.updateSortOption(PharmacySortOption.fastestDelivery);
    expect(cubit.state.sortOption, PharmacySortOption.fastestDelivery);

    for (int i = 0; i < cubit.state.results.length - 1; i++) {
      expect(
        cubit.state.results[i].deliveryMinutes <=
            cubit.state.results[i + 1].deliveryMinutes,
        true,
      );
    }
  });

  test('search query finds medicine across all pharmacies', () {
    cubit.updateSearchQuery('Panadol');
    expect(cubit.state.searchQuery, 'Panadol');
    expect(cubit.state.results.isNotEmpty, true);

    for (final result in cubit.state.results) {
      expect(
        result.matchedMedicines.any((m) => m.name.contains('Panadol')),
        true,
      );
    }

    cubit.clearSearch();
    expect(cubit.state.searchQuery, '');
  });

  test('search query verifies medicine is in stock and excludes out of stock pharmacies', () {
    // Panadol Extra is out of stock in pharmacy_19011 (quantity: 0)
    cubit.updateSearchQuery('Panadol Extra');

    // Should return pharmacies where it IS in stock
    expect(cubit.state.results.isNotEmpty, true);
    final pharmacyIds = cubit.state.results.map((r) => r.pharmacy.id).toList();

    // pharmacy_19011 must NOT be in the results
    expect(pharmacyIds.contains('pharmacy_19011'), false);

    // All returned pharmacies must actually have Panadol Extra in stock
    for (final result in cubit.state.results) {
      final extraMed = result.matchedMedicines.firstWhere(
        (m) => m.name.contains('Panadol Extra'),
      );
      expect(extraMed.isAvailable && extraMed.quantity > 0, true);
    }
  });

  test('searching medicine family excludes out of stock items from matchedMedicines', () {
    cubit.updateSearchQuery('Panadol');

    // pharmacy_19011 has other Panadols in stock (Advance, Joint), so it is present
    final ph19011Result = cubit.state.results.firstWhere(
      (r) => r.pharmacy.id == 'pharmacy_19011',
    );

    // BUT Panadol Extra must NOT be in its matchedMedicines because it is out of stock (0)
    expect(
      ph19011Result.matchedMedicines.any((m) => m.name == 'Panadol Extra'),
      false,
    );
    // Other available Panadols are present
    expect(
      ph19011Result.matchedMedicines.any((m) => m.name.contains('Panadol')),
      true,
    );
  });

  test('openOnly filter excludes closed pharmacies', () {
    final beforeCount = cubit.state.results.length;
    cubit.updateFilters(const SearchFilterOptions(openOnly: true));

    expect(cubit.state.results.length < beforeCount, true);
    for (final result in cubit.state.results) {
      expect(result.pharmacy.isOpen, true);
    }
  });

  test('verifiedOnly filter excludes unverified pharmacies', () {
    cubit.updateFilters(const SearchFilterOptions(verifiedOnly: true));
    for (final result in cubit.state.results) {
      expect(result.pharmacy.isVerified, true);
    }
  });

  test('fastDeliveryOnly filter limits to pharmacies under 30 minutes', () {
    cubit.updateFilters(const SearchFilterOptions(fastDeliveryOnly: true));
    for (final result in cubit.state.results) {
      expect(result.deliveryMinutes <= 30, true);
    }
  });

  test('resetFilters restores initial state', () {
    cubit.updateFilters(
      const SearchFilterOptions(openOnly: true, fastDeliveryOnly: true),
    );
    expect(cubit.state.filters.activeCount, 2);

    cubit.resetFilters();
    expect(cubit.state.filters.activeCount, 0);
  });
}

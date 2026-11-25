class SearchFilterOptions {
  final String selectedCategory;
  final bool inStockOnly;
  final bool openOnly;
  final bool verifiedOnly;
  final bool fastDeliveryOnly;
  final bool digitalPaymentOnly;
  final String? medicineForm;

  const SearchFilterOptions({
    this.selectedCategory = 'الكل',
    this.inStockOnly = false,
    this.openOnly = false,
    this.verifiedOnly = false,
    this.fastDeliveryOnly = false,
    this.digitalPaymentOnly = false,
    this.medicineForm,
  });

  int get activeCount {
    int count = 0;
    if (selectedCategory != 'الكل') count++;
    if (inStockOnly) count++;
    if (openOnly) count++;
    if (verifiedOnly) count++;
    if (fastDeliveryOnly) count++;
    if (digitalPaymentOnly) count++;
    if (medicineForm != null && medicineForm!.isNotEmpty) count++;
    return count;
  }

  SearchFilterOptions copyWith({
    String? selectedCategory,
    bool? inStockOnly,
    bool? openOnly,
    bool? verifiedOnly,
    bool? fastDeliveryOnly,
    bool? digitalPaymentOnly,
    String? medicineForm,
    bool clearForm = false,
  }) {
    return SearchFilterOptions(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      openOnly: openOnly ?? this.openOnly,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      fastDeliveryOnly: fastDeliveryOnly ?? this.fastDeliveryOnly,
      digitalPaymentOnly: digitalPaymentOnly ?? this.digitalPaymentOnly,
      medicineForm: clearForm ? null : (medicineForm ?? this.medicineForm),
    );
  }

  SearchFilterOptions reset() => const SearchFilterOptions();
}

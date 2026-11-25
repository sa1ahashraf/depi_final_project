import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:depi_final_project/core/widgets/feedback/app_feedback.dart';
import 'package:depi_final_project/features/customer/cart/logic/cubits/customer_cart_cubit.dart';
import 'package:depi_final_project/features/customer/cart/logic/cubits/customer_cart_state.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/repositories/pharmacy_details_repository.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/screens/pharmacy_details_screen.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/widgets/cart_bottom_sheet_widget.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/widgets/floating_cart_bar.dart';
import '../../data/models/pharmacy_search_result_model.dart';
import '../../data/repositories/firebase_pharmacy_search_repository.dart';
import '../../data/repositories/pharmacy_search_repository.dart';
import '../../logic/cubits/pharmacy_search_cubit.dart';
import '../../logic/cubits/pharmacy_search_state.dart';
import '../widgets/empty_search_state_widget.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/global_medicine_search_bar.dart';
import '../widgets/pharmacy_search_result_card.dart';
import '../widgets/search_header_widget.dart';
import '../widgets/sort_options_bar.dart';

class PharmacySearchScreen extends StatelessWidget {
  final PharmacySearchRepository? repository;
  final PharmacyDetailsRepository? pharmacyDetailsRepository;
  final String? initialQuery;
  final ValueChanged<PharmacySearchResultModel>? onPharmacySelected;

  const PharmacySearchScreen({
    super.key,
    this.repository,
    this.pharmacyDetailsRepository,
    this.initialQuery,
    this.onPharmacySelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repo = repository ?? FirebasePharmacySearchRepository();
        final cubit = PharmacySearchCubit(repository: repo);
        cubit.loadData();
        if (initialQuery != null && initialQuery!.isNotEmpty) {
          cubit.updateSearchQuery(initialQuery!);
        }
        return cubit;
      },
      child: _PharmacySearchView(
        pharmacyDetailsRepository: pharmacyDetailsRepository,
        onPharmacySelected: onPharmacySelected,
      ),
    );
  }
}

class _PharmacySearchView extends StatelessWidget {
  final PharmacyDetailsRepository? pharmacyDetailsRepository;
  final ValueChanged<PharmacySearchResultModel>? onPharmacySelected;

  const _PharmacySearchView({
    this.pharmacyDetailsRepository,
    this.onPharmacySelected,
  });

  @override
  Widget build(BuildContext context) {
    CustomerCartCubit? cartCubit;
    try {
      cartCubit = context.watch<CustomerCartCubit>();
    } catch (_) {
      cartCubit = null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFCFC),
      body: SafeArea(
        child: BlocConsumer<PharmacySearchCubit, PharmacySearchState>(
          listener: (context, state) {
            if (state.status == PharmacySearchStatus.error &&
                state.errorMessage != null) {
              AppFeedback.showSnackBar(
                context,
                state.errorMessage!,
                type: FeedbackType.error,
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Top Header (Title, live coverage, location)
                SearchHeaderWidget(
                  onBack: () => Navigator.of(context).maybePop(),
                  onChangeLocation: () {
                    AppFeedback.showSnackBar(
                      context,
                      'تم تحديد موقعك الحالي: المعادي، القاهرة',
                      type: FeedbackType.information,
                    );
                  },
                ),

                // Global Medicine Search Bar + Filter Icon with Badge
                GlobalMedicineSearchBar(
                  initialQuery: state.searchQuery,
                  activeFilterCount: state.filters.activeCount,
                  onSearchChanged: (query) {
                    context.read<PharmacySearchCubit>().updateSearchQuery(query);
                  },
                  onClear: () {
                    context.read<PharmacySearchCubit>().clearSearch();
                  },
                  onOpenFilters: () {
                    FilterBottomSheet.show(
                      context,
                      currentFilters: state.filters,
                      categories: state.categories,
                      onApply: (newFilters) {
                        context.read<PharmacySearchCubit>().updateFilters(
                              newFilters,
                            );
                      },
                    );
                  },
                ),

                // Sorting Options Bar (Nearest, Highest Rating, Fastest Delivery, Lowest Price)
                SortOptionsBar(
                  selectedSort: state.sortOption,
                  onSortSelected: (option) {
                    context.read<PharmacySearchCubit>().updateSortOption(option);
                  },
                ),

                // Fast Category Chips Row
                _buildFastCategories(context, state),

                // Results Count & Subtitle Bar
                _buildResultsSummaryBar(context, state),

                // Pharmacies List
                Expanded(
                  child: state.results.isEmpty
                      ? EmptySearchStateWidget(
                          query: state.searchQuery,
                          onReset: () {
                            context.read<PharmacySearchCubit>().clearSearch();
                            context.read<PharmacySearchCubit>().resetFilters();
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24, top: 4),
                          itemCount: state.results.length,
                          itemBuilder: (context, index) {
                            final result = state.results[index];
                            return PharmacySearchResultCard(
                              result: result,
                              onTap: () => _navigateToPharmacyDetails(
                                context,
                                result,
                                state.searchQuery,
                              ),
                            );
                          },
                        ),
                ),

                // Persistent Floating Cart Bar across pharmacies
                if (cartCubit != null && cartCubit.state.isNotEmpty)
                  FloatingCartBar(
                    totalAmount: cartCubit.state.grandTotal,
                    itemCount: cartCubit.state.totalItemCount,
                    onViewCart: () => _showCartSheet(context, cartCubit!),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFastCategories(BuildContext context, PharmacySearchState state) {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: state.categories.map((cat) {
            final isSelected = state.filters.selectedCategory == cat;

            return Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (selected) {
                  context.read<PharmacySearchCubit>().selectCategory(
                        selected ? cat : 'الكل',
                      );
                },
                selectedColor: const Color(0xFF005C53),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF005C53)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResultsSummaryBar(
    BuildContext context,
    PharmacySearchState state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'الصيدليات المتاحة (${state.results.length})',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          if (state.searchQuery.isNotEmpty)
            Flexible(
              child: Text(
                'نتائج دواء: "${state.searchQuery}"',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF005C53),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToPharmacyDetails(
    BuildContext context,
    PharmacySearchResultModel result,
    String currentSearchQuery,
  ) {
    if (onPharmacySelected != null) {
      onPharmacySelected!(result);
      return;
    }
    // Navigates to PharmacyDetailsScreen for the chosen pharmacy carrying forward search query
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PharmacyDetailsScreen(
          pharmacyId: result.pharmacy.id,
          pharmacy: result.pharmacy,
          repository: pharmacyDetailsRepository,
          preloadCartForDemo: false,
          initialSearchQuery: currentSearchQuery,
        ),
      ),
    );
  }

  void _showCartSheet(BuildContext context, CustomerCartCubit cartCubit) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocBuilder<CustomerCartCubit, CustomerCartState>(
          bloc: cartCubit,
          builder: (context, cartState) {
            return CartBottomSheetWidget(
              cart: cartState.items,
              totalAmount: cartState.grandTotal,
              onIncrement: (cartItem) {
                cartCubit.incrementQuantity(
                  '${cartItem.pharmacyId}_${cartItem.item.id}',
                );
              },
              onDecrement: (cartItem) {
                cartCubit.decrementQuantity(
                  '${cartItem.pharmacyId}_${cartItem.item.id}',
                );
              },
              onCheckout: () {
                Navigator.pop(sheetContext);
                AppFeedback.showSnackBar(
                  context,
                  'جاري الانتقال لإتمام الطلب بقيمة ${cartState.selectedTotal.toStringAsFixed(0)} ج.م',
                  type: FeedbackType.success,
                );
              },
              onCheckoutSelected: (selectedPharmacies, total) {
                Navigator.pop(sheetContext);
                AppFeedback.showSnackBar(
                  context,
                  'تم اختيار ${selectedPharmacies.length} صيدليات لإتمام الطلب بقيمة ${total.toStringAsFixed(0)} ج.م',
                  type: FeedbackType.success,
                );
              },
            );
          },
        );
      },
    );
  }
}

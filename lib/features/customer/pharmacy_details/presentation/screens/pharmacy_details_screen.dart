import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:depi_final_project/core/theme/app_colors.dart';
import 'package:depi_final_project/core/widgets/feedback/app_feedback.dart';
import 'package:depi_final_project/features/customer/cart/logic/cubits/customer_cart_cubit.dart';
import 'package:depi_final_project/features/customer/cart/logic/cubits/customer_cart_state.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/repositories/firebase_pharmacy_details_repository.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/repositories/pharmacy_details_repository.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/logic/cubits/pharmacy_details_cubit.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/logic/cubits/pharmacy_details_state.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/widgets/cart_bottom_sheet_widget.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/widgets/categories_bar_widget.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/widgets/floating_cart_bar.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/widgets/live_inventory_header.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/widgets/medicine_card_widget.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/widgets/medicine_search_bar.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/widgets/missing_medicine_card.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/widgets/pharmacy_header_widget.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/widgets/pharmacy_info_card.dart';

class PharmacyDetailsScreen extends StatelessWidget {
  final String pharmacyId;
  final PharmacyDetailModel? pharmacy;
  final PharmacyDetailsRepository? repository;
  final bool preloadCartForDemo;
  final String initialSearchQuery;

  const PharmacyDetailsScreen({
    super.key,
    this.pharmacyId = 'pharmacy_al_nour',
    this.pharmacy,
    this.repository,
    this.preloadCartForDemo = false,
    this.initialSearchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repo = repository ?? FirebasePharmacyDetailsRepository();
        final cubit = PharmacyDetailsCubit(
          repository: repo,
          pharmacyId: pharmacyId,
          initialPharmacy: pharmacy,
          initialSearchQuery: initialSearchQuery,
        );
        cubit.loadPharmacyDetails(pharmacyId);

        // Preload cart matching screenshot when explicitly requested in tests
        if (preloadCartForDemo) {
          cubit.setCartPreloadedForDemo();
        }
        return cubit;
      },
      child: const _PharmacyDetailsView(),
    );
  }
}

class _PharmacyDetailsView extends StatelessWidget {
  const _PharmacyDetailsView();

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
        child: BlocConsumer<PharmacyDetailsCubit, PharmacyDetailsState>(
          listener: (context, state) {
            if (state.status == PharmacyDetailsStatus.error &&
                state.errorMessage != null) {
              AppFeedback.showSnackBar(
                context,
                state.errorMessage!,
                type: FeedbackType.error,
              );
            }
          },
          builder: (context, state) {
            final pharmacy =
                state.pharmacy ??
                FirebasePharmacyDetailsRepository.defaultPharmacy;
            final items = state.filteredItems;

            return Column(
              children: [
                // Top Header (Pharmacy Name, Rating, Distance, Chat Button)
                PharmacyHeaderWidget(
                  pharmacy: pharmacy,
                  onBack: () => Navigator.of(context).maybePop(),
                  onChat: () => _showChatDialog(context, pharmacy.name),
                ),

                // Scrollable Content
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // Pharmacy Info Card (License, Address, Payment badges)
                      SliverToBoxAdapter(
                        child: PharmacyInfoCard(pharmacy: pharmacy),
                      ),

                      // Search bar to find any medicine in pharmacy
                      SliverToBoxAdapter(
                        child: MedicineSearchBar(
                          initialQuery: state.searchQuery,
                          onSearchChanged: (query) {
                            context
                                .read<PharmacyDetailsCubit>()
                                .updateSearchQuery(query);
                          },
                          onClear: () {
                            context
                                .read<PharmacyDetailsCubit>()
                                .clearSearch();
                          },
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 6)),

                      // Category Filter Pills Bar
                      SliverToBoxAdapter(
                        child: CategoriesBarWidget(
                          categories: state.categories,
                          selectedCategory: state.selectedCategory,
                          onCategorySelected: (category) {
                            context.read<PharmacyDetailsCubit>().selectCategory(
                              category,
                            );
                          },
                        ),
                      ),

                      // Live Inventory Header (Real-time badge)
                      const SliverToBoxAdapter(child: LiveInventoryHeader()),

                      // Medicines List
                      if (items.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(
                              child: Text(
                                state.searchQuery.isNotEmpty
                                    ? 'لا توجد أدوية مطابقة للبحث عن "${state.searchQuery}"'
                                    : 'لا توجد أدوية متوفرة في هذا القسم حالياً',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = items[index];
                            return MedicineCardWidget(
                              item: item,
                              onAddToCart: () {
                                final added = context
                                    .read<PharmacyDetailsCubit>()
                                    .addToCart(item);
                                if (cartCubit != null) {
                                  cartCubit.addToCart(item, pharmacy);
                                }
                                if (added) {
                                  AppFeedback.showSnackBar(
                                    context,
                                    'تمت إضافة ${item.name} إلى السلة من ${pharmacy.name}',
                                    type: FeedbackType.success,
                                  );
                                } else {
                                  AppFeedback.showSnackBar(
                                    context,
                                    'هذا الدواء غير متوفر حالياً في الصيدلية',
                                    type: FeedbackType.error,
                                  );
                                }
                              },
                            );
                          }, childCount: items.length),
                        ),

                      // Missing Medicine Help Banner
                      SliverToBoxAdapter(
                        child: MissingMedicineCard(
                          onChatPressed:
                              () => _showChatDialog(context, pharmacy.name),
                        ),
                      ),

                      // Bottom Padding so content isn't obscured by floating cart bar
                      const SliverToBoxAdapter(child: SizedBox(height: 90)),
                    ],
                  ),
                ),

                // Sticky Bottom Cart Bar (Calculates from shared multi-pharmacy cart if available)
                _buildFloatingCartBar(context, state, cartCubit),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloatingCartBar(
    BuildContext context,
    PharmacyDetailsState state,
    CustomerCartCubit? cartCubit,
  ) {
    final int count = cartCubit != null && cartCubit.state.isNotEmpty
        ? cartCubit.state.totalItemCount
        : state.cartItemCount;
    final double total = cartCubit != null && cartCubit.state.isNotEmpty
        ? cartCubit.state.grandTotal
        : state.cartTotal;

    if (count <= 0) return const SizedBox.shrink();

    return FloatingCartBar(
      totalAmount: total,
      itemCount: count,
      onViewCart: () => _showCartSheet(context, state, cartCubit),
    );
  }

  void _showChatDialog(BuildContext context, String pharmacyName) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'التواصل مع $pharmacyName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('إرسال صورة الروشتة أو الدواء'),
                subtitle: const Text('سيقوم الصيدلي بالتحقق من التوفر فوراً'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  AppFeedback.showSnackBar(
                    context,
                    'جاري فتح الكاميرا لإرسال الروشتة...',
                    type: FeedbackType.information,
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.primary,
                ),
                title: const Text('محادثة نصية مباشرة مع الصيدلي'),
                subtitle: const Text('للاستفسار عن البدائل والأسعار'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  AppFeedback.showSnackBar(
                    context,
                    'تم فتح المحادثة مع الصيدلية',
                    type: FeedbackType.success,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCartSheet(
    BuildContext context,
    PharmacyDetailsState state,
    CustomerCartCubit? cartCubit,
  ) {
    final localCubit = context.read<PharmacyDetailsCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        if (cartCubit != null) {
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
                  localCubit.addToCart(cartItem.item);
                },
                onDecrement: (cartItem) {
                  cartCubit.decrementQuantity(
                    '${cartItem.pharmacyId}_${cartItem.item.id}',
                  );
                  localCubit.removeFromCart(cartItem.item);
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
        }

        return BlocProvider.value(
          value: localCubit,
          child: BlocBuilder<PharmacyDetailsCubit, PharmacyDetailsState>(
            builder: (context, liveState) {
              return CartBottomSheetWidget(
                cart: liveState.cart,
                totalAmount: liveState.cartTotal,
                onIncrement: (cartItem) => localCubit.addToCart(cartItem.item),
                onDecrement: (cartItem) =>
                    localCubit.removeFromCart(cartItem.item),
                onCheckout: () {
                  Navigator.pop(sheetContext);
                  AppFeedback.showSnackBar(
                    context,
                    'جاري الانتقال لإتمام الطلب بقيمة ${liveState.cartTotal.toStringAsFixed(0)} ج.م',
                    type: FeedbackType.success,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}


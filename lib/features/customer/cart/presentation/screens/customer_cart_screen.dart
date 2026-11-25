import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:depi_final_project/core/models/order_model.dart';
import 'package:depi_final_project/core/theme/app_colors.dart';
import 'package:depi_final_project/core/theme/app_styles.dart';
import 'package:depi_final_project/core/widgets/buttons/primary_button.dart';
import 'package:depi_final_project/core/widgets/dialogs/app_dialogs.dart';
import 'package:depi_final_project/core/widgets/feedback/app_feedback.dart';
import 'package:depi_final_project/features/customer/cart/logic/cubits/customer_cart_cubit.dart';
import 'package:depi_final_project/features/customer/cart/logic/cubits/customer_cart_state.dart';
import 'package:depi_final_project/features/customer/cart/presentation/widgets/cart_pharmacy_group_card.dart';
import 'package:depi_final_project/features/customer/cart/presentation/widgets/checkout_summary_card.dart';
import 'package:depi_final_project/features/customer/cart/presentation/widgets/delivery_address_section.dart';
import 'package:depi_final_project/features/customer/orders/logic/cubits/customer_orders_cubit.dart';
import 'package:depi_final_project/features/customer/orders/logic/cubits/customer_orders_state.dart';
import 'package:depi_final_project/features/customer/orders/presentation/screens/customer_orders_screen.dart';
import 'package:depi_final_project/features/customer/orders/presentation/screens/order_tracking_screen.dart';

class CustomerCartScreen extends StatefulWidget {
  static const double defaultDeliveryFeePerPharmacy = 15.0;

  const CustomerCartScreen({super.key});

  @override
  State<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  String _selectedPaymentMethod = CheckoutSummaryCard.paymentOptions.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('سلة المشتريات والدفع'),
        actions: [
          BlocBuilder<CustomerCartCubit, CustomerCartState>(
            builder: (context, cartState) {
              if (cartState.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () async {
                  final confirmed = await DialogHelper.showConfirmation(
                    context,
                    title: 'إفراغ السلة',
                    message: 'هل تريد حذف جميع الأدوية من سلة المشتريات؟',
                  );
                  if (confirmed == true && context.mounted) {
                    context.read<CustomerCartCubit>().clearCart();
                  }
                },
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'إفراغ السلة',
              );
            },
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CustomerOrdersScreen(),
              ),
            ),
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'طلباتي',
          ),
        ],
      ),
      body: BlocBuilder<CustomerCartCubit, CustomerCartState>(
        builder: (context, cartState) {
          if (cartState.isEmpty) {
            return _EmptyCartView(
              onBrowsePressed: () => Navigator.of(context).maybePop(),
              onOrdersPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CustomerOrdersScreen(),
                ),
              ),
            );
          }

          final groups = cartState.pharmacyGroups;
          final selectedGroups = groups.where((g) => g.isSelected).toList();
          final selectedCount = selectedGroups.length;
          final totalWithDelivery =
              cartState.selectedTotal +
              (selectedCount * CustomerCartScreen.defaultDeliveryFeePerPharmacy);

          return BlocConsumer<CustomerOrdersCubit, CustomerOrdersState>(
            listener: (context, ordersState) {
              if (ordersState.status == CustomerOrdersStatus.error &&
                  ordersState.errorMessage != null) {
                AppFeedback.showSnackBar(
                  context,
                  ordersState.errorMessage!,
                  type: FeedbackType.error,
                );
              }
            },
            builder: (context, ordersState) {
              final isSubmitting =
                  ordersState.status == CustomerOrdersStatus.submitting;

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Selection control bar
                          if (groups.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'تم تحديد $selectedCount من ${groups.length} صيدليات للشراء',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      final cubit =
                                          context.read<CustomerCartCubit>();
                                      if (cartState.isAllSelected) {
                                        cubit.deselectAllPharmacies();
                                      } else {
                                        cubit.selectAllPharmacies();
                                      }
                                    },
                                    icon: Icon(
                                      cartState.isAllSelected
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      size: 18,
                                    ),
                                    label: Text(
                                      cartState.isAllSelected
                                          ? 'إلغاء تحديد الكل'
                                          : 'تحديد الكل',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Pharmacy Groups
                          ...groups.map((group) {
                            return CartPharmacyGroupCard(
                              group: group,
                              deliveryFee:
                                  CustomerCartScreen.defaultDeliveryFeePerPharmacy,
                              onToggleSelect: () => context
                                  .read<CustomerCartCubit>()
                                  .togglePharmacySelection(group.pharmacyId),
                              onSelectOnly: () => context
                                  .read<CustomerCartCubit>()
                                  .selectOnlyPharmacy(group.pharmacyId),
                              onIncrement: (cartItem) => context
                                  .read<CustomerCartCubit>()
                                  .incrementQuantity(
                                    '${cartItem.effectivePharmacyId}_${cartItem.item.id}',
                                  ),
                              onDecrement: (cartItem) => context
                                  .read<CustomerCartCubit>()
                                  .decrementQuantity(
                                    '${cartItem.effectivePharmacyId}_${cartItem.item.id}',
                                  ),
                              onRemoveItem: (cartItem) => context
                                  .read<CustomerCartCubit>()
                                  .removeFromCart(
                                    '${cartItem.effectivePharmacyId}_${cartItem.item.id}',
                                  ),
                            );
                          }),

                          const SizedBox(height: 6),

                          // Delivery Address Section
                          DeliveryAddressSection(
                            savedAddresses: ordersState.savedAddresses,
                            selectedAddress: ordersState.selectedAddress,
                            onSelectAddress: (addr) => context
                                .read<CustomerOrdersCubit>()
                                .selectAddress(addr),
                            onAddAddress: ({
                              required label,
                              required addressLine,
                              required phone,
                            }) async {
                              await context
                                  .read<CustomerOrdersCubit>()
                                  .addOrUpdateAddress(
                                    label: label,
                                    addressLine: addressLine,
                                    phone: phone,
                                  );
                            },
                          ),

                          const SizedBox(height: 14),

                          // Summary & Payment Card
                          CheckoutSummaryCard(
                            itemsSubtotal: cartState.selectedTotal,
                            deliveryFeePerPharmacy:
                                CustomerCartScreen.defaultDeliveryFeePerPharmacy,
                            selectedPharmacyCount: selectedCount,
                            selectedPaymentMethod: _selectedPaymentMethod,
                            onPaymentMethodChanged: (method) => setState(
                              () => _selectedPaymentMethod = method,
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Sticky Checkout Action Bar
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: PrimaryButton(
                        isLoading: isSubmitting,
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: selectedCount == 0
                            ? 'يرجى تحديد صيدلية واحدة على الأقل'
                            : 'تأكيد وإرسال الطلب (${totalWithDelivery.toStringAsFixed(0)} ج.م)',
                        onPressed: selectedCount == 0
                            ? null
                            : () => _submitOrders(context, selectedGroups),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _submitOrders(
    BuildContext context,
    List<dynamic> selectedGroups,
  ) async {
    final ordersCubit = context.read<CustomerOrdersCubit>();
    final cartCubit = context.read<CustomerCartCubit>();
    final groups = cartCubit.state.pharmacyGroups
        .where((g) => g.isSelected)
        .toList();

    final createdOrders = await ordersCubit.placeOrdersFromCart(
      cartCubit: cartCubit,
      selectedGroups: groups,
      deliveryFeePerPharmacy: CustomerCartScreen.defaultDeliveryFeePerPharmacy,
    );

    if (!context.mounted || createdOrders.isEmpty) return;

    await _showOrderSuccessAndNavigate(context, createdOrders);
  }

  Future<void> _showOrderSuccessAndNavigate(
    BuildContext context,
    List<OrderModel> createdOrders,
  ) async {
    final count = createdOrders.length;
    AppFeedback.showSnackBar(
      context,
      count == 1
          ? 'تم إرسال طلبك بنجاح! يمكنك متابعة حالته الآن'
          : 'تم إرسال $count طلبات للصيدليات المحددة بنجاح!',
      type: FeedbackType.success,
    );

    if (count == 1) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(orderId: createdOrders.first.id),
        ),
      );
    } else {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const CustomerOrdersScreen(),
        ),
      );
    }
  }
}

class _EmptyCartView extends StatelessWidget {
  final VoidCallback onBrowsePressed;
  final VoidCallback onOrdersPressed;

  const _EmptyCartView({
    required this.onBrowsePressed,
    required this.onOrdersPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 42,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'سلة المشتريات فارغة حالياً',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابحث عن الأدوية في الصيدليات القريبة وأضفها للسلة لإتمام طلبك بسهولة.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'تصفح الصيدليات والأدوية',
              icon: const Icon(Icons.local_pharmacy_outlined, size: 18),
              onPressed: onBrowsePressed,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onOrdersPressed,
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              label: const Text('متابعة طلباتي السابقة'),
            ),
          ],
        ),
      ),
    );
  }
}

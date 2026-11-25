import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:depi_final_project/core/theme/app_colors.dart';
import 'package:depi_final_project/core/theme/app_styles.dart';
import 'package:depi_final_project/core/widgets/dialogs/app_dialogs.dart';
import 'package:depi_final_project/core/widgets/feedback/app_feedback.dart';
import 'package:depi_final_project/features/customer/cart/logic/cubits/customer_cart_cubit.dart';
import 'package:depi_final_project/features/customer/cart/logic/cubits/customer_cart_state.dart';
import 'package:depi_final_project/features/customer/cart/presentation/screens/customer_cart_screen.dart';
import 'package:depi_final_project/features/customer/orders/logic/cubits/customer_orders_cubit.dart';
import 'package:depi_final_project/features/customer/orders/logic/cubits/customer_orders_state.dart';
import 'package:depi_final_project/features/customer/orders/presentation/screens/order_tracking_screen.dart';
import 'package:depi_final_project/features/customer/orders/presentation/widgets/order_history_card.dart';

class CustomerOrdersScreen extends StatelessWidget {
  const CustomerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('طلباتي وسجل الطلبات'),
        actions: [
          BlocBuilder<CustomerCartCubit, CustomerCartState>(
            builder: (context, cartState) {
              return IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CustomerCartScreen(),
                  ),
                ),
                tooltip: 'سلة المشتريات',
                icon: Badge(
                  isLabelVisible: cartState.totalItemCount > 0,
                  label: Text('${cartState.totalItemCount}'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<CustomerOrdersCubit, CustomerOrdersState>(
        listener: (context, state) {
          if (state.status == CustomerOrdersStatus.error &&
              state.errorMessage != null) {
            AppFeedback.showSnackBar(
              context,
              state.errorMessage!,
              type: FeedbackType.error,
            );
          }
        },
        builder: (context, state) {
          final orders = state.filteredOrders;

          return Column(
            children: [
              // Filter Tabs
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: OrderHistoryFilter.values.map((filter) {
                      final isSelected = state.filter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          label: Text(filter.arabicLabel),
                          selected: isSelected,
                          onSelected: (_) => context
                              .read<CustomerOrdersCubit>()
                              .setFilter(filter),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              Expanded(
                child: state.status == CustomerOrdersStatus.loading &&
                        state.orders.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : orders.isEmpty
                    ? _EmptyOrdersState(filter: state.filter)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return OrderHistoryCard(
                            order: order,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrderTrackingScreen(
                                  orderId: order.id,
                                  initialOrder: order,
                                ),
                              ),
                            ),
                            onCancel: () async {
                              final confirmed =
                                  await DialogHelper.showConfirmation(
                                    context,
                                    title: 'إلغاء الطلب',
                                    message:
                                        'هل أنت متأكد من إلغاء هذا الطلب؟ لن يمكن التراجع بعد الإلغاء.',
                                  );
                              if (confirmed == true && context.mounted) {
                                final ok = await context
                                    .read<CustomerOrdersCubit>()
                                    .cancelOrder(order.id);
                                if (ok && context.mounted) {
                                  AppFeedback.showSnackBar(
                                    context,
                                    'تم إلغاء الطلب بنجاح',
                                    type: FeedbackType.information,
                                  );
                                }
                              }
                            },
                            onReorder: () {
                              final cartCubit =
                                  context.read<CustomerCartCubit>();
                              final added = context
                                  .read<CustomerOrdersCubit>()
                                  .reorderToCart(order, cartCubit);
                              if (added > 0) {
                                AppFeedback.showSnackBar(
                                  context,
                                  'تمت إضافة $added عبوات إلى سلة المشتريات',
                                  type: FeedbackType.success,
                                );
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CustomerCartScreen(),
                                  ),
                                );
                              } else {
                                AppFeedback.showSnackBar(
                                  context,
                                  'الأدوية في هذا الطلب غير متوفرة حالياً في الصيدلية',
                                  type: FeedbackType.information,
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyOrdersState extends StatelessWidget {
  final OrderHistoryFilter filter;

  const _EmptyOrdersState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              filter == OrderHistoryFilter.all
                  ? 'لا توجد طلبات حتى الآن'
                  : 'لا توجد طلبات في تصنيف "${filter.arabicLabel}"',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بالبحث عن أدويتك في أقرب صيدلية وأرسل طلبك الأول.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:depi_final_project/core/enums/order_status.dart';
import 'package:depi_final_project/core/models/order_model.dart';
import 'package:depi_final_project/core/theme/app_colors.dart';
import 'package:depi_final_project/core/theme/app_styles.dart';
import 'package:depi_final_project/core/widgets/dialogs/app_dialogs.dart';
import 'package:depi_final_project/core/widgets/feedback/app_feedback.dart';
import 'package:depi_final_project/features/customer/cart/logic/cubits/customer_cart_cubit.dart';
import 'package:depi_final_project/features/customer/cart/presentation/screens/customer_cart_screen.dart';
import 'package:depi_final_project/features/customer/orders/data/models/order_display_helpers.dart';
import 'package:depi_final_project/features/customer/orders/logic/cubits/customer_orders_cubit.dart';
import 'package:depi_final_project/features/customer/orders/presentation/widgets/order_status_badge.dart';
import 'package:depi_final_project/features/customer/orders/presentation/widgets/order_tracking_timeline.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  final OrderModel? initialOrder;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  Widget build(BuildContext context) {
    final ordersCubit = context.read<CustomerOrdersCubit>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('تتبع الطلب ${OrderDisplayHelpers.shortOrderCode(orderId)}'),
      ),
      body: StreamBuilder<OrderModel?>(
        initialData: initialOrder,
        stream: ordersCubit.repository.watchOrderById(orderId),
        builder: (context, snapshot) {
          final order = snapshot.data;

          if (snapshot.connectionState == ConnectionState.waiting &&
              order == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (order == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.search_off_rounded,
                      size: 56,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'تعذر العثور على بيانات هذا الطلب',
                      style: AppTextStyles.headlineSmall,
                    ),
                  ],
                ),
              ),
            );
          }

          final pharmacyName = OrderDisplayHelpers.resolvePharmacyName(
            order.pharmacyId,
          );
          final subtotal = OrderDisplayHelpers.itemsSubtotal(order);
          final finalTotal = OrderDisplayHelpers.finalPayableTotal(order);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hero Header Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    pharmacyName,
                                    style: AppTextStyles.headlineSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                OrderStatusBadge(status: order.status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'رقم الطلب: ${OrderDisplayHelpers.shortOrderCode(order.id)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              'تاريخ الإنشاء: ${OrderDisplayHelpers.formatDateTime(order.createdAt)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Live Stepper Timeline
                      OrderTrackingTimeline(order: order),

                      const SizedBox(height: 14),

                      // Ordered Medicines Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.medication_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'الأدوية المطلوبة (${order.items.length})',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20, color: Color(0xFFF1F5F9)),
                            for (int i = 0; i < order.items.length; i++) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.items[i].medicineName,
                                          style: AppTextStyles.labelLarge
                                              .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                        Text(
                                          '${order.items[i].strength} • ${order.items[i].unitPrice.toStringAsFixed(0)} ج.م × ${order.items[i].quantity}',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                            color: const Color(0xFF64748B),
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${order.items[i].subtotal.toStringAsFixed(0)} ج.م',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (i < order.items.length - 1)
                                const Divider(
                                  height: 16,
                                  color: Color(0xFFF1F5F9),
                                ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Delivery Address Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'عنوان التوصيل (${OrderDisplayHelpers.addressLabel(order.deliveryAddress)})',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              OrderDisplayHelpers.addressLine(
                                order.deliveryAddress,
                              ),
                              style: AppTextStyles.bodyMedium,
                            ),
                            if (OrderDisplayHelpers.addressPhone(
                              order.deliveryAddress,
                            ).isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'هاتف التواصل: ${OrderDisplayHelpers.addressPhone(order.deliveryAddress)}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Payment Summary Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _CostRow(
                              label: 'مجموع الأدوية',
                              value: '${subtotal.toStringAsFixed(0)} ج.م',
                            ),
                            const SizedBox(height: 6),
                            _CostRow(
                              label: 'رسوم التوصيل',
                              value:
                                  '${order.deliveryFee.toStringAsFixed(0)} ج.م',
                            ),
                            const Divider(height: 18, color: Color(0xFFE2E8F0)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'الإجمالي النهائي',
                                    style: AppTextStyles.headlineSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${finalTotal.toStringAsFixed(0)} ج.م',
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom contextual actions
              if (order.status == OrderStatus.pending || order.status.isFinal)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: SafeArea(
                    top: false,
                    child: order.status == OrderStatus.pending
                        ? SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final confirmed =
                                    await DialogHelper.showConfirmation(
                                      context,
                                      title: 'إلغاء الطلب',
                                      message:
                                          'هل أنت متأكد من إلغاء هذا الطلب؟',
                                    );
                                if (confirmed == true && context.mounted) {
                                  final ok = await ordersCubit.cancelOrder(
                                    order.id,
                                  );
                                  if (ok && context.mounted) {
                                    AppFeedback.showSnackBar(
                                      context,
                                      'تم إلغاء الطلب بنجاح',
                                      type: FeedbackType.information,
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text('إلغاء الطلب'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final cartCubit =
                                    context.read<CustomerCartCubit>();
                                final added = ordersCubit.reorderToCart(
                                  order,
                                  cartCubit,
                                );
                                if (added > 0) {
                                  AppFeedback.showSnackBar(
                                    context,
                                    'تمت إضافة الأدوية إلى سلة المشتريات',
                                    type: FeedbackType.success,
                                  );
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const CustomerCartScreen(),
                                    ),
                                  );
                                } else {
                                  AppFeedback.showSnackBar(
                                    context,
                                    'الأدوية غير متوفرة حالياً',
                                    type: FeedbackType.information,
                                  );
                                }
                              },
                              icon: const Icon(Icons.replay_rounded),
                              label: const Text('إعادة طلب نفس الأدوية'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;

  const _CostRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

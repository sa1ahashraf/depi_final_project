import 'package:flutter/material.dart';
import 'package:depi_final_project/core/theme/app_colors.dart';
import 'package:depi_final_project/core/theme/app_styles.dart';
import 'package:depi_final_project/features/customer/cart/data/models/cart_pharmacy_group.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/cart_item_model.dart';

class CartPharmacyGroupCard extends StatelessWidget {
  final CartPharmacyGroup group;
  final double deliveryFee;
  final VoidCallback onToggleSelect;
  final VoidCallback onSelectOnly;
  final ValueChanged<CartItemModel> onIncrement;
  final ValueChanged<CartItemModel> onDecrement;
  final ValueChanged<CartItemModel> onRemoveItem;

  const CartPharmacyGroupCard({
    super.key,
    required this.group,
    required this.deliveryFee,
    required this.onToggleSelect,
    required this.onSelectOnly,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = group.isSelected;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: onToggleSelect,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFF94A3B8),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.pharmacyName,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (group.pharmacyAddress != null &&
                          group.pharmacyAddress!.isNotEmpty)
                        Text(
                          group.pharmacyAddress!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (group.pharmacyDeliveryTime != null &&
                          group.pharmacyDeliveryTime!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                size: 13,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  'التوصيل خلال ${group.pharmacyDeliveryTime}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onSelectOnly,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: const Text(
                      'هذه الصيدلية فقط',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Items list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              children: [
                for (int i = 0; i < group.items.length; i++) ...[
                  _CartItemRow(
                    cartItem: group.items[i],
                    onIncrement: () => onIncrement(group.items[i]),
                    onDecrement: () => onDecrement(group.items[i]),
                    onRemove: () => onRemoveItem(group.items[i]),
                  ),
                  if (i < group.items.length - 1)
                    const Divider(height: 12, color: Color(0xFFF1F5F9)),
                ],
              ],
            ),
          ),

          // Footer subtotal + delivery fee
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'مجموع الأدوية (${group.itemCount} أصناف) + توصيل ${deliveryFee.toStringAsFixed(0)} ج.م',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(group.subtotal + deliveryFee).toStringAsFixed(0)} ج.م',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItemModel cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemRow({
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Medicine info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.item.name,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${cartItem.item.unitDescription} • ${cartItem.item.price.toStringAsFixed(0)} ج.م للعبوة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'الإجمالي: ${cartItem.totalPrice.toStringAsFixed(0)} ج.م',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Stepper + Delete
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primary,
                  size: 22,
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                tooltip: 'زيادة الكمية',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '${cartItem.quantity}',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: AppColors.error,
                  size: 22,
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                tooltip: 'تقليل الكمية',
              ),
              const SizedBox(width: 2),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                tooltip: 'حذف الدواء',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

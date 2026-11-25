import 'package:flutter/material.dart';
import 'package:depi_final_project/core/theme/app_colors.dart';
import 'package:depi_final_project/core/theme/app_styles.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';

class MedicineCardWidget extends StatelessWidget {
  final PharmacyInventoryItemModel item;
  final VoidCallback onAddToCart;

  const MedicineCardWidget({
    super.key,
    required this.item,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = !item.isAvailable || item.quantity <= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isOutOfStock
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFE2EBE8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Plus Button (Disabled and faded when out of stock)
          Material(
            color: isOutOfStock ? const Color(0xFFF1F5F9) : AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: isOutOfStock ? null : onAddToCart,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.add,
                  color: isOutOfStock ? const Color(0xFF94A3B8) : Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Center: Name, Formula, Price & Stock
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Title (English)
                Text(
                  item.name,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isOutOfStock
                        ? const Color(0xFF64748B)
                        : AppColors.textPrimary,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 2),

                // Description / Active ingredients (Arabic)
                Text(
                  item.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11.5,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Price & Stock row
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Stock badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFE6F5EF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isOutOfStock ? 'غير متوفر' : _formatStock(item.quantity),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isOutOfStock
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF0F766E),
                            fontWeight: FontWeight.w700,
                            fontSize: 10.5,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Price with ج.م
                      Text(
                        '${item.price.toStringAsFixed(0)} ج.م',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: isOutOfStock
                              ? const Color(0xFF94A3B8)
                              : AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right: Dose Icon and Unit description container
          Container(
            width: 58,
            height: 62,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF6FAF9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5EDE9)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUnitIcon(item.iconType),
                const SizedBox(height: 4),
                Text(
                  item.unitDescription,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatStock(int quantity) {
    if (quantity >= 3 && quantity <= 10) {
      return 'متوفر $quantity علب';
    }
    return 'متوفر $quantity علبة';
  }

  Widget _buildUnitIcon(MedicineIconType type) {
    switch (type) {
      case MedicineIconType.vitamin:
        return const Icon(
          Icons.health_and_safety_outlined,
          color: Color(0xFFD97706),
          size: 22,
        );
      case MedicineIconType.capsule:
        return const Icon(
          Icons.healing_outlined,
          color: AppColors.primary,
          size: 22,
        );
      case MedicineIconType.syrup:
        return const Icon(
          Icons.local_drink_outlined,
          color: AppColors.primary,
          size: 22,
        );
      case MedicineIconType.tablets:
        return const Icon(
          Icons.medication_outlined,
          color: AppColors.primary,
          size: 22,
        );
    }
  }
}

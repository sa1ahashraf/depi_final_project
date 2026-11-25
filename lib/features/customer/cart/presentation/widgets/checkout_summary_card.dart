import 'package:flutter/material.dart';
import 'package:depi_final_project/core/theme/app_colors.dart';
import 'package:depi_final_project/core/theme/app_styles.dart';

class CheckoutSummaryCard extends StatelessWidget {
  final double itemsSubtotal;
  final double deliveryFeePerPharmacy;
  final int selectedPharmacyCount;
  final String selectedPaymentMethod;
  final ValueChanged<String> onPaymentMethodChanged;

  const CheckoutSummaryCard({
    super.key,
    required this.itemsSubtotal,
    required this.deliveryFeePerPharmacy,
    required this.selectedPharmacyCount,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
  });

  static const List<String> paymentOptions = [
    'دفع عند الاستلام',
    'إكسترا باي InstaPay',
    'فودافون كاش',
  ];

  @override
  Widget build(BuildContext context) {
    final totalDeliveryFee = selectedPharmacyCount * deliveryFeePerPharmacy;
    final grandTotal = itemsSubtotal + totalDeliveryFee;

    return Container(
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
                Icons.payments_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'طريقة الدفع',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: paymentOptions.map((method) {
              final isSelected = selectedPaymentMethod == method;
              return ChoiceChip(
                label: Text(method),
                selected: isSelected,
                onSelected: (_) => onPaymentMethodChanged(method),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),

          const Divider(height: 24, color: Color(0xFFF1F5F9)),

          Text(
            'ملخص الفاتورة',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'إجمالي الأدوية المحددة',
            value: '${itemsSubtotal.toStringAsFixed(0)} ج.م',
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label:
                'رسوم التوصيل ($selectedPharmacyCount × ${deliveryFeePerPharmacy.toStringAsFixed(0)} ج.م)',
            value: '${totalDeliveryFee.toStringAsFixed(0)} ج.م',
          ),
          if (selectedPharmacyCount > 1) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سيتم إنشاء $selectedPharmacyCount طلبات مستقلة (طلب لكل صيدلية) لتتمكن من تتبع كل صيدلية على حدة.',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 20, color: Color(0xFFE2E8F0)),
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
                '${grandTotal.toStringAsFixed(0)} ج.م',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

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
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

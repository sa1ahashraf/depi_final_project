import 'package:flutter/material.dart';
import 'package:depi_final_project/core/models/address_model.dart';
import 'package:depi_final_project/core/theme/app_colors.dart';
import 'package:depi_final_project/core/theme/app_styles.dart';
import 'package:depi_final_project/core/utils/validators.dart';
import 'package:depi_final_project/core/widgets/buttons/primary_button.dart';
import 'package:depi_final_project/core/widgets/inputs/app_text_fields.dart';

class DeliveryAddressSection extends StatelessWidget {
  final List<AddressModel> savedAddresses;
  final AddressModel? selectedAddress;
  final ValueChanged<AddressModel> onSelectAddress;
  final Future<void> Function({
    required String label,
    required String addressLine,
    required String phone,
  })
  onAddAddress;

  const DeliveryAddressSection({
    super.key,
    required this.savedAddresses,
    required this.selectedAddress,
    required this.onSelectAddress,
    required this.onAddAddress,
  });

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'عنوان التوصيل',
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
              ),
              TextButton.icon(
                onPressed: () => _showAddAddressSheet(context),
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text('إضافة عنوان'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),

          if (savedAddresses.isNotEmpty) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: savedAddresses.map((addr) {
                  final isSelected = selectedAddress?.id == addr.id;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(addr.label),
                      selected: isSelected,
                      onSelected: (_) => onSelectAddress(addr),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 10),

          if (selectedAddress != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2EBE8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary20,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          selectedAddress!.label,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedAddress!.phone,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedAddress!.address,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning15,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'لم يتم تحديد عنوان توصيل بعد. يرجى إضافة عنوان لإتمام الطلب.',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final labelCtrl = TextEditingController(text: 'المنزل');
    final addressCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'إضافة عنوان توصيل جديد',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: labelCtrl,
                    label: 'تسمية العنوان (مثال: المنزل، العمل)',
                    prefixIcon: const Icon(Icons.bookmark_border_rounded),
                    validator: AppValidators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: addressCtrl,
                    label: 'العنوان بالتفصيل',
                    hint: 'الشارع، رقم العمارة، الدور، الشقة',
                    prefixIcon: const Icon(Icons.home_outlined),
                    maxLines: 2,
                    validator: AppValidators.required,
                  ),
                  const SizedBox(height: 12),
                  AppPhoneField(
                    controller: phoneCtrl,
                    validator: AppValidators.egyptianPhone,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'حفظ واستخدام هذا العنوان',
                    icon: const Icon(Icons.check_rounded, size: 18),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      Navigator.pop(sheetContext);
                      await onAddAddress(
                        label: labelCtrl.text,
                        addressLine: addressCtrl.text,
                        phone: phoneCtrl.text,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

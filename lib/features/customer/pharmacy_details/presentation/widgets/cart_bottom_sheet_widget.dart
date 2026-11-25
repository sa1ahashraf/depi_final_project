import 'package:flutter/material.dart';
import 'package:depi_final_project/core/theme/app_colors.dart';
import 'package:depi_final_project/core/theme/app_styles.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/cart_item_model.dart';

class CartBottomSheetWidget extends StatefulWidget {
  final Map<String, CartItemModel> cart;
  final double totalAmount;
  final ValueChanged<CartItemModel> onIncrement;
  final ValueChanged<CartItemModel> onDecrement;
  final VoidCallback onCheckout;
  final void Function(Set<String> selectedPharmacyIds, double selectedTotal)?
      onCheckoutSelected;

  const CartBottomSheetWidget({
    super.key,
    required this.cart,
    required this.totalAmount,
    required this.onIncrement,
    required this.onDecrement,
    required this.onCheckout,
    this.onCheckoutSelected,
  });

  @override
  State<CartBottomSheetWidget> createState() => _CartBottomSheetWidgetState();
}

class _CartBottomSheetWidgetState extends State<CartBottomSheetWidget> {
  late Set<String> _selectedPharmacyIds;

  @override
  void initState() {
    super.initState();
    // By default, select all pharmacies in cart
    _selectedPharmacyIds = _extractPharmacyIds(widget.cart);
  }

  @override
  void didUpdateWidget(covariant CartBottomSheetWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentPharmacies = _extractPharmacyIds(widget.cart);
    _selectedPharmacyIds.retainAll(currentPharmacies);
    if (_selectedPharmacyIds.isEmpty && currentPharmacies.isNotEmpty) {
      _selectedPharmacyIds = Set<String>.from(currentPharmacies);
    }
  }

  Set<String> _extractPharmacyIds(Map<String, CartItemModel> cart) {
    return cart.values.map((e) => e.effectivePharmacyId).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = widget.cart.values.toList();

    // Group items by pharmacy ID
    final Map<String, List<CartItemModel>> groupedItems = {};
    for (final cartItem in allItems) {
      final phId = cartItem.effectivePharmacyId;
      groupedItems.putIfAbsent(phId, () => []).add(cartItem);
    }

    final allPharmacyIds = groupedItems.keys.toSet();
    final isAllSelected = allPharmacyIds.isNotEmpty &&
        _selectedPharmacyIds.length == allPharmacyIds.length;

    // Calculate selected total and selected items count
    double selectedTotal = 0.0;
    int selectedItemCount = 0;
    for (final entry in groupedItems.entries) {
      if (_selectedPharmacyIds.contains(entry.key)) {
        for (final item in entry.value) {
          selectedTotal += item.totalPrice;
          selectedItemCount += item.quantity;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title Row matching screenshot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${allItems.length} أصناف',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  'سلة المشتريات',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const Divider(height: 16),

            // Multi-Pharmacy helper bar (when > 1 pharmacy)
            if (groupedItems.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isAllSelected) {
                            _selectedPharmacyIds.clear();
                          } else {
                            _selectedPharmacyIds =
                                Set<String>.from(allPharmacyIds);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAllSelected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 16,
                              color: const Color(0xFF005C53),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAllSelected ? 'إلغاء تحديد الكل' : 'تحديد الكل',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF005C53),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'الأدوية مقسمة حسب ${groupedItems.length} صيدليات:',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            if (allItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'السلة فارغة حالياً',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.52,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: groupedItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, groupIndex) {
                    final phId = groupedItems.keys.elementAt(groupIndex);
                    final pharmacyItems = groupedItems[phId]!;
                    final firstItem = pharmacyItems.first;
                    final isPharmacySelected =
                        _selectedPharmacyIds.contains(phId);

                    final groupSubtotal = pharmacyItems.fold(
                      0.0,
                      (sum, item) => sum + item.totalPrice,
                    );

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isPharmacySelected
                              ? const Color(0xFF005C53)
                              : const Color(0xFFE2E8F0),
                          width: isPharmacySelected ? 1.5 : 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Pharmacy Header with Checkbox & Quick "Select Only" Action
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isPharmacySelected
                                  ? const Color(0xFFF0FDF4)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Pharmacy selection checkbox
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isPharmacySelected) {
                                        _selectedPharmacyIds.remove(phId);
                                      } else {
                                        _selectedPharmacyIds.add(phId);
                                      }
                                    });
                                  },
                                  child: Icon(
                                    isPharmacySelected
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked,
                                    size: 22,
                                    color: isPharmacySelected
                                        ? const Color(0xFF005C53)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Pharmacy Name & Address
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        firstItem.effectivePharmacyName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (firstItem.pharmacyAddress != null)
                                        Text(
                                          firstItem.pharmacyAddress!,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: Color(0xFF64748B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Quick button: "طلب هذه الصيدلية فقط"
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedPharmacyIds = {phId};
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    child: const Text(
                                      'هذه الصيدلية فقط',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF005C53),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 1, color: Color(0xFFF1F5F9)),

                          // Medicine Items list under this pharmacy
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Column(
                              children: pharmacyItems.map((cartItem) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Quantity controls
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                              color: AppColors.primary,
                                              size: 22,
                                            ),
                                            onPressed: () =>
                                                widget.onIncrement(cartItem),
                                            constraints:
                                                const BoxConstraints(),
                                            padding: const EdgeInsets.all(4),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: Text(
                                              '${cartItem.quantity}',
                                              style: AppTextStyles.labelLarge
                                                  .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Color(0xFFDC2626),
                                              size: 22,
                                            ),
                                            onPressed: () =>
                                                widget.onDecrement(cartItem),
                                            constraints:
                                                const BoxConstraints(),
                                            padding: const EdgeInsets.all(4),
                                          ),
                                        ],
                                      ),

                                      // Item description & price
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              cartItem.item.name,
                                              style: AppTextStyles.labelLarge
                                                  .copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13.5,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                            Text(
                                              '${cartItem.item.price.toStringAsFixed(0)} ج.م × ${cartItem.quantity} = ${cartItem.totalPrice.toStringAsFixed(0)} ج.م',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // Pharmacy Group Subtotal footer
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(15),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${groupSubtotal.toStringAsFixed(0)} ج.م',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF005C53),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'المجموع (${firstItem.effectivePharmacyName}):',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
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
                    );
                  },
                ),
              ),

            const Divider(height: 20),

            // Selected Summary Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedTotal.toStringAsFixed(0)} ج.م',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 20,
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'الإجمالي للمحدد للشراء',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '($_selectedPharmaciesCountText - $selectedItemCount أصناف)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Checkout Button
            ElevatedButton(
              onPressed: _selectedPharmacyIds.isEmpty
                  ? null
                  : () {
                      if (widget.onCheckoutSelected != null) {
                        widget.onCheckoutSelected!(
                          _selectedPharmacyIds,
                          selectedTotal,
                        );
                      } else {
                        widget.onCheckout();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                _checkoutButtonLabel(
                  groupedItems,
                  _selectedPharmacyIds,
                  selectedTotal,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _selectedPharmaciesCountText {
    final count = _selectedPharmacyIds.length;
    if (count == 0) return 'لا توجد صيدلية محددة';
    if (count == 1) return 'صيدلية واحدة';
    if (count == 2) return 'صيدليتان';
    return '$count صيدليات';
  }

  String _checkoutButtonLabel(
    Map<String, List<CartItemModel>> groupedItems,
    Set<String> selectedIds,
    double total,
  ) {
    if (selectedIds.isEmpty) {
      return 'يرجى تحديد صيدلية واحدة على الأقل';
    }
    if (selectedIds.length == 1) {
      final phId = selectedIds.first;
      final phName =
          groupedItems[phId]?.first.effectivePharmacyName ?? 'الصيدلية';
      return 'متابعة طلب $phName (${total.toStringAsFixed(0)} ج.م)';
    }
    if (selectedIds.length == groupedItems.length) {
      return 'إتمام الطلب لجميع الصيدليات (${total.toStringAsFixed(0)} ج.م)';
    }
    return 'إتمام طلب الصيدليات المحددة (${selectedIds.length}) (${total.toStringAsFixed(0)} ج.م)';
  }
}

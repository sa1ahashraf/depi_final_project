import 'package:flutter/material.dart';
import '../../data/models/search_filter_options.dart';

class FilterBottomSheet extends StatefulWidget {
  final SearchFilterOptions initialFilters;
  final List<String> categories;
  final ValueChanged<SearchFilterOptions> onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.categories,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required SearchFilterOptions currentFilters,
    required List<String> categories,
    required ValueChanged<SearchFilterOptions> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialFilters: currentFilters,
        categories: categories,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late SearchFilterOptions _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header (Title & Reset)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFF005C53),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'خيارات الفلترة والتصفية',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filters = const SearchFilterOptions();
                      });
                    },
                    child: const Text(
                      'إعادة تعيين',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFF1F5F9), thickness: 1),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Pharmacy Filters
                    _buildSectionHeader('فلاتر الصيدليات'),
                    _buildSwitchTile(
                      title: 'مفتوح الآن فقط',
                      subtitle: 'إظهار الصيدليات المتاحة للطلب الفوري حالياً',
                      value: _filters.openOnly,
                      onChanged: (val) {
                        setState(() {
                          _filters = _filters.copyWith(openOnly: val);
                        });
                      },
                    ),
                    _buildSwitchTile(
                      title: 'صيدليات معتمدة ومرخصة',
                      subtitle: 'صيدليات موثوقة ومطابقة لمعايير وزارة الصحة',
                      value: _filters.verifiedOnly,
                      onChanged: (val) {
                        setState(() {
                          _filters = _filters.copyWith(verifiedOnly: val);
                        });
                      },
                    ),
                    _buildSwitchTile(
                      title: 'توصيل فوري (أقل من 30 دقيقة)',
                      subtitle: 'صيدليات ذات سرعة توصيل عالية قريبة منك',
                      value: _filters.fastDeliveryOnly,
                      onChanged: (val) {
                        setState(() {
                          _filters = _filters.copyWith(fastDeliveryOnly: val);
                        });
                      },
                    ),
                    _buildSwitchTile(
                      title: 'دفع إلكتروني (InstaPay / فودافون كاش)',
                      subtitle: 'صيدليات تقبل الدفع الرقمي اللحظي',
                      value: _filters.digitalPaymentOnly,
                      onChanged: (val) {
                        setState(() {
                          _filters = _filters.copyWith(digitalPaymentOnly: val);
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Section 2: Medicine Filters
                    _buildSectionHeader('فلاتر الأدوية والمخزون'),
                    _buildSwitchTile(
                      title: 'الأدوية المتوفرة بالمخزون فقط',
                      subtitle: 'استبعاد الأدوية غير المتوفرة حالياً بالصيدلية',
                      value: _filters.inStockOnly,
                      onChanged: (val) {
                        setState(() {
                          _filters = _filters.copyWith(inStockOnly: val);
                        });
                      },
                    ),

                    const SizedBox(height: 12),
                    const Text(
                      'الشكل الصيدلاني:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFormChip('الكل', null),
                        _buildFormChip('أقراص', 'أقراص'),
                        _buildFormChip('كبسولات', 'كبسولات'),
                        _buildFormChip('شراب', 'شراب'),
                        _buildFormChip('فوار / أكياس', 'فوار'),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'التصنيف الطبي:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.categories.map((cat) {
                        final isSelected = _filters.selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _filters = _filters.copyWith(
                                selectedCategory: selected ? cat : 'الكل',
                              );
                            });
                          },
                          selectedColor: const Color(0xFF005C53),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF005C53)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_filters);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005C53),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'تطبيق الفلاتر (${_filters.activeCount} نشط)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        value: value,
        activeColor: const Color(0xFF005C53),
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        dense: true,
      ),
    );
  }

  Widget _buildFormChip(String label, String? formValue) {
    final isSelected = _filters.medicineForm == formValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filters = _filters.copyWith(
            medicineForm: selected ? formValue : null,
            clearForm: !selected,
          );
        });
      },
      selectedColor: const Color(0xFF005C53),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF334155),
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? const Color(0xFF005C53) : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }
}

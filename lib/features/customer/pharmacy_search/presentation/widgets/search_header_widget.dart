import 'package:flutter/material.dart';

class SearchHeaderWidget extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onChangeLocation;
  final VoidCallback? onOpenCart;
  final int cartItemCount;
  final VoidCallback? onOpenOrders;
  final int activeOrdersCount;

  const SearchHeaderWidget({
    super.key,
    this.onBack,
    this.onChangeLocation,
    this.onOpenCart,
    this.cartItemCount = 0,
    this.onOpenOrders,
    this.activeOrdersCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (onBack != null && Navigator.of(context).canPop())
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_forward_ios, size: 20),
                  color: const Color(0xFF0F172A),
                  tooltip: 'رجوع',
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'البحث في جميع الصيدليات',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'مباشر',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    InkWell(
                      onTap: onChangeLocation,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Color(0xFF005C53),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'المعادي، القاهرة • ضمن نطاق 5 كم',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (onOpenOrders != null)
                IconButton(
                  onPressed: onOpenOrders,
                  tooltip: 'طلباتي',
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                  icon: Badge(
                    isLabelVisible: activeOrdersCount > 0,
                    label: Text('$activeOrdersCount'),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: Color(0xFF005C53),
                      size: 22,
                    ),
                  ),
                ),
              if (onOpenCart != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onOpenCart,
                  tooltip: 'سلة المشتريات',
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                  icon: Badge(
                    isLabelVisible: cartItemCount > 0,
                    label: Text('$cartItemCount'),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Color(0xFF005C53),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

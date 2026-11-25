import 'package:flutter/material.dart';
import 'package:depi_final_project/core/enums/order_status.dart';
import 'package:depi_final_project/features/customer/orders/data/models/order_display_helpers.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool compact;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: status.badgeBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: compact ? 13 : 15,
            color: status.badgeTextColor,
          ),
          const SizedBox(width: 5),
          Text(
            status.arabicLabel,
            style: TextStyle(
              color: status.badgeTextColor,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

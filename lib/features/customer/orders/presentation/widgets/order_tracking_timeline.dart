import 'package:flutter/material.dart';
import 'package:depi_final_project/core/enums/order_status.dart';
import 'package:depi_final_project/core/models/order_model.dart';
import 'package:depi_final_project/core/theme/app_colors.dart';
import 'package:depi_final_project/core/theme/app_styles.dart';
import 'package:depi_final_project/features/customer/orders/data/models/order_display_helpers.dart';

class OrderTrackingTimeline extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingTimeline({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.status;

    if (status == OrderStatus.rejected || status == OrderStatus.cancelled) {
      final isRejected = status == OrderStatus.rejected;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: status.badgeBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: status.badgeTextColor.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(status.icon, color: status.badgeTextColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.arabicLabel,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: status.badgeTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.arabicDescription,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  if (isRejected &&
                      order.rejectionReason != null &&
                      order.rejectionReason!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'سبب الرفض: ${order.rejectionReason}',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    final currentStep = status.trackingStepIndex;
    final steps = OrderDisplayHelpers.trackingSteps;

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
                Icons.timeline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'مراحل تتبع الطلب',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < steps.length; i++)
            _TimelineStepTile(
              stepStatus: steps[i],
              isCompleted: i < currentStep || status == OrderStatus.completed,
              isCurrent: i == currentStep && status != OrderStatus.completed,
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineStepTile extends StatelessWidget {
  final OrderStatus stepStatus;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  const _TimelineStepTile({
    required this.stepStatus,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = isCompleted || isCurrent;
    final Color circleColor = isCompleted
        ? AppColors.success
        : (isCurrent ? AppColors.primary : const Color(0xFFE2E8F0));
    final Color lineColor =
        isCompleted ? AppColors.success : const Color(0xFFE2E8F0);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive ? circleColor : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? circleColor : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : stepStatus.icon,
                  size: 15,
                  color: isActive ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: lineColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stepStatus.arabicLabel,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: isCurrent || isCompleted
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isActive
                          ? AppColors.textPrimary
                          : const Color(0xFF94A3B8),
                      fontSize: 13.5,
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(height: 3),
                    Text(
                      stepStatus.arabicDescription,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF475569),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

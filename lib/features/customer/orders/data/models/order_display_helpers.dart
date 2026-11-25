import 'package:flutter/material.dart';
import 'package:depi_final_project/core/constants/firestore_fields.dart';
import 'package:depi_final_project/core/enums/order_status.dart';
import 'package:depi_final_project/core/models/order_model.dart';
import 'package:depi_final_project/core/theme/app_colors.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/data/repositories/firebase_pharmacy_search_repository.dart';

/// Display metadata and domain helpers for [OrderStatus] and [OrderModel].
extension OrderStatusDisplayX on OrderStatus {
  String get arabicLabel {
    switch (this) {
      case OrderStatus.pending:
        return 'بانتظار موافقة الصيدلية';
      case OrderStatus.accepted:
        return 'تم قبول الطلب';
      case OrderStatus.preparing:
        return 'جاري تحضير الأدوية';
      case OrderStatus.ready:
        return 'جاهز للتوصيل';
      case OrderStatus.completed:
        return 'تم التسليم';
      case OrderStatus.rejected:
        return 'مرفوض من الصيدلية';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  String get arabicDescription {
    switch (this) {
      case OrderStatus.pending:
        return 'تم إرسال طلبك للصيدلية وجاري مراجعة توافر الأدوية.';
      case OrderStatus.accepted:
        return 'وافقت الصيدلية على طلبك وسيتم البدء في تجهيزه قريباً.';
      case OrderStatus.preparing:
        return 'الصيدلي يقوم بتجهيز ومراجعة الأدوية الخاصة بطلبك الآن.';
      case OrderStatus.ready:
        return 'طلبك جاهز ومغلف وفي طريقه للتسليم إلى عنوانك.';
      case OrderStatus.completed:
        return 'تم تسليم الطلب بنجاح. نتمنى لك دوام الصحة والعافية!';
      case OrderStatus.rejected:
        return 'نعتذر، تعذر تنفيذ هذا الطلب من قبل الصيدلية.';
      case OrderStatus.cancelled:
        return 'تم إلغاء هذا الطلب بناءً على رغبتك.';
    }
  }

  Color get badgeTextColor {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.accepted:
        return AppColors.secondary;
      case OrderStatus.preparing:
        return const Color(0xFF1D4ED8);
      case OrderStatus.ready:
        return const Color(0xFF7C3AED);
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.rejected:
        return AppColors.error;
      case OrderStatus.cancelled:
        return const Color(0xFF64748B);
    }
  }

  Color get badgeBackgroundColor {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.warning15;
      case OrderStatus.accepted:
        return AppColors.primary20;
      case OrderStatus.preparing:
        return const Color(0xFFDBEAFE);
      case OrderStatus.ready:
        return const Color(0xFFEDE9FE);
      case OrderStatus.completed:
        return AppColors.success15;
      case OrderStatus.rejected:
        return const Color(0xFFFEE2E2);
      case OrderStatus.cancelled:
        return const Color(0xFFF1F5F9);
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_top_rounded;
      case OrderStatus.accepted:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.preparing:
        return Icons.medication_liquid_rounded;
      case OrderStatus.ready:
        return Icons.delivery_dining_rounded;
      case OrderStatus.completed:
        return Icons.verified_rounded;
      case OrderStatus.rejected:
        return Icons.error_outline_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  /// Zero-based index along the happy-path tracking timeline (-1 if terminal failure).
  int get trackingStepIndex {
    switch (this) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.accepted:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.ready:
        return 3;
      case OrderStatus.completed:
        return 4;
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return -1;
    }
  }

  bool get isActive => !isFinal;
}

class OrderDisplayHelpers {
  OrderDisplayHelpers._();

  static const List<OrderStatus> trackingSteps = [
    OrderStatus.pending,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.completed,
  ];

  static String shortOrderCode(String orderId) {
    final cleaned = orderId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (cleaned.length <= 6) return '#${cleaned.toUpperCase()}';
    return '#${cleaned.substring(cleaned.length - 6).toUpperCase()}';
  }

  static String resolvePharmacyName(String pharmacyId) {
    for (final pharmacy in FirebasePharmacySearchRepository.defaultPharmacies) {
      if (pharmacy.id == pharmacyId) {
        return pharmacy.name;
      }
    }
    if (pharmacyId.isEmpty) return 'الصيدلية';
    return pharmacyId;
  }

  static double itemsSubtotal(OrderModel order) {
    return order.items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Ensures consistent display whether [OrderModel.totalPrice] already includes
  /// [OrderModel.deliveryFee] or represents only the items subtotal.
  static double finalPayableTotal(OrderModel order) {
    final subtotal = itemsSubtotal(order);
    if (order.totalPrice >= subtotal + order.deliveryFee - 0.01) {
      return order.totalPrice;
    }
    return subtotal + order.deliveryFee;
  }

  static String addressLabel(Map<String, dynamic> addressMap) {
    final label = addressMap[FirestoreFields.label]?.toString().trim() ?? '';
    return label.isNotEmpty ? label : 'عنوان التوصيل';
  }

  static String addressLine(Map<String, dynamic> addressMap) {
    final line = addressMap[FirestoreFields.address]?.toString().trim() ?? '';
    return line.isNotEmpty ? line : 'غير محدد';
  }

  static String addressPhone(Map<String, dynamic> addressMap) {
    return addressMap[FirestoreFields.phone]?.toString().trim() ?? '';
  }

  static String formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour24 = dt.hour;
    final period = hour24 >= 12 ? 'م' : 'ص';
    final hour12 = (hour24 % 12 == 0 ? 12 : hour24 % 12).toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour12:$minute $period';
  }
}

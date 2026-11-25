import 'package:flutter/material.dart';

enum PharmacySortOption {
  nearest,
  highestRating,
  fastestDelivery,
  lowestPrice,
}

extension PharmacySortOptionExtension on PharmacySortOption {
  String get label {
    switch (this) {
      case PharmacySortOption.nearest:
        return 'الأقرب إليك';
      case PharmacySortOption.highestRating:
        return 'الأعلى تقييماً';
      case PharmacySortOption.fastestDelivery:
        return 'الأسرع توصيلاً';
      case PharmacySortOption.lowestPrice:
        return 'الأقل سعراً';
    }
  }

  IconData get icon {
    switch (this) {
      case PharmacySortOption.nearest:
        return Icons.near_me_outlined;
      case PharmacySortOption.highestRating:
        return Icons.star_rounded;
      case PharmacySortOption.fastestDelivery:
        return Icons.bolt_rounded;
      case PharmacySortOption.lowestPrice:
        return Icons.payments_outlined;
    }
  }
}

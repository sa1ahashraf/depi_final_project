import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';

class PharmacySearchResultModel {
  final PharmacyDetailModel pharmacy;
  final List<PharmacyInventoryItemModel> matchedMedicines;
  final int totalMedicineCount;
  final double? lowestPrice;
  final int deliveryMinutes;

  const PharmacySearchResultModel({
    required this.pharmacy,
    required this.matchedMedicines,
    required this.totalMedicineCount,
    this.lowestPrice,
    required this.deliveryMinutes,
  });

  PharmacySearchResultModel copyWith({
    PharmacyDetailModel? pharmacy,
    List<PharmacyInventoryItemModel>? matchedMedicines,
    int? totalMedicineCount,
    double? lowestPrice,
    int? deliveryMinutes,
  }) {
    return PharmacySearchResultModel(
      pharmacy: pharmacy ?? this.pharmacy,
      matchedMedicines: matchedMedicines ?? this.matchedMedicines,
      totalMedicineCount: totalMedicineCount ?? this.totalMedicineCount,
      lowestPrice: lowestPrice ?? this.lowestPrice,
      deliveryMinutes: deliveryMinutes ?? this.deliveryMinutes,
    );
  }
}

import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';

abstract class PharmacyDetailsRepository {
  Stream<PharmacyDetailModel> getPharmacyDetailsStream(String pharmacyId);

  Stream<List<PharmacyInventoryItemModel>> getPharmacyInventoryStream(
    String pharmacyId,
  );

  Future<void> seedDefaultPharmacyData(String pharmacyId);
}

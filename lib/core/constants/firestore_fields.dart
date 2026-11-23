abstract final class FirestoreFields {
  // Common
  static const String id = 'id';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String isActive = 'isActive';

  // Users
  static const String uid = 'uid';
  static const String name = 'name';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String role = 'role';
  static const String photoUrl = 'photoUrl';

  // Pharmacies
  static const String ownerId = 'ownerId';
  static const String pharmacyId = 'pharmacyId';
  static const String approvalStatus = 'approvalStatus';
  static const String rejectionReason = 'rejectionReason';
  static const String address = 'address';
  static const String location = 'location';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String imageUrl = 'imageUrl';

  // Medicine Catalog
  static const String medicineId = 'medicineId';
  static const String genericName = 'genericName';
  static const String strength = 'strength';
  static const String form = 'form';
  static const String category = 'category';
  static const String description = 'description';
  static const String searchKeywords = 'searchKeywords';

  // Inventory
  static const String price = 'price';
  static const String quantity = 'quantity';
  static const String isAvailable = 'isAvailable';
  static const String publicVisible = 'publicVisible';

  // Orders
  static const String customerId = 'customerId';
  static const String items = 'items';
  static const String totalPrice = 'totalPrice';
  static const String unitPrice = 'unitPrice';
  static const String subtotal = 'subtotal';
  static const String deliveryFee = 'deliveryFee';
  static const String deliveryAddress = 'deliveryAddress';
  static const String status = 'status';

  // Addresses
  static const String userId = 'userId';
  static const String label = 'label';
  static const String isDefault = 'isDefault';

  // Admin
  static const String reviewedAt = 'reviewedAt';
  static const String reviewedBy = 'reviewedBy';
}

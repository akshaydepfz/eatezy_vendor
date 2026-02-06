class OfferModel {
  String id;
  String vendorId;
  String productId;
  String productName;
  String productImage;
  String title;
  String discountType; // 'percentage' or 'fixed'
  double discountValue;
  String? startDate;
  String? endDate;
  bool isActive;
  String createdAt;

  OfferModel({
    required this.id,
    required this.vendorId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.title,
    required this.discountType,
    required this.discountValue,
    this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
  });

  factory OfferModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OfferModel(
      id: id,
      vendorId: data['vendorId'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productImage: data['productImage'] ?? '',
      title: data['title'] ?? '',
      discountType: data['discountType'] ?? 'percentage',
      discountValue: data['discountValue'] != null
          ? double.parse(data['discountValue'].toString())
          : 0.0,
      startDate: data['startDate']?.toString(),
      endDate: data['endDate']?.toString(),
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vendorId': vendorId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'title': title,
      'discountType': discountType,
      'discountValue': discountValue,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}

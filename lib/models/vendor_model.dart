class VendorModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String password;
  final String shopName;
  final String shopAddress;
  final String vendorImage;
  final String shopImage;
  bool isActive;
  final String estimateTime;
  final String estimateDistance;
  final String lat;
  final String long;
  final String banner;
  final String packingFee;
  final String openingTime;
  final String closingTime;

  VendorModel(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.phone,
      required this.email,
      required this.password,
      required this.shopName,
      required this.shopAddress,
      required this.vendorImage,
      required this.shopImage,
      required this.isActive,
      required this.estimateTime,
      required this.estimateDistance,
      required this.lat,
      required this.long,
      required this.banner,
      required this.packingFee,
      required this.openingTime,
      required this.closingTime});

  factory VendorModel.fromFirestore(
    Map<String, dynamic> data,
    String id, {
    String? estimateDistance,
    String? estimateTime,
  }) {
    return VendorModel(
        id: id,
        firstName: data['first_name'] ?? '',
        lastName: data['last_name'] ?? '',
        phone: data['phone'] ?? '',
        email: data['email'] ?? '',
        password: data['password'] ?? '',
        shopName: data['shop_name'] ?? '',
        shopAddress: data['shop_address'] ?? '',
        vendorImage: data['vendor_image'] ?? '',
        shopImage: data['shop_image'] ?? '',
        isActive: data['is_active'] ?? false,
        estimateDistance: estimateDistance ?? data['estimateDistance'] ?? '',
        estimateTime: estimateTime ?? data['estimateTime'] ?? '',
        lat: data['lat'] ?? '',
        long: data['long'] ?? '',
        banner: data['banner'] ?? '',
        packingFee: data['packing_fee']?.toString() ?? '0',
        openingTime: data['opening_time']?.toString() ?? '09:00',
        closingTime: data['closing_time']?.toString() ?? '22:00');
  }
}

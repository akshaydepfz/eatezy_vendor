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
  final bool isSuspend;
  final String estimateTime;
  final String estimateDistance;
  final String lat;
  final String long;
  final String banner;
  final String packingFee;

  /// Whether this vendor accepts online ordering / delivery (backed by is_online_ordering).
  final bool isOnlineOrdering;

  /// Optional fallback for old data.
  final String openingTime;
  final String closingTime;

  /// Multiple time slots (e.g. 9:00–12:00, 17:00–22:00). Same format as product availability_slots.
  final List<Map<String, String>> openingHoursSlots;

  /// Returns openingTime from first slot if slots exist, else uses openingTime field.
  String get effectiveOpeningTime {
    if (openingHoursSlots.isNotEmpty &&
        openingHoursSlots.first['from']?.isNotEmpty == true) {
      return openingHoursSlots.first['from']!;
    }
    return openingTime;
  }

  /// Returns closingTime from first slot if slots exist, else uses closingTime field.
  String get effectiveClosingTime {
    if (openingHoursSlots.isNotEmpty &&
        openingHoursSlots.first['to']?.isNotEmpty == true) {
      return openingHoursSlots.first['to']!;
    }
    return closingTime;
  }

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
      required this.isSuspend,
      required this.estimateTime,
      required this.estimateDistance,
      required this.lat,
      required this.long,
      required this.banner,
      required this.packingFee,
      required this.isOnlineOrdering,
      required this.openingTime,
      required this.closingTime,
      this.openingHoursSlots = const []});

  static bool _parseBool(dynamic v, bool def) {
    if (v == null) return def;
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    if (v is int) return v != 0;
    return def;
  }

  factory VendorModel.fromFirestore(
    Map<String, dynamic> data,
    String id, {
    String? estimateDistance,
    String? estimateTime,
  }) {
    final openingTime = data['opening_time']?.toString() ?? '09:00';
    final closingTime = data['closing_time']?.toString() ?? '22:00';

    List<Map<String, String>> parsedSlots = [];
    final rawSlots = data['opening_hours_slots'];
    if (rawSlots is List) {
      parsedSlots = rawSlots
          .whereType<Map>()
          .map((slot) => {
                'from': (slot['from'] ?? '').toString(),
                'to': (slot['to'] ?? '').toString(),
              })
          .where((s) => (s['from'] ?? '').isNotEmpty || (s['to'] ?? '').isNotEmpty)
          .toList();
    }
    if (parsedSlots.isEmpty) {
      parsedSlots = [{'from': openingTime, 'to': closingTime}];
    }

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
        isActive: _parseBool(data['is_active'], false),
        isSuspend: _parseBool(data['is_suspend'], false),
        estimateDistance: estimateDistance ?? data['estimateDistance'] ?? '',
        estimateTime: estimateTime ?? data['estimateTime'] ?? '',
        lat: data['lat'] ?? '',
        long: data['long'] ?? '',
        banner: data['banner'] ?? '',
        packingFee: data['packing_fee']?.toString() ?? '0',
        isOnlineOrdering: _parseBool(data['is_online_ordering'], false),
        openingTime: openingTime,
        closingTime: closingTime,
        openingHoursSlots: parsedSlots);
  }
}

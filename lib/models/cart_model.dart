double _parsePackingFee(Map<String, dynamic> data) {
  // Backend may use packing_fee, package_fee, or packing_charge
  final value = data['packing_fee'] ?? data['package_fee'] ?? data['packing_charge'] ?? data['package_charge'];
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class CartModel {
  String id;
  String uuid;
  String vendorId;
  String createdDate;
  String customerName;
  String phone;
  String address;
  bool isPaid;
  String orderStatus;
  String deliveryBoyId;
  bool isDelivered;
  bool isCancelled;
  String cancellationReason;
  String deliveryType;
  bool isRated;
  String ratingText;
  double rating;
  String confimedTime;
  String driverGoShopTime;
  String orderPickedTime;
  String onTheWayTime;
  String orderDeliveredTime;
  int deliveryCharge;
  String lat;
  String long;
  String customerImage;
  String vendorName;
  String shopImage;
  String vendorPhone;
  String chatId;
  String discount;
  String totalPrice;
  String notes;
  double packingFee;

  /// Estimated preparation time in minutes (set when vendor confirms order).
  int preparationTimeMinutes;
  double platformCharge;
  List<OrderedProduct> products;

  CartModel(
      {required this.id,
      required this.uuid,
      required this.vendorId,
      required this.createdDate,
      required this.customerName,
      required this.phone,
      required this.address,
      required this.isPaid,
      required this.orderStatus,
      required this.deliveryBoyId,
      required this.isDelivered,
      required this.isCancelled,
      this.cancellationReason = '',
      required this.deliveryType,
      required this.isRated,
      required this.rating,
      required this.confimedTime,
      required this.driverGoShopTime,
      required this.orderPickedTime,
      required this.onTheWayTime,
      required this.orderDeliveredTime,
      required this.deliveryCharge,
      required this.lat,
      required this.long,
      required this.customerImage,
      required this.vendorName,
      required this.shopImage,
      required this.vendorPhone,
      required this.ratingText,
      required this.chatId,
      required this.products,
      required this.discount,
      required this.totalPrice,
      this.notes = '',
      this.packingFee = 0.0,
      this.platformCharge = 0.0,
      this.preparationTimeMinutes = 0});

  factory CartModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CartModel(
        id: id,
        uuid: data['uuid'],
        vendorId: data['vendor_id'],
        createdDate: data['created_date'],
        customerName: data['customer_name'],
        phone: data['phone'],
        address: data['address'],
        isPaid: data['isPaid'],
        orderStatus: data['order_status'],
        deliveryBoyId: data['deliveryBoyId'] ?? '',
        isDelivered: data['isDelivered'] ?? false,
        isCancelled: data['isCancelled'] ?? false,
        cancellationReason: data['cancellation_reason'] ?? '',
        deliveryType: data['delivery_type'] ?? '',
        isRated: data['is_rated'] ?? false,
        rating: data['star']?.toDouble() ?? 0.0,
        confimedTime: data['confrimTime'] ?? '',
        driverGoShopTime: data['driverShop'] ?? '',
        orderPickedTime: data['pickedTime'] ?? '',
        onTheWayTime: data['onTheWayTime'] ?? '',
        orderDeliveredTime: data['deliveredTime'] ?? '',
        deliveryCharge: data['delivery_charge'] ?? 0,
        lat: data['lat'] ?? '',
        long: data['long'] ?? '',
        customerImage: data['customer_image'] ?? '',
        vendorName: data['vendor_name'] ?? '',
        shopImage: data['shop_image'] ?? '',
        ratingText: data['rating_text'] ?? '',
        vendorPhone: data['vendor_phone'] ?? '',
        chatId: data['chat_id'] ?? '',
        products: (data['products'] as List<dynamic>)
            .map((e) => OrderedProduct.fromMap(e))
            .toList(),
        discount: data['discount'] ?? '',
        totalPrice: data['total'] ?? '',
        notes: data['notes'] ?? '',
        packingFee: _parsePackingFee(data),
        platformCharge: (data['platform_charge'] as num?)?.toDouble() ?? 0.0,
        preparationTimeMinutes: data['preparation_time'] != null
            ? int.tryParse(data['preparation_time'].toString()) ?? 0
            : 0);
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'vendor_id': vendorId,
      'created_date': createdDate,
      'customer_name': customerName,
      'phone': phone,
      'address': address,
      'isPaid': isPaid,
      'order_status': orderStatus,
      'deliveryBoyId': deliveryBoyId,
      'isDelivered': isDelivered,
      'isCancelled': isCancelled,
      'cancellation_reason': cancellationReason,
      'delivery_type': deliveryType,
      'is_rated': isRated,
      'star': rating,
      'confrimTime': confimedTime,
      'driverShop': driverGoShopTime,
      'pickedTime': orderPickedTime,
      'onTheWayTime': onTheWayTime,
      'deliveredTime': orderDeliveredTime,
      'delivery_charge': deliveryCharge,
      'lat': lat,
      'long': long,
      'customer_image': customerImage,
      'vendor_name': vendorName,
      'shop_image': shopImage,
      'vendor_phone': vendorPhone,
      'chat_id': chatId,
      'products': products.map((e) => e.toMap()).toList(),
      'discount': discount,
      'total': totalPrice,
      'notes': notes,
      'packing_fee': packingFee,
      'platform_charge': platformCharge,
      'preparation_time': preparationTimeMinutes,
      'rating_text': ratingText,
    };
  }
}

class OrderedProduct {
  String name;
  String image;
  String description;
  int quantity;
  double price;
  String unit;

  OrderedProduct({
    required this.name,
    required this.image,
    required this.description,
    required this.quantity,
    required this.price,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'description': description,
      'quantity': quantity,
      'price': price,
      'unit': unit,
    };
  }

  factory OrderedProduct.fromMap(Map<String, dynamic> map) {
    return OrderedProduct(
      name: map['name'],
      image: map['image'],
      description: map['description'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
      unit: map['unit'],
    );
  }
}

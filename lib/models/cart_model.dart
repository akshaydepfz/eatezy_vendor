class CartModel {
  String id;
  String name;
  String image;
  String description;
  String category;
  String unit;
  int stock;
  int maxOrder;
  double price;
  double slashedPrice;
  int itemCount;
  String uuid;
  String vendorId;
  String createdDate;
  String customerName;
  String phone;
  String address;
  String orderStatus;
  String deliveryType;
  String deliveryBoyID;
  int deliveryCharge;

  CartModel(
      {required this.id,
      required this.name,
      required this.image,
      required this.description,
      required this.category,
      required this.unit,
      required this.stock,
      required this.maxOrder,
      required this.price,
      required this.slashedPrice,
      required this.itemCount,
      required this.uuid,
      required this.vendorId,
      required this.createdDate,
      required this.address,
      required this.customerName,
      required this.phone,
      required this.orderStatus,
      required this.deliveryType,
      required this.deliveryBoyID,
      required this.deliveryCharge});

  // Create a factory method to map Firestore data to ProductModel
  factory CartModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CartModel(
        id: id,
        name: data['name'] ?? '',
        image: data['image'] ?? '',
        description: data['description'] ?? '',
        category: data['category'] ?? '',
        unit: data['unit'] ?? '',
        stock: data['stock'] != null ? int.parse(data['stock'].toString()) : 0,
        maxOrder: data['maxOrder'] != null
            ? int.parse(data['maxOrder'].toString())
            : 0,
        price: data['price'] != null
            ? double.parse(data['price'].toString())
            : 0.0,
        slashedPrice: data['slashedPrice'] != null
            ? double.parse(data['slashedPrice'].toString())
            : 0.0,
        itemCount: data['itemCount'],
        uuid: data['uuid'],
        vendorId: data['vendor_id'],
        createdDate: data['created_date'],
        customerName: data['customer_name'],
        phone: data['phone'],
        address: data['address'],
        orderStatus: data['order_status'],
        deliveryType: data['delivery_type'] ?? "",
        deliveryBoyID: data['deliveryBoyId'] ?? "",
        deliveryCharge: data['delivery_charge'] ?? 0);
  } // Method to convert ProductModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'description': description,
      'category': category,
      'unit': unit,
      'stock': stock,
      'maxOrder': maxOrder,
      'price': price,
      'slashedPrice': slashedPrice,
      'itemCount': itemCount,
      'uuid': uuid,
      'vendor_id': vendorId,
      'created_date': createdDate,
      'customer_name': customerName,
      'phone': phone,
      'address': address,
      'order_status': orderStatus,
    };
  }
}

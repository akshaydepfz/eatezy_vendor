class ProductModel {
  String id;
  String name;
  String image;
  String description;
  String category;
  String unit;
  int stock;
  int maxOrder;
  double price;
  String slashedPrice;
  String unitPerItem;
  /// Maps from Firestore is_active. When false, product is "sold out" (hidden from customers without deleting).
  bool isAvailable;
  final List<Map<String, String>> availabilitySlots;

  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.category,
    required this.unit,
    required this.stock,
    required this.maxOrder,
    required this.price,
    required this.slashedPrice,
    required this.unitPerItem,
    this.isAvailable = true,
    this.availabilitySlots = const [
      {'from': '09:00', 'to': '18:00'}
    ],
  });

  String get availableFromTime =>
      availabilitySlots.isNotEmpty ? (availabilitySlots.first['from'] ?? "09:00") : "09:00";

  String get availableToTime =>
      availabilitySlots.isNotEmpty ? (availabilitySlots.first['to'] ?? "18:00") : "18:00";

  // Create a factory method to map Firestore data to ProductModel
  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    final rawSlots = data['availability_slots'];
    List<Map<String, String>> parsedSlots = [];

    if (rawSlots is List) {
      parsedSlots = rawSlots
          .whereType<Map>()
          .map((slot) => {
                'from': (slot['from'] ?? '').toString(),
                'to': (slot['to'] ?? '').toString(),
              })
          .where((slot) => slot['from']!.isNotEmpty || slot['to']!.isNotEmpty)
          .toList();
    }

    if (parsedSlots.isEmpty) {
      parsedSlots = [
        {
          'from': (data['available_from_time'] ?? "09:00").toString(),
          'to': (data['available_to_time'] ?? "18:00").toString(),
        }
      ];
    }

    return ProductModel(
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
        slashedPrice: data['slashedPrice'],
        unitPerItem: data['unitPerItem'] ?? "",
        isAvailable: data['is_active'] is bool ? data['is_active'] as bool : true,
        availabilitySlots: parsedSlots);
  }
}

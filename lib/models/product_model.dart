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
  });

  // Create a factory method to map Firestore data to ProductModel
  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
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
        unitPerItem: data['unitPerItem'] ?? "");
  }
}

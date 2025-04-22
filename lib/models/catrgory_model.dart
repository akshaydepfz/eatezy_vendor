class CategoryModel {
  final String id;
  final String name;
  final String image;
  final String order;
  final String mainCategory;
  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.order,
    required this.mainCategory,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CategoryModel(
        id: data['id'] ?? "",
        name: data['name'] ?? "",
        image: data['image'] ?? "",
        order: data['order'].toString() ?? '',
        mainCategory: data['main_category'] ?? "");
  }
}

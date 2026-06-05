class ProductCategoryModel {
  final String id;
  final String name;
  final String? description;

  ProductCategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

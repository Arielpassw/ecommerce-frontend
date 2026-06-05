class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? categoryId;
  final String? categoryName;
  final String? imageUrl;
  final bool isActive;
  final bool isFeatured;
  final double? discount;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.categoryId,
    this.categoryName,
    this.imageUrl,
    required this.isActive,
    required this.isFeatured,
    this.discount,
  });

  factory ProductModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final category = json['category'];

    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      stock: json['stock'],
      categoryId: json['categoryId'],
      categoryName: category is Map<String, dynamic> ? category['name'] : null,
      imageUrl: json['imageUrl'],
      isActive: json['isActive'],
      isFeatured: json['isFeatured'],
      discount: json['discount'] != null
          ? (json['discount'] as num).toDouble()
          : null,
    );
  }
}

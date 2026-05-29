class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
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
    this.imageUrl,
    required this.isActive,
    required this.isFeatured,
    this.discount,
  });

  factory ProductModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      stock: json['stock'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'],
      isFeatured: json['isFeatured'],
      discount: json['discount'] != null
          ? (json['discount'] as num).toDouble()
          : null,
    );
  }
}
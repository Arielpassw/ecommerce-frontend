class CartItemModel {
  final String id;
  final int quantity;
  final ProductCartModel product;

  CartItemModel({
    required this.id,
    required this.quantity,
    required this.product,
  });

  factory CartItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CartItemModel(
      id: json['id'],
      quantity: json['quantity'],
      product: ProductCartModel.fromJson(
        json['product'],
      ),
    );
  }
}

class ProductCartModel {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;

  ProductCartModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  factory ProductCartModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductCartModel(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }
}
class OrderModel {
  final String id;
  final double totalAmount;
  final String status;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'],
    );
  }
}
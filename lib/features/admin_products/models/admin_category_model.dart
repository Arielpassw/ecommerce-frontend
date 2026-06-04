class AdminCategoryModel {
  final String id;
  final String name;
  final String? description;

  AdminCategoryModel({required this.id, required this.name, this.description});

  factory AdminCategoryModel.fromJson(Map<String, dynamic> json) {
    return AdminCategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class UserProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? phone;
  final String? avatar;

  UserProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.phone,
    this.avatar,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    final value = '$first$last'.trim();

    return value.isEmpty ? 'U' : value.toUpperCase();
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
    );
  }
}

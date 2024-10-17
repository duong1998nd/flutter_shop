class UserDTO {
  final int id;
  final String fullname;
  final String email;
  final String phone;

  UserDTO({required this.id, required this.fullname, required this.email, required this.phone});

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'] ?? 0,
      fullname: json['fullname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

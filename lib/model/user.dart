class User {
  int id;
  String fullname;
  String email;
  String username;
  String password;
  String phone;
  String role;

  User(this.id, this.fullname, this.email, this.username, this.password, this.phone, this.role);
  factory User.fromJson(Map<String, Object?> json) {
    return User(
      int.parse(json['id'].toString()),
      json['fullname'].toString(),
      json['email'].toString(),
      json['username'].toString(),
      json['password'].toString(),
      json['phone'].toString(),
      json['role'].toString(),
    );
  }
  Map<String, String> toMap() {
    return {
      "id": id.toString(),
      "fullname": fullname,
      "email": email,
      "username": username,
      "password": password,
      "phone": phone,
      "role": role
    };
  }
}
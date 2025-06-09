class UserModel {
  final int? id;
  final String name;
  final String email;
  final String telephone;
  final String sexe;
  final String address;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.telephone,
    required this.sexe,
    required this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      telephone: json['telephone'],
      sexe: json['sexe'],
      address: json['address'],
    );
  }
}

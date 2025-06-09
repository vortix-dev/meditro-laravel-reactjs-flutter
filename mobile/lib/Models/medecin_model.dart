// lib/Models/medecin_model.dart
class MedecinModel {
  final int id;
  final String name;
  final String email;
  final String role;

  MedecinModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory MedecinModel.fromJson(Map<String, dynamic> json) => MedecinModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
      );
}

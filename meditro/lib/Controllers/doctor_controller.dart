import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DoctorController {
  final String baseUrl;

  DoctorController({required this.baseUrl});

  /// 🔹 Connexion du médecin et stockage du token
  Future<Map<String, dynamic>> loginDoctor({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/medecin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      // 🔐 Enregistrer le token localement
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('doctor_token', token);

      return {'token': token, 'doctor': data['user']};
    } else {
      throw Exception('Échec de la connexion du médecin');
    }
  }

  /// 🔹 Déconnexion du médecin
  Future<void> logoutDoctor() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('doctor_token');
  }

  /// 🔹 Récupérer le token actuel
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('doctor_token');
  }

  /// 🔹 Récupérer tous les médecins
  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    final response = await http.get(Uri.parse('$baseUrl/medecins'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Échec du chargement des médecins');
    }
  }

  /// 🔹 Récupérer un médecin par ID
  Future<Map<String, dynamic>> getDoctorById(String doctorId) async {
    final response = await http.get(Uri.parse('$baseUrl/medecins/$doctorId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec du chargement du médecin');
    }
  }

  /// 🔹 Mettre à jour un champ d’un médecin (avec token)
  Future<bool> updateDoctorField(
    String doctorId,
    String fieldKey,
    String newValue,
  ) async {
    final token = await getSavedToken();

    if (token == null) {
      throw Exception('Médecin non authentifié');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/medecins/$doctorId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({fieldKey: newValue}),
    );

    return response.statusCode == 200;
  }
}

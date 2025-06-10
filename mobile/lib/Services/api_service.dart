import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // ⚠️ Si tu es sous Android Emulator, utilise 10.0.2.2 au lieu de 127.0.0.1
  static const String baseUrl = 'http://192.168.1.24:8000/api';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 🔐 Connexion
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      if (token != null) {
        await _storage.write(key: 'token', value: token);
      }
      return data;
    } else {
      final errorData = json.decode(response.body);
      return {
        'error': errorData['message'] ?? 'Erreur inconnue lors de la connexion',
      };
    }
  }

  /// 🧾 Inscription
  Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String sexe,
    required String address,
    required String telephone,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'sexe': sexe,
        'address': address,
        'telephone': telephone,
      },
    );

    if (response.statusCode == 200) {
      // Laravel renvoie 200 pour succès inscription
      final data = json.decode(response.body);
      final token = data['token'];
      if (token != null) {
        await _storage.write(key: 'token', value: token);
      }
      return data;
    } else {
      final errorData = json.decode(response.body);
      return {'error': errorData['message'] ?? 'Erreur lors de l’inscription'};
    }
  }

  /// ❌ Déconnexion
  Future<void> logout() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return;

    final url = Uri.parse('$baseUrl/logout');
    await http.post(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    await _storage.delete(key: 'token');
  }

  /// 📥 Récupérer le token
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  /// ❓ Mot de passe oublié
  Future<Map<String, dynamic>?> forgotPassword({required String email}) async {
    final url = Uri.parse('$baseUrl/forgot-password');

    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'email': email},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      return {
        'error': errorData['message'] ?? 'Erreur lors de l’envoi de l’email',
      };
    }
  }

  /// 🔁 Réinitialiser mot de passe
  Future<Map<String, dynamic>?> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/reset-password');

    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      return {
        'error': errorData['message'] ?? 'Erreur lors de la réinitialisation',
      };
    }
  }

  /// Optionnel : récupérer le profil de l'utilisateur connecté
  Future<Map<String, dynamic>?> getProfile() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/profile'); // à créer côté Laravel si besoin
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'error': 'Impossible de récupérer le profil'};
    }
  }
}

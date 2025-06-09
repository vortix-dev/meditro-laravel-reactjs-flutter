import 'dart:convert';
import 'package:http/http.dart' as http;

class ServiceController {
  final String baseUrl;

  ServiceController({required this.baseUrl});

  Future<List<Map<String, dynamic>>> getAllServices() async {
    final url = Uri.parse('$baseUrl/services'); // Modifie le chemin si besoin
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement des services');
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import '../Auth/auth_provider.dart';

class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  _MedicalRecordScreenState createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  List<dynamic> _medicalRecords = [];
  bool _isLoading = false;
  int _selectedIndex = 2;
<<<<<<< HEAD
  final String baseUrl = 'http://192.168.43.161:8000/api';
=======

  final String baseUrl = 'https://api-meditro.x10.mx/api';
>>>>>>> a726ac4b6ab91def70a26c661494c66f39a233b7

  @override
  void initState() {
    super.initState();
    _fetchMedicalRecords();
  }

  Future<void> _fetchMedicalRecords() async {
    setState(() => _isLoading = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    try {
      final response = await http.get(
<<<<<<< HEAD
        Uri.parse('$baseUrl/user/dossier-medical'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _medicalRecords = data['data'] ?? []; // Extract 'data' key
          _isLoading = false;
        });
      } else {
        _handleError(response);
      }
    } catch (e) {
      _showError('Erreur lors du chargement : $e');
    }
  }

  void _handleError(http.Response response) {
    String errorMessage = 'Échec du chargement des dossiers';
    try {
      final errorData = json.decode(utf8.decode(response.bodyBytes));
      errorMessage = errorData['message'] ?? errorMessage;
    } catch (_) {}
    _showError(errorMessage);
  }

  void _showError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: const Color(0xFFFF7043),
      ),
    );
  }

  Future<void> _downloadPrescription(int id) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/ordonnances/$id/pdf'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/prescription_$id.pdf');
        await file.writeAsBytes(response.bodyBytes);
        final result = await OpenFile.open(file.path);
        if (result.type != ResultType.done) {
          _showError('Erreur lors de l\'ouverture du PDF : ${result.message}');
        }
=======
        Uri.parse('$baseUrl/medical-records'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _medicalRecords = data;
          _isLoading = false;
        });
>>>>>>> a726ac4b6ab91def70a26c661494c66f39a233b7
      } else {
        _handleError(response);
      }
    } catch (e) {
<<<<<<< HEAD
=======
      _showError('Erreur lors du chargement : $e');
    }
  }

  void _handleError(http.Response response) {
    String errorMessage = 'Échec du chargement des dossiers';
    try {
      final errorData = json.decode(utf8.decode(response.bodyBytes));
      errorMessage = errorData['message'] ?? errorMessage;
    } catch (_) {}
    _showError(errorMessage);
  }

  void _showError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Color(0xFF3F51B5)),
        ),
        backgroundColor: const Color(0xFFFF7043),
      ),
    );
  }

  Future<void> _downloadPrescription(int id) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/download-prescription/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/prescription_$id.pdf');
        await file.writeAsBytes(bytes);
        OpenFile.open(file.path);
      } else {
        _handleError(response);
      }
    } catch (e) {
>>>>>>> a726ac4b6ab91def70a26c661494c66f39a233b7
      _showError('Erreur de téléchargement : $e');
    }
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/user');
    } else if (index == 1) {
      Navigator.pushNamed(
        context,
        '/book-appointment',
        arguments: {'services': []},
      );
    } else if (index == 2) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF3F51B5),
                ),
                title: Text(
                  'Mes rendez-vous',
                  style: GoogleFonts.poppins(color: Color(0xFF3F51B5)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/my-appointments');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.medical_services,
                  color: Color(0xFF3F51B5),
                ),
                title: Text(
                  'Mon dossier médical',
                  style: GoogleFonts.poppins(color: Color(0xFF3F51B5)),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF3F51B5)),
                title: Text(
                  'Déconnexion',
                  style: GoogleFonts.poppins(color: Color(0xFF3F51B5)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Mon dossier médical",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3F51B5),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF3F51B5)),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/patient-profile'),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Backgroundelapps.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4DB6AC),
                      ),
                    ),
                  )
                : _medicalRecords.isEmpty
                ? Center(
                    child: Text(
                      'Aucun dossier médical trouvé',
<<<<<<< HEAD
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 18 : 16,
                        color: Color(0xFF3F51B5),
                      ),
=======
                      style: GoogleFonts.poppins(color: Color(0xFF3F51B5)),
>>>>>>> a726ac4b6ab91def70a26c661494c66f39a233b7
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
                    itemCount: _medicalRecords.length,
                    itemBuilder: (context, index) {
                      final record = _medicalRecords[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          color: Colors.white.withOpacity(0.9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: Color(0xFF3F51B5),
                              width: 1,
                            ),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(isTablet ? 20 : 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diagnostic : ${record['diagnostic'] ?? 'N/A'}',
                                  style: GoogleFonts.poppins(
<<<<<<< HEAD
                                    fontSize: isTablet ? 18 : 16,
=======
>>>>>>> a726ac4b6ab91def70a26c661494c66f39a233b7
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF3F51B5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Groupe sanguin : ${record['groupe_sanguin'] ?? 'N/A'}',
                                  style: GoogleFonts.poppins(
<<<<<<< HEAD
                                    fontSize: isTablet ? 16 : 14,
=======
>>>>>>> a726ac4b6ab91def70a26c661494c66f39a233b7
                                    color: const Color(0xFF3F51B5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
<<<<<<< HEAD
                                  'Poids : ${record['poids']?.toString() ?? 'N/A'} kg',
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 16 : 14,
=======
                                  'Poids : ${record['poids'] ?? 'N/A'} kg',
                                  style: GoogleFonts.poppins(
>>>>>>> a726ac4b6ab91def70a26c661494c66f39a233b7
                                    color: const Color(0xFF3F51B5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
<<<<<<< HEAD
                                  'Taille : ${record['taille']?.toString() ?? 'N/A'} cm',
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 16 : 14,
=======
                                  'Taille : ${record['taille'] ?? 'N/A'} cm',
                                  style: GoogleFonts.poppins(
>>>>>>> a726ac4b6ab91def70a26c661494c66f39a233b7
                                    color: const Color(0xFF3F51B5),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (record['ordonnance'] != null &&
                                    record['ordonnance'].isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ordonnances :',
                                        style: GoogleFonts.poppins(
<<<<<<< HEAD
                                          fontSize: isTablet ? 16 : 14,
=======
>>>>>>> a726ac4b6ab91def70a26c661494c66f39a233b7
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF3F51B5),
                                        ),
                                      ),
                                      ...record['ordonnance'].map<Widget>((
                                        ord,
                                      ) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
<<<<<<< HEAD
                                                'Prescription : ${ord['date'] ?? 'N/A'}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: isTablet ? 16 : 14,
=======
                                                'Prescription : ${ord['date']}',
                                                style: GoogleFonts.poppins(
>>>>>>> a726ac4b6ab91def70a26c661494c66f39a233b7
                                                  color: const Color(
                                                    0xFF3F51B5,
                                                  ).withOpacity(0.7),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.download,
                                                  color: Color(0xFF4DB6AC),
                                                ),
                                                onPressed: () =>
                                                    _downloadPrescription(
<<<<<<< HEAD
                                                      ord['id'] ?? 0,
                                                    ),
                                                tooltip:
                                                    'Télécharger l\'ordonnance',
=======
                                                      ord['id'],
                                                    ),
>>>>>>> a726ac4b6ab91def70a26c661494c66f39a233b7
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
<<<<<<< HEAD
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF3F51B5),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24),
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_rounded),
            label: 'Réserver',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
=======
>>>>>>> a726ac4b6ab91def70a26c661494c66f39a233b7
      ),
    );
  }
}

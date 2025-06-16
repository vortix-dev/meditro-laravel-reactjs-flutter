import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../Auth/auth_provider.dart';
import '../Auth/login_screen.dart';

class DoctorPatients extends StatefulWidget {
  const DoctorPatients({super.key});

  @override
  _DoctorPatientsState createState() => _DoctorPatientsState();
}

class _DoctorPatientsState extends State<DoctorPatients> {
  List<dynamic> _patients = [];
  bool _isLoading = false;
  String? _errorMessage;
  final String baseUrl = 'https://api-meditro.x10.mx/api';

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      setState(() {
        _errorMessage = 'Veuillez vous reconnecter.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medecin/all-my-patient'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _patients = data['data'];
      } else {
        _errorMessage = 'Échec du chargement des patients.';
      }
    } catch (e) {
      _errorMessage = 'Une erreur est survenue.';
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/Backgroundelapps.jpg', fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: SizedBox(
              height: 50,
              child: Image.asset('assets/logo.png', fit: BoxFit.contain),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Mes Patients',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF565ACF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._patients.map((patient) {
                          final rdvList = patient['rdv'] as List;
                          final doneAppointments = rdvList
                              .where((rdv) => rdv['status'] == 'done')
                              .toList();

                          if (doneAppointments.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final latestRdv = doneAppointments.reduce(
                            (a, b) =>
                                DateTime.parse(
                                  b['date'],
                                ).isAfter(DateTime.parse(a['date']))
                                ? b
                                : a,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: Color(0xFF565ACF),
                                  width: 1.5,
                                ),
                              ),
                              color: Colors.white.withOpacity(0.9),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            patient['name'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: patient['sexe'] == 'Homme'
                                                ? Colors.blue.shade50
                                                : Colors.pink.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            patient['sexe'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: patient['sexe'] == 'Homme'
                                                  ? Colors.blue
                                                  : Colors.pink,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: 'Téléphone : ',
                                            style: TextStyle(
                                              color: Color(0xFFF17732),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${patient['telephone']}\n',
                                            style: const TextStyle(
                                              color: Color(0xFF565ACF),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: 'Dernier RDV : ',
                                            style: TextStyle(
                                              color: Color(0xFFF17732),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${latestRdv['date']}\n',
                                            style: const TextStyle(
                                              color: Color(0xFF565ACF),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: 'Heure : ',
                                            style: TextStyle(
                                              color: Color(0xFFF17732),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '${latestRdv['heure'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              color: Color(0xFF565ACF),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/doctor/medical-records/${patient['id']}',
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF565ACF,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Voir Dossier',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 1,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushNamed(context, '/doctor');
              } else if (index == 1) {
                // current page
              } else if (index == 2) {
                Navigator.pushNamed(context, '/doctor-appointments');
              } else if (index == 3) {
                Navigator.pushNamed(context, '/doctor-profile');
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF565ACF),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            selectedIconTheme: const IconThemeData(size: 32),
            unselectedIconTheme: const IconThemeData(size: 28),
            selectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Patients',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Rendez-vous',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

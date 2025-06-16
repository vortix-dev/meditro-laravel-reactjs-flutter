import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../Auth/auth_provider.dart';
import '../Auth/login_screen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedIndex = 0;
  int _patientCount = 0;
  int _appointmentCount = 0;
  bool _isLoading = false;
  String? _errorMessage;
  String? _doctorName;

  final String baseUrl = 'https://api-meditro.x10.mx/api';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      final profileResponse = await http.get(
        Uri.parse('$baseUrl/medecin/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final patientsResponse = await http.get(
        Uri.parse('$baseUrl/medecin/all-my-patient'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final appointmentsResponse = await http.get(
        Uri.parse('$baseUrl/medecin/all-my-rdv'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (profileResponse.statusCode == 200) {
        final profileData = json.decode(profileResponse.body);
        _doctorName = profileData['data']['nom'] ?? 'Doctor';
      }

      if (patientsResponse.statusCode == 200) {
        final patientsData = json.decode(patientsResponse.body);
        _patientCount = (patientsData['data'] as List).length;
      } else {
        _errorMessage = 'Échec du chargement des patients';
      }

      if (appointmentsResponse.statusCode == 200) {
        final appointmentsData = json.decode(appointmentsResponse.body);
        _appointmentCount = (appointmentsData['data'] as List).length;
      } else {
        _errorMessage = _errorMessage ?? 'Échec du chargement des rendez-vous';
      }
    } catch (e) {
      _errorMessage = 'Une erreur est survenue.';
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) Navigator.pushNamed(context, '/doctor');
    if (index == 1) Navigator.pushNamed(context, '/doctor-patients');
    if (index == 2) Navigator.pushNamed(context, '/doctor-appointments');
    if (index == 3) Navigator.pushNamed(context, '/doctor-profile');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Backgroundelapps.jpg',
              fit: BoxFit.cover,
            ),
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
                        children: [
                          Center(
                            child: Text(
                              'Bienvenue ${_doctorName ?? ''}',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF565ACF),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'Dashboard',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ),
                          ),
                          const SizedBox(height: 100),
                          Column(
                            children: [
                              _buildStatCard(
                                icon: Icons.people,

                                label: 'Mes Patients',
                                value: _patientCount.toString(),
                              ),
                              const SizedBox(height: 20),
                              _buildStatCard(
                                icon: Icons.calendar_month,
                                label: 'Mes Rendez-vous',
                                value: _appointmentCount.toString(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onNavItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color.fromARGB(255, 86, 90, 207),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              selectedIconTheme: const IconThemeData(size: 32),
              unselectedIconTheme: const IconThemeData(size: 28),
              selectedLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Accueil',
                ),
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
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      height: 160,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF565ACF), width: 1.5),
        ),
        color: Colors.white.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: const Color(0xFF565ACF)),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF17732),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF565ACF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

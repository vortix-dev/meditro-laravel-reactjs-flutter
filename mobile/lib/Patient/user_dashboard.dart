import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../Auth/auth_provider.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<dynamic> _services = [];
  List<dynamic> _doctors = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isBookButtonPressed = false;
  int _selectedIndex = 0;
  final String baseUrl ='http://192.168.19.123:8000/api'; // Replace with your API URL

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
      final servicesResponse = await http.get(
        Uri.parse('$baseUrl/services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final doctorsResponse = await http.get(
        Uri.parse('$baseUrl/medecins'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (servicesResponse.statusCode == 200) {
        final servicesData = json.decode(servicesResponse.body);
        _services = servicesData['data'];
      } else {
        _errorMessage = 'Failed to load services';
      }

      if (doctorsResponse.statusCode == 200) {
        final doctorsData = json.decode(doctorsResponse.body);
        _doctors = doctorsData['data'];
      } else {
        _errorMessage = 'Failed to load doctors';
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _getServiceName(dynamic serviceId) {
    final service = _services.firstWhere(
      (s) => s['id'] == serviceId, // Compare as integers
      orElse: () => {'name': 'Unknown'},
    );
    return service['name'];
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/user');
    } else if (index == 1) {
      Navigator.pushNamed(
        context,
        '/book-appointment',
        arguments: {'services': _services},
      );
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/patient-profile');
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
        automaticallyImplyLeading: false, // enlève le bouton retour
        title: Image.asset('assets/logo.png', height: 50),
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
            child: Stack(
              children: [
                // FORMES dans les 4 coins
                Positioned(
                  top: 100,
                  left: 50,
                  child: Image.asset('assets/imgForm/forme5.png', width: 80),
                ),
                Positioned(
                  top: 370,
                  right: 20,
                  child: Image.asset('assets/imgForm/forme4.png', width: 140),
                ),
                Positioned(
                  bottom: 280,
                  left: 0,
                  child: Image.asset('assets/imgForm/forme1.png', width: 80),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Image.asset('assets/imgForm/forme3.png', width: 80),
                ),
                Positioned(
                  bottom: 50,
                  left: 0,
                  child: Image.asset('assets/imgForm/forme2.png', width: 80),
                ),

                // CONTENU PRINCIPAL
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // IMAGE CENTRALE
                      Center(
                        child: Image.asset(
                          'assets/imgDoctor/DoctorHeader.png',
                          width: 300,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // TITRE
                      Text(
                        'Votre santé Mérite Tout Notre Attention',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F51B5), // Bleu
                        ),
                      ),

                      const SizedBox(height: 16),

                      // TEXTE D’ACCUEIL
                      Text(
                        'Bienvenue sur Meditro, votre application de prise de rendez-vous simple et rapide avec notre cabinet médical. En quelques clics, choisissez le créneau qui vous convient et recevez un rappel avant votre consultation. Plus besoin d’attendre au téléphone — Meditro vous simplifie la santé, avec attention et proximité.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // BOUTON RENDEZ-VOUS
                      GestureDetector(
                        onTapDown: (_) =>
                            setState(() => _isBookButtonPressed = true),
                        onTapUp: (_) =>
                            setState(() => _isBookButtonPressed = false),
                        onTapCancel: () =>
                            setState(() => _isBookButtonPressed = false),
                        child: AnimatedScale(
                          scale: _isBookButtonPressed ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          child: Container(
                            width: double.infinity,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 241, 120, 50),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/book-appointment',
                                  arguments: {'services': _services},
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                  vertical: isTablet ? 18 : 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Demander un Rendez-vous',
                                style: GoogleFonts.montserrat(
                                  fontSize: isTablet ? 23 : 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 34),

                      // SERVICES
                      Text(
                        'Services',
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 30 : 28,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 241, 120, 50),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        height: isTablet ? 200 : 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _services.length,
                          itemBuilder: (context, index) {
                            final service = _services[index];
                            return Container(
                              width: isTablet ? 240 : 200,
                              margin: const EdgeInsets.only(right: 8),
                              child: Card(
                                elevation: 2,
                                color: const Color(0xFFF5F5F5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Color(0xFF3F51B5),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: service['img'] != null
                                                ? Image.network(
                                                    service['img'],
                                                    width: isTablet ? 100 : 80,
                                                    height: isTablet ? 100 : 80,
                                                    fit: BoxFit.contain,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          _,
                                                        ) => Container(
                                                          width: isTablet
                                                              ? 100
                                                              : 80,
                                                          height: isTablet
                                                              ? 100
                                                              : 80,
                                                          color:
                                                              Colors.grey[300],
                                                          child: const Icon(
                                                            Icons.broken_image,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                  )
                                                : Container(
                                                    width: isTablet ? 100 : 80,
                                                    height: isTablet ? 100 : 80,
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.medical_services,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        service['name'],
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: isTablet ? 18 : 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF3F51B5),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // DOCTEURS
                      Text(
                        'Doctors',
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 30 : 28,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 241, 120, 50),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        height: isTablet ? 160 : 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _doctors.length,
                          itemBuilder: (context, index) {
                            final doctor = _doctors[index];
                            return Container(
                              width: isTablet ? 240 : 200,
                              margin: const EdgeInsets.only(right: 8),
                              child: Card(
                                elevation: 2,
                                color: const Color(0xFFF5F5F5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Color(0xFF3F51B5),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        doctor['name'],
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: isTablet ? 20 : 18,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF3F51B5),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Service: ${_getServiceName(doctor['service_id'])}',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: isTablet ? 16 : 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ✅ BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(
          0xFF565ACF,
        ), // même couleur que la deuxième
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: const IconThemeData(size: 32),
        unselectedIconTheme: const IconThemeData(size: 28),
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
      ),
    );
  }
}

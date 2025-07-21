import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../Auth/auth_provider.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  _MyAppointmentsScreenState createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  List<dynamic> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedIndex = 2;
  final String baseUrl ='http://192.168.19.123:8000/api'; // Replace with your API URL

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final token = Provider.of<AuthProvider>(context, listen: false).token;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/all-my-rdv'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          setState(() {
            _appointments = data['data'] ?? [];
            _isLoading = false;
          });
        } catch (e) {
          setState(() {
            _errorMessage = 'Invalid server response. Please try again.';
            _isLoading = false;
          });
          _showSnackBar(_errorMessage!);
        }
      } else {
        setState(() {
          _errorMessage = 'Erreur lors du chargement des rendez-vous';
          _isLoading = false;
        });
        _showSnackBar(_errorMessage!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue. Vérifiez votre connexion.';
        _isLoading = false;
      });
      _showSnackBar(_errorMessage!);
    }
  }

  Future<void> _cancelAppointment(int id) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/cancel-rdv/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ?? 'Annulation réussie',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF4DB6AC),
            ),
          );
          await _fetchAppointments();
        } catch (e) {
          setState(() {
            _errorMessage = 'Invalid server response. Please try again.';
            _isLoading = false;
          });
          _showSnackBar(_errorMessage!);
        }
      } else {
        try {
          final data = json.decode(response.body);
          setState(() {
            _errorMessage = data['message'] ?? 'Erreur lors de l’annulation';
            _isLoading = false;
          });
          _showSnackBar(_errorMessage!);
        } catch (e) {
          setState(() {
            _errorMessage = 'Invalid server response. Please try again.';
            _isLoading = false;
          });
          _showSnackBar(_errorMessage!);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue lors de l’annulation.';
        _isLoading = false;
      });
      _showSnackBar(_errorMessage!);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: const Color(0xFFFF7043),
      ),
    );
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return; // Prevent redundant navigation
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
      // Already on MyAppointmentsScreen, show profile menu
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _buildProfileMenu(),
      );
    }
  }

  Widget _buildProfileMenu() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItem(
            Icons.calendar_today,
            'Mes rendez-vous',
            () => Navigator.pop(
              context,
            ), // No action needed, already on this screen
          ),
          _buildMenuItem(
            Icons.medical_services,
            'Mon dossier médical',
            () => Navigator.pushNamed(context, '/medical-record'),
          ),
          _buildMenuItem(Icons.logout, 'Déconnexion', () {
            Provider.of<AuthProvider>(context, listen: false).logout();
            Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
    );
  }

  ListTile _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3F51B5)),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF3F51B5)),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/patient-profile'),
        ),
        centerTitle: true,
        title: Text(
          'Mes rendez-vous',
          style: GoogleFonts.poppins(
            fontSize: 22,
            color: const Color(0xFF3F51B5),
            fontWeight: FontWeight.bold,
          ),
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
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  )
                : _appointments.isEmpty
                ? Center(
                    child: Text(
                      'Aucun rendez-vous trouvé',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF3F51B5),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(isTablet ? 32.0 : 24.0).clamp(
                      EdgeInsets.zero,
                      EdgeInsets.all(double.infinity),
                    ), // Safe padding
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _appointments[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        color: Colors.white.withOpacity(0.95),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xFF3F51B5),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16), // Safe padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment['medecin']['name'] ??
                                    'Médecin inconnu',
                                style: GoogleFonts.poppins(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3F51B5),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Date : ${appointment['date'] ?? 'N/A'}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Heure : ${appointment['heure'] ?? 'Non spécifiée'}', // Added time display
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Status : ${appointment['status'] ?? 'N/A'}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: appointment['status'] == 'pending'
                                      ? const Color(0xFFFFA726)
                                      : Colors.green,
                                ),
                              ),
                              if (appointment['status'] == 'pending')
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: TextButton.icon(
                                    onPressed: () =>
                                        _cancelAppointment(appointment['id']),
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      'Annuler',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF565ACF),
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

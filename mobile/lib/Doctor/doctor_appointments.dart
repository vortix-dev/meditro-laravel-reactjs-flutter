import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../Auth/auth_provider.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  List<dynamic> _appointments = [];
  List<dynamic> _filteredAppointments = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'all';
  final String baseUrl = 'https://api-meditro.x10.mx/api';

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

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medecin/all-my-rdv'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _appointments = data['data'];
          _applyFilter();
          _isLoading = false;
        });
      } else {
        _handleError('Erreur lors du chargement');
      }
    } catch (e) {
      _handleError('Erreur de connexion');
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'confirmed') {
        _filteredAppointments = _appointments
            .where((appt) => appt['status'] == 'confirmed')
            .toList();
      } else if (_selectedFilter == 'done') {
        _filteredAppointments = _appointments
            .where((appt) => appt['status'] == 'done')
            .toList();
      } else {
        _filteredAppointments = List.from(_appointments);
      }
    });
  }

  void _handleError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _updateStatus(int id, String status) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/medecin/update-rdv/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _appointments = _appointments.map((appt) {
            if (appt['id'] == id) return {...appt, 'status': status};
            return appt;
          }).toList();
          _applyFilter();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _handleError('Échec de la mise à jour');
      }
    } catch (e) {
      _handleError('Erreur serveur');
    }
  }

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/doctor');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/doctor-patients');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/doctor-appointments');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/doctor-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Supprime le bouton retour
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Color.fromARGB(255, 255, 0, 0),
            ),
            onPressed: _fetchAppointments,
          ),
        ],
      ),
      body: Stack(
        children: [
          // ✅ Image de fond SANS transparence
          Positioned.fill(
            child: Image.asset(
              'assets/Backgroundelapps.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tous')),
                      DropdownMenuItem(
                        value: 'confirmed',
                        child: Text('Confirmés'),
                      ),
                      DropdownMenuItem(value: 'done', child: Text('Terminés')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedFilter = value;
                          _applyFilter();
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : _filteredAppointments.isEmpty
                      ? Center(
                          child: Text(
                            'Aucun rendez-vous.',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredAppointments.length,
                          itemBuilder: (context, index) {
                            final appt = _filteredAppointments[index];
                            return Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Colors.orange.shade200,
                                  width: 1.5,
                                ),
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'ID: ${appt['id']}',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          appt['status']
                                              .toString()
                                              .toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            color: appt['status'] == 'done'
                                                ? Colors.green
                                                : appt['status'] == 'confirmed'
                                                ? Colors.blue
                                                : Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Nom: ${appt['user']['name']}',
                                      style: GoogleFonts.poppins(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Téléphone: ${appt['user']['phone']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Date: ${appt['date']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    Text(
                                      'Heure: ${appt['heure']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButton<String>(
                                      value: appt['status'],
                                      isExpanded: true,
                                      items: [
                                        if (appt['status'] == 'confirmed')
                                          const DropdownMenuItem(
                                            value: 'confirmed',
                                            child: Text('Confirmé'),
                                          ),
                                        const DropdownMenuItem(
                                          value: 'done',
                                          child: Text('Terminé'),
                                        ),
                                        const DropdownMenuItem(
                                          value: 'cancelled',
                                          child: Text('Annulé'),
                                        ),
                                      ],
                                      onChanged:
                                          [
                                            'done',
                                            'cancelled',
                                          ].contains(appt['status'])
                                          ? null
                                          : (value) {
                                              if (value != null &&
                                                  value != appt['status']) {
                                                _updateStatus(
                                                  appt['id'],
                                                  value,
                                                );
                                              }
                                            },
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
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // "Rendez-vous" actif
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF565ACF),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: const IconThemeData(size: 32),
        unselectedIconTheme: const IconThemeData(size: 28),
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Rendez-vous',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

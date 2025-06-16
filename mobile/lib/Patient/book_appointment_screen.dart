import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../Auth/auth_provider.dart';

class BookAppointmentScreen extends StatefulWidget {
  final List<dynamic>? services;

  const BookAppointmentScreen({super.key, this.services});

  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  List<dynamic> _services = [];
  List<dynamic> _doctors = [];
  int? _selectedServiceId;
  int? _selectedDoctorId;
  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  int _selectedIndex = 1; // Book selected by default
  bool _isButtonPressed = false;
  final String baseUrl = 'https://api-meditro.x10.mx/api';
  @override
  void initState() {
    super.initState();
    if (widget.services != null) {
      _services = widget.services!;
    } else {
      _fetchServices();
    }
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _services = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load services';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _errorMessage!,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFFF7043),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _errorMessage!,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFFF7043),
        ),
      );
    }
  }

  Future<void> _fetchDoctors() async {
    if (_selectedServiceId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _doctors = [];
      _selectedDoctorId = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/medecins/$_selectedServiceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _doctors = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load doctors';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _errorMessage!,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFFF7043),
          ),
        );
      }
    } catch (e) {
      setState() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      }

      ;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _errorMessage!,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFFF7043),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4DB6AC),
              onPrimary: Colors.white,
              onSurface: Color(0xFF757575),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3F51B5),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedServiceId == null ||
        _selectedDoctorId == null ||
        _selectedDate == null) {
      setState(() {
        _errorMessage = 'Please select a service, doctor, and date';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _errorMessage!,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFFF7043),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/create-rdv'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'medecin_id': _selectedDoctorId,
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _successMessage =
              data['message'] ?? 'Appointment booked successfully';
          _isLoading = false;
          _selectedServiceId = null;
          _selectedDoctorId = null;
          _selectedDate = null;
          _doctors = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _successMessage!,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF4DB6AC),
          ),
        );
      } else {
        final data = json.decode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Failed to book appointment';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _errorMessage!,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFFF7043),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _errorMessage!,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFFF7043),
        ),
      );
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/user');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(
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
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Nouveau titre principal
                    Center(
                      child: Text(
                        'Demandez un Rendez-Vous',
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 32 : 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F51B5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 16 : 14,
                            color: const Color(0xFFFF7043),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (_successMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _successMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 16 : 14,
                            color: const Color(0xFF4DB6AC),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    // Titre français orange
                    Text(
                      'Sélectionner un service',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 241, 120, 50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFF3F51B5), width: 1),
                      ),
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedServiceId,
                        onChanged: (value) {
                          setState(() {
                            _selectedServiceId = value;
                            _fetchDoctors();
                          });
                        },
                        items: _services.map((service) {
                          return DropdownMenuItem<int>(
                            value: service['id'],
                            child: Semantics(
                              label: 'Service: ${service['name']}',
                              child: Text(
                                service['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: isTablet ? 16 : 14,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        hint: Semantics(
                          label: 'Select service',
                          child: Text(
                            'Select Service',
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 14 : 12,
                              color: const Color.fromARGB(
                                255,
                                0,
                                0,
                                0,
                              ).withOpacity(0.7),
                            ),
                          ),
                        ),
                        underline: const SizedBox(),
                        dropdownColor: const Color(0xFFF5F5F5),
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 16 : 14,
                          color: Colors.black54,
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF3F51B5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Sélectionner un médecin',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 241, 120, 50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFF3F51B5), width: 1),
                      ),
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedDoctorId,
                        onChanged: (value) {
                          setState(() {
                            _selectedDoctorId = value;
                          });
                        },
                        items: _doctors.map((doctor) {
                          return DropdownMenuItem<int>(
                            value: doctor['id'],
                            child: Semantics(
                              label: 'Doctor: ${doctor['name']}',
                              child: Text(
                                doctor['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: isTablet ? 16 : 14,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        hint: Semantics(
                          label: 'Select doctor',
                          child: Text(
                            'Select Doctor',
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 14 : 12,
                              color: const Color.fromARGB(
                                255,
                                0,
                                0,
                                0,
                              ).withOpacity(0.7),
                            ),
                          ),
                        ),
                        underline: const SizedBox(),
                        dropdownColor: const Color(0xFFF5F5F5),
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 16 : 14,
                          color: Colors.black54,
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF3F51B5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Select Date',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 241, 120, 50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isButtonPressed = true),
                      onTapUp: (_) => setState(() => _isButtonPressed = false),
                      onTapCancel: () =>
                          setState(() => _isButtonPressed = false),
                      onTap: () => _selectDate(context),
                      child: AnimatedScale(
                        scale: _isButtonPressed ? 0.95 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFF3F51B5),
                              width: 1,
                            ),
                          ),
                          child: Semantics(
                            label: _selectedDate == null
                                ? 'Select appointment date'
                                : 'Selected date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                            child: Text(
                              _selectedDate == null
                                  ? 'Choose Date'
                                  : DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(_selectedDate!),
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 16 : 14,
                                color: _selectedDate == null
                                    ? const Color.fromARGB(
                                        255,
                                        0,
                                        0,
                                        0,
                                      ).withOpacity(0.7)
                                    : const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isButtonPressed = true),
                      onTapUp: (_) => setState(() => _isButtonPressed = false),
                      onTapCancel: () =>
                          setState(() => _isButtonPressed = false),
                      onTap: _bookAppointment,
                      child: AnimatedScale(
                        scale: _isButtonPressed ? 0.95 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                          width: double.infinity,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 241, 120, 50),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _bookAppointment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Semantics(
                              label: 'Confirmer le rendez-vous',
                              child: Text(
                                'Confirmer le rendez-vous',
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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

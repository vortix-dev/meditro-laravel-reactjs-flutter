import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../Auth/auth_provider.dart';
import 'doctor_dashboard.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  Map<String, String> _profile = {'name': '', 'email': ''};
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _isLoading = false;
  int _selectedIndex = 2; // Set to 2 since this is the Profile screen
   final String baseUrl =
      'https://api-meditro.x10.mx/api';
  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in again'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medecin/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          _profile = {'name': data['name'], 'email': data['email']};
          _nameController.text = data['name'];
          _emailController.text = data['email'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              json.decode(response.body)['message'] ?? 'Failed to load profile',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    final userId = authProvider.userId;

    final payload = {};
    if (_nameController.text != _profile['name'])
      payload['name'] = _nameController.text;
    if (_emailController.text != _profile['email'])
      payload['email'] = _emailController.text;
    if (_passwordController.text.isNotEmpty) {
      payload['password'] = _passwordController.text;
      payload['password_confirmation'] = _passwordConfirmController.text;
    }

    if (payload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to save'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/medecin/profile-update/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          _profile = {'name': data['name'], 'email': data['email']};
          _passwordController.clear();
          _passwordConfirmController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              json.decode(response.body)['message'] ??
                  'Profile updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              json.decode(response.body)['message'] ??
                  'Failed to update profile',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushNamed(context, '/doctor-patients');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/doctor-appointments');
    } else if (index == 2) {
      // Already on profile screen, no action needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        title: Text(
          'Doctor Profile',
          style: GoogleFonts.poppins(
            fontSize: isTablet ? 22 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DoctorDashboard()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DB6AC)),
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Profile Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFF3F51B5),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Profile',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3F51B5),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Color(0xFF4DB6AC),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Name: ${_profile['name']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 16 : 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.email,
                                  color: Color(0xFF4DB6AC),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Username: ${_profile['email']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 16 : 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Update Profile Form
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFF3F51B5),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Update Profile',
                                style: GoogleFonts.poppins(
                                  fontSize: isTablet ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF3F51B5),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  labelStyle: GoogleFonts.poppins(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: Color(0xFF4DB6AC),
                                  ),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter your name'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  labelStyle: GoogleFonts.poppins(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Color(0xFF4DB6AC),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password (optional)',
                                  labelStyle: GoogleFonts.poppins(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Color(0xFF4DB6AC),
                                  ),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordConfirmController,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  labelStyle: GoogleFonts.poppins(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Color(0xFF4DB6AC),
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (_passwordController.text.isNotEmpty &&
                                      value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3F51B5),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Update Profile',
                                    style: GoogleFonts.poppins(
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
              ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF3F51B5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavItemTapped,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Patients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

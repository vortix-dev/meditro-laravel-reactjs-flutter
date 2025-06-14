import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../Auth/auth_provider.dart';
import 'doctor_dashboard.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  _DoctorAppointmentsScreenState createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  List<dynamic> _appointments = [];
  List<dynamic> _filteredAppointments = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedIndex = 1;
  String _selectedFilter = 'all'; // Filter for appointments
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
    final userId = authProvider.userId;

    if (token == null || userId == null) {
      _handleError('Please log in again');
      return;
    }

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
        _handleError(
          json.decode(response.body)['message'] ??
              'Failed to fetch appointments',
        );
      }
    } catch (e) {
      _handleError('An error occurred. Please try again.');
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
            if (appt['id'] == id) {
              return {...appt, 'status': status};
            }
            return appt;
          }).toList();
          _applyFilter();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Status updated'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _handleError(
          json.decode(response.body)['message'] ?? 'Failed to update status',
        );
      }
    } catch (e) {
      _handleError('Failed to update status');
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushNamed(context, '/doctor-patients');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/doctor-profile');
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
          'Manage Appointments',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchAppointments,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
              child: DropdownButton<String>(
                value: _selectedFilter,
                isExpanded: true,
                hint: Text('Filter Appointments', style: GoogleFonts.poppins()),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(
                    value: 'confirmed',
                    child: Text('Confirmed'),
                  ),
                  DropdownMenuItem(value: 'done', child: Text('Done')),
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
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4DB6AC),
                        ),
                      ),
                    )
                  : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFF7043),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : _filteredAppointments.isEmpty
                  ? Center(
                      child: Text(
                        'No appointments found.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                      itemCount: _filteredAppointments.length,
                      itemBuilder: (context, index) {
                        final appt = _filteredAppointments[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: appt['status'] == 'confirmed'
                                  ? Colors.blueAccent
                                  : const Color(0xFF3F51B5),
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
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
                                        fontSize: isTablet ? 16 : 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      appt['status'].toString().toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: isTablet ? 14 : 12,
                                        color: appt['status'] == 'done'
                                            ? Colors.green
                                            : appt['status'] == 'cancelled'
                                            ? Colors.red
                                            : appt['status'] == 'confirmed'
                                            ? Colors.blueAccent
                                            : Colors.orange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Patient: ${appt['user']?['name'] ?? 'N/A'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 16 : 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Date: ${DateTime.parse(appt['date']).toLocal().toString().split(' ')[0]}',
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 14 : 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Time: ${appt['heure'] ?? 'N/A'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 14 : 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButton<String>(
                                  value: appt['status'],
                                  isExpanded: true,
                                  hint: Text(
                                    'Select Status',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  items: [
                                    if (appt['status'] == 'confirmed')
                                      const DropdownMenuItem(
                                        value: 'confirmed',
                                        child: Text('Confirmed'),
                                      ),
                                    const DropdownMenuItem(
                                      value: 'done',
                                      child: Text('Done'),
                                    ),
                                    const DropdownMenuItem(
                                      value: 'cancelled',
                                      child: Text('Cancelled'),
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
                                              value.isNotEmpty &&
                                              value != 'confirmed') {
                                            _updateStatus(appt['id'], value);
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

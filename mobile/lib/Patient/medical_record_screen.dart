import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
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
  int _selectedIndex = 2; // Profile selected by default

  @override
  void initState() {
    super.initState();
    _fetchMedicalRecords();
  }

  Future<void> _fetchMedicalRecords() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.4:8000/api/user/dossier-medical'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _medicalRecords = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              json.decode(response.body)['message'] ??
                  'Failed to fetch medical records',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Color(0xFFFF7043),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to fetch medical records',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Color(0xFFFF7043),
        ),
      );
    }
  }

  Future<void> _downloadPrescription(int ordonnanceId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.1.4:8000/api/user/ordonnances/$ordonnanceId/pdf',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/ordonnance-$ordonnanceId.pdf');
        await file.writeAsBytes(response.bodyBytes);
        final result = await OpenFile.open(file.path);
        if (result.type == ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Prescription downloaded successfully!',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: Color(0xFF4DB6AC),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to open PDF: ${result.message}',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: Color(0xFFFF7043),
            ),
          );
        }
      } else {
        String errorMessage = 'Failed to download prescription';
        try {
          final errorData = json.decode(utf8.decode(response.bodyBytes));
          errorMessage =
              errorData['message'] ?? 'Failed to download prescription';
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Color(0xFFFF7043),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error downloading prescription: $e',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Color(0xFFFF7043),
        ),
      );
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 2) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
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
                  'My Appointments',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF757575),
                  ),
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
                  'My Medical Record',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF757575),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF3F51B5)),
                title: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF757575),
                  ),
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
    } else if (index == 1) {
      Navigator.pushNamed(
        context,
        '/book-appointment',
        arguments: {'services': []},
      );
    } else if (index == 0) {
      Navigator.pushReplacementNamed(context, '/user');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF3F51B5),
        title: Text(
          'My Medical Record',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/user'),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DB6AC)),
                ),
              )
            : _medicalRecords.isEmpty
            ? Center(
                child: Text(
                  'No medical records found',
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 18 : 16,
                    color: Color(0xFF757575),
                  ),
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
                      elevation: 2,
                      color: Color(0xFFF5F5F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Color(0xFF3F51B5), width: 1),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Diagnostic: ${record['diagnostic'] ?? 'N/A'}',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Blood Group: ${record['groupe_sanguin'] ?? 'N/A'}',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 16 : 14,
                                color: Color.fromARGB(
                                  255,
                                  0,
                                  0,
                                  0,
                                ).withOpacity(0.7),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Weight: ${record['poids'] ?? 'N/A'} kg',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 16 : 14,
                                color: Color.fromARGB(
                                  255,
                                  0,
                                  0,
                                  0,
                                ).withOpacity(0.7),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Height: ${record['taille'] ?? 'N/A'} cm',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 16 : 14,
                                color: Color.fromARGB(
                                  255,
                                  0,
                                  0,
                                  0,
                                ).withOpacity(0.7),
                              ),
                            ),
                            SizedBox(height: 16),
                            if (record['ordonnance'] != null &&
                                record['ordonnance'].isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Prescriptions:',
                                    style: GoogleFonts.poppins(
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                  ...record['ordonnance'].map<Widget>((ord) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Prescription : ${ord['date']}',
                                            style: GoogleFonts.poppins(
                                              fontSize: isTablet ? 16 : 14,
                                              color: Color(
                                                0xFF757575,
                                              ).withOpacity(0.7),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.download,
                                              color: Color(0xFF4DB6AC),
                                              size: isTablet ? 28 : 24,
                                            ),
                                            onPressed: () =>
                                                _downloadPrescription(
                                                  ord['id'],
                                                ),
                                            tooltip: 'Download Prescription',
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
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_rounded),
              label: 'Book',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

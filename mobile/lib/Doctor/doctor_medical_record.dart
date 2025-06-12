import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../Auth/auth_provider.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class DoctorMedicalRecordScreen extends StatefulWidget {
  final String userId;

  const DoctorMedicalRecordScreen({super.key, required this.userId});

  @override
  _DoctorMedicalRecordScreenState createState() =>
      _DoctorMedicalRecordScreenState();
}

class _DoctorMedicalRecordScreenState extends State<DoctorMedicalRecordScreen> {
  Map<String, dynamic>? _dossier;
  List<dynamic> _prescriptions = [];
  bool _isLoading = false;
  bool _isCreateModalOpen = false;
  bool _isEditModalOpen = false;
  bool _isPrescriptionModalOpen = false;
  final _formKey = GlobalKey<FormState>();
  final _diagnosticController = TextEditingController();
  final _groupeSanguinController = TextEditingController();
  final _poidsController = TextEditingController();
  final _tailleController = TextEditingController();
  final _prescriptionDateController = TextEditingController();
  List<Map<String, TextEditingController>> _medicamentControllers = [
    {
      'medicament': TextEditingController(),
      'dosage': TextEditingController(),
      'frequence': TextEditingController(),
      'duree': TextEditingController(),
    },
  ];
  int _selectedIndex = 0; // Patients tab active
  final Map<int, bool> _expandedPrescriptions = {};

  @override
  void initState() {
    super.initState();
    _fetchDossier();
  }

  @override
  void dispose() {
    _diagnosticController.dispose();
    _groupeSanguinController.dispose();
    _poidsController.dispose();
    _tailleController.dispose();
    _prescriptionDateController.dispose();
    for (var controllers in _medicamentControllers) {
      controllers.forEach((_, controller) => controller.dispose());
    }
    super.dispose();
  }

  Future<void> _fetchDossier() async {
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
        Uri.parse(
          'http://192.168.1.4:8000/api/medecin/get-dossier/${widget.userId}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          if (data.isNotEmpty) {
            _dossier = data[0];
            _prescriptions = _dossier!['ordonnance'] ?? [];
            _diagnosticController.text = _dossier!['diagnostic'] ?? '';
            _groupeSanguinController.text = _dossier!['groupe_sanguin'] ?? '';
            _poidsController.text = _dossier!['poids']?.toString() ?? '';
            _tailleController.text = _dossier!['taille']?.toString() ?? '';
          }
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
                  'Failed to fetch dossier',
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
          content: Text('Failed to fetch dossier'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createDossier() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    final medecinId = authProvider.userId;

    final payload = {
      'diagnostic': _diagnosticController.text,
      'groupe_sanguin': _groupeSanguinController.text,
      'poids': _poidsController.text,
      'taille': _tailleController.text,
      'medecin_id': medecinId,
      'user_id': widget.userId,
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4:8000/api/medecin/dossier-medicale'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          _dossier = data;
          _prescriptions = data['ordonnance'] ?? [];
          _isCreateModalOpen = false;
          _diagnosticController.clear();
          _groupeSanguinController.clear();
          _poidsController.clear();
          _tailleController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              json.decode(response.body)['message'] ??
                  'Dossier created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.statusCode == 422) {
        final errors = json.decode(response.body)['errors'];
        for (var error in errors.values) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error[0]), backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              json.decode(response.body)['message'] ??
                  'Failed to create dossier',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create dossier'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateDossier() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    final payload = {
      'diagnostic': _diagnosticController.text,
      'groupe_sanguin': _groupeSanguinController.text,
      'poids': _poidsController.text,
      'taille': _tailleController.text,
    };

    try {
      final response = await http.put(
        Uri.parse(
          'http://192.168.1.4:8000/api/medecin/dossier-medicale/${widget.userId}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          _dossier = data;
          _isEditModalOpen = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              json.decode(response.body)['message'] ??
                  'Dossier updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.statusCode == 422) {
        final errors = json.decode(response.body)['errors'];
        for (var error in errors.values) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error[0]), backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              json.decode(response.body)['message'] ??
                  'Failed to update dossier',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update dossier'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createPrescription() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    final medecinId = authProvider.userId;

    final medicaments = _medicamentControllers.map((controllers) {
      return {
        'medicament': controllers['medicament']!.text,
        'dosage': controllers['dosage']!.text,
        'frequence': controllers['frequence']!.text,
        'duree': controllers['duree']!.text,
      };
    }).toList();

    final payload = {
      'date': _prescriptionDateController.text,
      'medicaments': medicaments,
      'dossier_medicale_id': _dossier!['id'],
      'medecin_id': medecinId,
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4:8000/api/medecin/ordonnances'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(
          response.body,
        )['data']; // Fixed: Access 'data' field
        setState(() {
          _prescriptions = [..._prescriptions, data];
          _isPrescriptionModalOpen = false;
          _prescriptionDateController.clear();
          _medicamentControllers = [
            {
              'medicament': TextEditingController(),
              'dosage': TextEditingController(),
              'frequence': TextEditingController(),
              'duree': TextEditingController(),
            },
          ];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              json.decode(response.body)['message'] ??
                  'Prescription created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.statusCode == 422) {
        final errors = json.decode(response.body)['errors'];
        for (var error in errors.values) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error[0]), backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              json.decode(response.body)['message'] ??
                  'Failed to create prescription',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create prescription'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePrescription(int id) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      final response = await http.delete(
        Uri.parse('http://192.168.1.4:8000/api/medecin/ordonnances/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _prescriptions = _prescriptions.where((p) => p['id'] != id).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prescription deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              json.decode(response.body)['message'] ??
                  'Failed to delete prescription',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete prescription'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadPdf(int id) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/ordonnance-$id.pdf';

      await FileDownloader.downloadFile(
        url: 'http://192.168.1.4:8000/api/medecin/ordonnances/$id/pdf',
        name: 'ordonnance-$id.pdf',
        headers: {'Authorization': 'Bearer $token'},
        onDownloadCompleted: (path) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF downloaded to $path'),
              backgroundColor: Colors.green,
            ),
          );
          await OpenFile.open(path);
        },
        onDownloadError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to download PDF: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to download PDF'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addMedicament() {
    setState(() {
      _medicamentControllers.add({
        'medicament': TextEditingController(),
        'dosage': TextEditingController(),
        'frequence': TextEditingController(),
        'duree': TextEditingController(),
      });
    });
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
      Navigator.pushNamed(context, '/doctor-profile');
    }
  }

  Widget _buildModal({
    required String title,
    required Widget content,
    required VoidCallback onSubmit,
    required VoidCallback onCancel,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return AnimatedScale(
      scale: _isCreateModalOpen || _isEditModalOpen || _isPrescriptionModalOpen
          ? 1.0
          : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: isTablet ? 400 : screenWidth * 0.9,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3F51B5),
                  ),
                ),
                const SizedBox(height: 16),
                Form(key: _formKey, child: content),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onCancel,
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F51B5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        title.contains('Create') ? 'Create' : 'Update',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 1200;

    // Dynamic font size scaling
    final baseFontSize = isTablet ? 16.0 : 14.0;
    final titleFontSize = isTablet ? 20.0 : 18.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        title: Text(
          'Medical Record',
          style: GoogleFonts.poppins(
            fontSize: titleFontSize + (isLargeScreen ? 2 : 0),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/doctor-patients'),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DB6AC)),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(
                      isTablet ? 32.0 : constraints.maxWidth * 0.05,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_dossier == null) ...[
                          Center(
                            child: Text(
                              'No medical record found for this patient.',
                              style: GoogleFonts.poppins(
                                fontSize: baseFontSize,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          Center(
                            child: ElevatedButton(
                              onPressed: () =>
                                  setState(() => _isCreateModalOpen = true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3F51B5),
                                padding: EdgeInsets.symmetric(
                                  horizontal: constraints.maxWidth * 0.06,
                                  vertical: constraints.maxHeight * 0.015,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Create Dossier',
                                style: GoogleFonts.poppins(
                                  fontSize: baseFontSize - 2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
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
                              padding: EdgeInsets.all(
                                constraints.maxWidth * 0.04,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Medical Record Details',
                                    style: GoogleFonts.poppins(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF3F51B5),
                                    ),
                                  ),
                                  SizedBox(
                                    height: constraints.maxHeight * 0.015,
                                  ),
                                  Text(
                                    'Diagnostic: ${_dossier!['diagnostic'] ?? 'N/A'}',
                                    style: GoogleFonts.poppins(
                                      fontSize: baseFontSize,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Blood Group: ${_dossier!['groupe_sanguin'] ?? 'N/A'}',
                                    style: GoogleFonts.poppins(
                                      fontSize: baseFontSize,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Weight: ${_dossier!['poids'] != null ? '${_dossier!['poids']} kg' : 'N/A'}',
                                    style: GoogleFonts.poppins(
                                      fontSize: baseFontSize,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Height: ${_dossier!['taille'] != null ? '${_dossier!['taille']} cm' : 'N/A'}',
                                    style: GoogleFonts.poppins(
                                      fontSize: baseFontSize,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Patient: ${_dossier!['user']?['name'] ?? 'N/A'}',
                                    style: GoogleFonts.poppins(
                                      fontSize: baseFontSize,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(
                                    height: constraints.maxHeight * 0.02,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () => setState(
                                        () => _isEditModalOpen = true,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF3F51B5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Edit Dossier',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: baseFontSize - 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.03),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFF3F51B5),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(
                                    constraints.maxWidth * 0.04,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Prescriptions',
                                        style: GoogleFonts.poppins(
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF3F51B5),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => setState(
                                          () => _isPrescriptionModalOpen = true,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF3F51B5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Add Prescription',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: baseFontSize - 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_prescriptions.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.all(
                                      constraints.maxWidth * 0.04,
                                    ),
                                    child: Text(
                                      'No prescriptions found.',
                                      style: GoogleFonts.poppins(
                                        fontSize: baseFontSize,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _prescriptions.length,
                                    itemBuilder: (context, index) {
                                      final prescription =
                                          _prescriptions[index];
                                      final bool isExpanded =
                                          _expandedPrescriptions[prescription['id']] ??
                                          false;
                                      return ExpansionTile(
                                        title: Text(
                                          'Prescription ID: ${prescription['id']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: baseFontSize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Date: ${DateTime.parse(prescription['date']).toLocal().toString().split(' ')[0]}',
                                          style: GoogleFonts.poppins(
                                            fontSize: baseFontSize - 2,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.download,
                                                color: Color(0xFF4DB6AC),
                                              ),
                                              onPressed: () => _downloadPdf(
                                                prescription['id'],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  _deletePrescription(
                                                    prescription['id'],
                                                  ),
                                            ),
                                          ],
                                        ),
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(
                                              constraints.maxWidth * 0.04,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children:
                                                  (prescription['medicaments']
                                                              as List<
                                                                dynamic
                                                              >? ??
                                                          [])
                                                      .map(
                                                        (med) => Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Medicament: ${med['medicament'] ?? 'N/A'}',
                                                              style: GoogleFonts.poppins(
                                                                fontSize:
                                                                    baseFontSize -
                                                                    2,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                            Text(
                                                              'Dosage: ${med['dosage'] ?? 'N/A'}',
                                                              style: GoogleFonts.poppins(
                                                                fontSize:
                                                                    baseFontSize -
                                                                    2,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                            Text(
                                                              'Frequency: ${med['frequence'] ?? 'N/A'}',
                                                              style: GoogleFonts.poppins(
                                                                fontSize:
                                                                    baseFontSize -
                                                                    2,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                            Text(
                                                              'Duration: ${med['duree'] ?? 'N/A'}',
                                                              style: GoogleFonts.poppins(
                                                                fontSize:
                                                                    baseFontSize -
                                                                    2,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  constraints
                                                                      .maxHeight *
                                                                  0.01,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                      .toList(),
                                            ),
                                          ),
                                        ],
                                        onExpansionChanged: (expanded) {
                                          setState(() {
                                            _expandedPrescriptions[prescription['id']] =
                                                expanded;
                                          });
                                        },
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
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
          selectedLabelStyle: GoogleFonts.poppins(fontSize: isTablet ? 14 : 12),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: isTablet ? 14 : 12,
          ),
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
      floatingActionButton: _isCreateModalOpen
          ? _buildModal(
              title: 'Create Medical Record',
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _diagnosticController,
                      decoration: InputDecoration(
                        labelText: 'Diagnostic',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: baseFontSize - 2,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(
                          Icons.description,
                          color: Color(0xFF4DB6AC),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter diagnostic' : null,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    DropdownButtonFormField<String>(
                      value: _groupeSanguinController.text.isEmpty
                          ? null
                          : _groupeSanguinController.text,
                      decoration: InputDecoration(
                        labelText: 'Blood Group',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: baseFontSize - 2,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(
                          Icons.bloodtype,
                          color: Color(0xFF4DB6AC),
                        ),
                      ),
                      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                          .map(
                            (group) => DropdownMenuItem(
                              value: group,
                              child: Text(group),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          _groupeSanguinController.text = value!,
                      validator: (value) =>
                          value == null ? 'Please select blood group' : null,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextFormField(
                      controller: _poidsController,
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: baseFontSize - 2,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(
                          Icons.fitness_center,
                          color: Color(0xFF4DB6AC),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter weight';
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Please enter a valid weight';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextFormField(
                      controller: _tailleController,
                      decoration: InputDecoration(
                        labelText: 'Height (cm)',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: baseFontSize - 2,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(
                          Icons.height,
                          color: Color(0xFF4DB6AC),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter height';
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Please enter a valid height';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              onSubmit: _createDossier,
              onCancel: () => setState(() => _isCreateModalOpen = false),
            )
          : _isEditModalOpen
          ? _buildModal(
              title: 'Edit Medical Record',
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _diagnosticController,
                      decoration: InputDecoration(
                        labelText: 'Diagnostic',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: baseFontSize - 2,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(
                          Icons.description,
                          color: Color(0xFF4DB6AC),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter diagnostic' : null,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    DropdownButtonFormField<String>(
                      value: _groupeSanguinController.text.isEmpty
                          ? null
                          : _groupeSanguinController.text,
                      decoration: InputDecoration(
                        labelText: 'Blood Group',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: baseFontSize - 2,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(
                          Icons.bloodtype,
                          color: Color(0xFF4DB6AC),
                        ),
                      ),
                      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                          .map(
                            (group) => DropdownMenuItem(
                              value: group,
                              child: Text(group),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          _groupeSanguinController.text = value!,
                      validator: (value) =>
                          value == null ? 'Please select blood group' : null,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextFormField(
                      controller: _poidsController,
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: baseFontSize - 2,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(
                          Icons.fitness_center,
                          color: Color(0xFF4DB6AC),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter weight';
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Please enter a valid weight';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextFormField(
                      controller: _tailleController,
                      decoration: InputDecoration(
                        labelText: 'Height (cm)',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: baseFontSize - 2,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(
                          Icons.height,
                          color: Color(0xFF4DB6AC),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter height';
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Please enter a valid height';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              onSubmit: _updateDossier,
              onCancel: () => setState(() => _isEditModalOpen = false),
            )
          : _isPrescriptionModalOpen
          ? _buildModal(
              title: 'Add Prescription',
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _prescriptionDateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: baseFontSize - 2,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF4DB6AC),
                        ),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          _prescriptionDateController.text = date
                              .toIso8601String()
                              .split('T')[0];
                        }
                      },
                      readOnly: true,
                      validator: (value) =>
                          value!.isEmpty ? 'Please select a date' : null,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Medicaments',
                      style: GoogleFonts.poppins(
                        fontSize: baseFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    ..._medicamentControllers.asMap().entries.map((entry) {
                      final controllers = entry.value;
                      return Column(
                        children: [
                          TextFormField(
                            controller: controllers['medicament'],
                            decoration: InputDecoration(
                              labelText: 'Medicament',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: baseFontSize - 2,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(
                                Icons.medical_services,
                                color: Color(0xFF4DB6AC),
                              ),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter medicament'
                                : null,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          TextFormField(
                            controller: controllers['dosage'],
                            decoration: InputDecoration(
                              labelText: 'Dosage',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: baseFontSize - 2,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(
                                Icons.medication,
                                color: Color(0xFF4DB6AC),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter dosage' : null,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          TextFormField(
                            controller: controllers['frequence'],
                            decoration: InputDecoration(
                              labelText: 'Frequency',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: baseFontSize - 2,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(
                                Icons.schedule,
                                color: Color(0xFF4DB6AC),
                              ),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter frequency'
                                : null,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          TextFormField(
                            controller: controllers['duree'],
                            decoration: InputDecoration(
                              labelText: 'Duration',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: baseFontSize - 2,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(
                                Icons.timer,
                                color: Color(0xFF4DB6AC),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter duration' : null,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                        ],
                      );
                    }),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _addMedicament,
                        icon: const Icon(Icons.add, color: Color(0xFF4DB6AC)),
                        label: Text(
                          'Add Medicament',
                          style: GoogleFonts.poppins(
                            color: Color(0xFF4DB6AC),
                            fontSize: baseFontSize - 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onSubmit: _createPrescription,
              onCancel: () => setState(() => _isPrescriptionModalOpen = false),
            )
          : null,
    );
  }
}

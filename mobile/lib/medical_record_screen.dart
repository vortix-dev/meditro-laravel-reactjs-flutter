import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  _MedicalRecordScreenState createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  List<dynamic> _medicalRecords = [];
  bool _isLoading = false;

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
        Uri.parse('http://192.168.1.24:8000/api/user/dossier-medical'),
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
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch medical records')),
      );
    }
  }

  Future<void> _downloadPrescription(int ordonnanceId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.1.24:8000/api/user/ordonnances/$ordonnanceId/pdf',
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
            const SnackBar(
              content: Text('Prescription downloaded successfully!'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to open PDF: ${result.message}')),
          );
        }
      } else {
        String errorMessage = 'Failed to download prescription';
        try {
          final errorData = json.decode(utf8.decode(response.bodyBytes));
          errorMessage =
              errorData['message'] ??
              'Failed to download prescription (Status: ${response.statusCode})';
        } catch (_) {
          errorMessage =
              'Failed to download prescription (Status: ${response.statusCode})';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading prescription: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Medical Record')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medicalRecords.isEmpty
          ? const Center(child: Text('No medical records found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _medicalRecords.length,
              itemBuilder: (context, index) {
                final record = _medicalRecords[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Diagnostic: ${record['diagnostic'] ?? 'N/A'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Blood Group: ${record['groupe_sanguin'] ?? 'N/A'}',
                        ),
                        const SizedBox(height: 8),
                        Text('Weight: ${record['poids'] ?? 'N/A'} kg'),
                        const SizedBox(height: 8),
                        Text('Height: ${record['taille'] ?? 'N/A'} cm'),
                        const SizedBox(height: 16),
                        if (record['ordonnance'] != null &&
                            record['ordonnance'].isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Prescriptions:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ...record['ordonnance'].map<Widget>((ord) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Prescription ID: ${ord['id']}'),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.download),
                                          onPressed: () =>
                                              _downloadPrescription(ord['id']),
                                          tooltip: 'Download Prescription',
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

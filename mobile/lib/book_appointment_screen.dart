import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'auth_provider.dart';

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
        Uri.parse('http://192.168.1.24:8000/api/services'),
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
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
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
        Uri.parse(
          'http://192.168.1.24:8000/api/user/medecins/$_selectedServiceId',
        ),
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
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
        Uri.parse('http://192.168.1.24:8000/api/user/create-rdv'),
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
        });
      } else {
        final data = json.decode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Failed to book appointment';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  if (_successMessage != null)
                    Text(
                      _successMessage!,
                      style: const TextStyle(color: Colors.green),
                    ),
                  const SizedBox(height: 10),
                  const Text(
                    'Select Service',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<int>(
                    isExpanded: true,
                    value: _selectedServiceId,
                    items: _services.map((service) {
                      return DropdownMenuItem<int>(
                        value: service['id'],
                        child: Text(service['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedServiceId = value;
                        _fetchDoctors();
                      });
                    },
                    hint: const Text('Select Service'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Doctor',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<int>(
                    isExpanded: true,
                    value: _selectedDoctorId,
                    items: _doctors.map((doctor) {
                      return DropdownMenuItem<int>(
                        value: doctor['id'],
                        child: Text(doctor['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDoctorId = value;
                      });
                    },
                    hint: const Text('Select Doctor'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      _selectedDate == null
                          ? 'Choose Date'
                          : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _bookAppointment,
                    child: const Text('Confirm Appointment'),
                  ),
                ],
              ),
            ),
    );
  }
}

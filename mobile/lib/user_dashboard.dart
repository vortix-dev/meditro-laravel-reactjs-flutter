import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

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
      // Fetch services
      final servicesResponse = await http.get(
        Uri.parse('http://192.168.1.24:8000/api/services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Fetch doctors
      final doctorsResponse = await http.get(
        Uri.parse('http://192.168.1.24:8000/api/medecins'),
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

  String _getServiceName(int serviceId) {
    final service = _services.firstWhere(
      (s) => s['id'] == serviceId,
      orElse: () => {'name': 'Unknown'},
    );
    return service['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/book-appointment',
                        arguments: {'services': _services},
                      );
                    },
                    child: const Text('Book Appointment'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/my-appointments');
                    },
                    child: const Text('My Appointments'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/medical-record');
                    },
                    child: const Text('My Medical Record'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Services',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        return Card(
                          child: ListTile(
                            leading: service['img'] != null
                                ? Image.network(
                                    service['img'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image),
                                  )
                                : const Icon(Icons.medical_services),
                            title: Text(service['name']),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Doctors',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = _doctors[index];
                        return Card(
                          child: ListTile(
                            title: Text(doctor['name']),
                            subtitle: Text(
                              'Service: ${_getServiceName(doctor['service_id'])}',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

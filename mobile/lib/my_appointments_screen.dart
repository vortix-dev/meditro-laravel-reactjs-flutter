import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  _MyAppointmentsScreenState createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  List<dynamic> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

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
        Uri.parse('http://192.168.1.24:8000/api/user/all-my-rdv'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _appointments = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load appointments';
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

  Future<void> _cancelAppointment(int id) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.24:8000/api/user/cancel-rdv/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Appointment cancelled')),
        );
        _fetchAppointments(); // Refresh the list
      } else {
        final data = json.decode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Failed to cancel appointment';
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
      appBar: AppBar(
        title: const Text('My Appointments'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _appointments.isEmpty
                  ? const Center(child: Text('No appointments found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _appointments[index];
                        return Card(
                          child: ListTile(
                            title: Text(appointment['medecin']['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: ${appointment['date']}'),
                                Text('Status: ${appointment['status']}'),
                              ],
                            ),
                            trailing: appointment['status'] == 'pending'
                                ? IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.red),
                                    onPressed: () {
                                      _cancelAppointment(appointment['id']);
                                    },
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
    );
  }
}
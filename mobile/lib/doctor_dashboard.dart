import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
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
      body: const Center(
        child: Text(
          'Welcome, Doctor! This is your dashboard.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
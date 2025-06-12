import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Auth/auth_provider.dart';
import 'Auth/login_screen.dart';
import 'Auth/register_screen.dart';
import 'Patient/user_dashboard.dart';
import 'Doctor/doctor_dashboard.dart';
import 'Patient/book_appointment_screen.dart';
import 'Patient/my_appointments_screen.dart';
import 'Patient/medical_record_screen.dart';
import 'Doctor/doctor_patients.dart';
import 'Doctor/doctor_appointments.dart';
import 'Doctor/doctor_profile.dart';
import 'Doctor/doctor_medical_record.dart'; // Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Medical App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/user': (context) => const UserDashboard(),
          '/doctor': (context) => const DoctorDashboard(),
          '/my-appointments': (context) => const MyAppointmentsScreen(),
          '/medical-record': (context) => const MedicalRecordScreen(),
          '/doctor-patients': (context) => const DoctorPatients(),
          '/doctor-appointments': (context) => const DoctorAppointmentsScreen(),
          '/doctor-profile': (context) => const DoctorProfileScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name!.startsWith('/book-appointment')) {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => BookAppointmentScreen(
                services: args?['services'] as List<dynamic>?,
              ),
            );
          } else if (settings.name!.startsWith('/doctor/medical-records/')) {
            final userId = settings.name!.split('/').last;
            return MaterialPageRoute(
              builder: (context) => DoctorMedicalRecordScreen(userId: userId),
            );
          }
          return null;
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Route not found')),
            ),
          );
        },
      ),
    );
  }
}

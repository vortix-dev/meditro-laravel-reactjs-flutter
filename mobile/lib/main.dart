import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'user_dashboard.dart';
import 'doctor_dashboard.dart';
import 'book_appointment_screen.dart';
import 'my_appointments_screen.dart';
import 'medical_record_screen.dart';

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
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/book-appointment') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => BookAppointmentScreen(
                services: args?['services'] as List<dynamic>?,
              ),
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

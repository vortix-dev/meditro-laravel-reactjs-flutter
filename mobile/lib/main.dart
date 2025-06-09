import 'package:flutter/material.dart';
import 'package:meditro/Views/Auth/login_view.dart';
import 'package:meditro/Views/Auth/register_view.dart';
import 'package:meditro/Views/onboarding/onboarding_view.dart';
// import 'package:meditro/Views/doctor/doctor_home_wrapper.dart';
// import 'package:meditro/Views/patient/user_home_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cabinet Médical',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
      home: const OnboardingView(),
      routes: {
        '/login': (context) => LoginView(),
        '/register': (context) => RegisterPage(),
        // '/doctorhome': (context) => DoctorHomeWrapper(),
        // '/userhome': (context) => UserHomeWrapper(),
      },
    );
  }
}

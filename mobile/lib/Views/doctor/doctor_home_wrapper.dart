import 'package:flutter/material.dart';
import 'package:meditro/Views/doctor/doctor_appointment_view.dart';
import 'package:meditro/Views/doctor/doctor_home_view.dart';
import 'package:meditro/Views/widgets/Doctor_bottom_nav_bar.dart';


class DoctorHomeWrapper extends StatefulWidget {
  const DoctorHomeWrapper({Key? key}) : super(key: key);

  @override
  State<DoctorHomeWrapper> createState() => _DoctorHomeWrapperState();
}

class _DoctorHomeWrapperState extends State<DoctorHomeWrapper> {
  int _currentIndex = 0;

  // Liste des vues liées aux onglets
  final List<Widget> _pages = [
    DoctorHomeView (), // Ton écran d'accueil principal
    DoctorAppointmentView(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Affiche la page selon l'index
      bottomNavigationBar: DoctorBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

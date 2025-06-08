import 'package:flutter/material.dart';
import 'package:meditro/Views/patient/dossier_view.dart';
import 'package:meditro/Views/patient/user_appointment_view.dart';
import 'package:meditro/Views/widgets/user_bottom_nav_bar.dart';
import 'user_home_view.dart';

class UserHomeWrapper extends StatefulWidget {
  const UserHomeWrapper({Key? key}) : super(key: key);

  @override
  State<UserHomeWrapper> createState() => _UserHomeWrapperState();
}

class _UserHomeWrapperState extends State<UserHomeWrapper> {
  int _currentIndex = 0;

  // Liste des vues liées aux onglets
  final List<Widget> _pages = [
    UserHomeView(), // Ton écran d'accueil principal
    UserAppointmentView(),
    DossierView(),
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
      bottomNavigationBar: UserBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

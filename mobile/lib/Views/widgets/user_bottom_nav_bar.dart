import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const UserBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Color.fromARGB(255, 86, 90, 207),
      selectedItemColor: Colors.white,
      unselectedItemColor: Color.fromARGB(255, 179, 179, 179),
      showSelectedLabels: true,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.houseMedical),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.calendarCheck),
          label: 'Rendez-vous',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.fileMedical),
          label: 'Dossier',
        ),
      ],
    );
  }
}

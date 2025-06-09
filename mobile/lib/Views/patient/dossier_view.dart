import 'package:flutter/material.dart';
import 'package:meditro/Views/widgets/user_top_bar.dart';

class DossierView extends StatelessWidget {
  const DossierView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: UserTopBar(
           userId: 'your_user_id', 
          logoImagePath: 'assets/img/logo.png', // ton logo image
          avatarImagePath:
              'assets/img/imgDoctor/DoctorHeader.png', // photo profil
          // onNotificationTap: () { /* action notif */ },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/img/imgBg/Backgroundelapps.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // le reste du contenu ici...
        ],
      ),
    );
  }
}

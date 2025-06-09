import 'package:flutter/material.dart';
import 'package:meditro/Views/patient/user_all_doctors_view.dart';
import 'package:meditro/Views/patient/user_all_services_view.dart';
import 'package:meditro/Views/widgets/floating_image.dart';
import 'package:meditro/Views/widgets/user_top_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserHomeView extends StatelessWidget {
  const UserHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: UserTopBar(
          userId: 'your_user_id',
          logoImagePath: 'assets/img/logo.png',
          avatarImagePath: 'assets/img/imgDoctor/DoctorHeader.png',
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/img/imgBg/Backgroundelapps.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Floating images (fixes et non scrollables)
          const FloatingImage(
            imagePath: 'assets/img/imgForm/forme1.png',
            width: 70,
            bottom: 50,
            left: 10,
          ),
          const FloatingImage(
            imagePath: 'assets/img/imgForm/forme2.png',
            width: 70,
            top: 120,
            right: 20,
          ),
          const FloatingImage(
            imagePath: 'assets/img/imgForm/forme3.png',
            width: 70,
            bottom: 70,
            left: 330,
          ),
          const FloatingImage(
            imagePath: 'assets/img/imgForm/forme4.png',
            width: 150,
            bottom: 320,
            left: 70,
          ),
          const FloatingImage(
            imagePath: 'assets/img/imgForm/forme5.png',
            width: 70,
            top: 150,
            right: 300,
          ),

          // Scrollable content with SafeArea
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50), // Compense la SafeArea en haut
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/img/imgDoctor/DoctorHeader.png',
                          width: 300,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Votre Santé Mérite\nToute Notre Attention',
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF565ACF),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Bienvenue sur Meditro, l’app simple et rapide pour prendre rendez-vous avec votre cabinet médical.',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF17732),
                            minimumSize: const Size(205, 62),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Demander un Rendez-vous',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    'Nos Services',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF565ACF),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: List.generate(4, (index) {
                        final icons = [
                          FontAwesomeIcons.stethoscope,
                          FontAwesomeIcons.suitcaseMedical,
                          FontAwesomeIcons.tooth,
                          FontAwesomeIcons.truckMedical,
                        ];

                        final titles = [
                          'Diagnostics',
                          'Chirurgie',
                          'Dentaire',
                          'Urgence',
                        ];

                        final subtitles = [
                          'Une évaluation médicale précise et approfondie pour identifier rapidement les pathologies et orienter vers le traitement adapté.',
                          'Des interventions chirurgicales sûres, encadrées par une équipe spécialisée, dans un environnement stérile et sécurisé.',
                          'Des soins dentaires complets, alliant technologie moderne et expertise pour une santé buccodentaire optimale.',
                          'Une prise en charge rapide et efficace 24h/24 pour répondre à toutes les situations médicales critiques.',
                        ];

                        return Container(
                          width: 175,
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F1F1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: FaIcon(
                                          icons[index],
                                          size: 40,
                                          color: const Color.fromARGB(
                                            255,
                                            31,
                                            34,
                                            120,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  titles[index],
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 23,
                                    color: Color.fromARGB(255, 241, 120, 50),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                child: Text(
                                  subtitles[index],
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 86, 90, 207),
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllServicesView(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF17732),
                      minimumSize: const Size(205, 62),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Voir Tout Nos Services',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    'Nos Docteurs',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF565ACF),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: List.generate(4, (index) {
                      return Container(
                        width: 175,
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: Image.asset(
                                'assets/img/imgDoctor/Docteur4.jpg',
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Dr. Jean Dupont',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Action à ajouter ici
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF565ACF),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Voir Détail',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllDoctorsView(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF17732),
                      minimumSize: const Size(205, 62),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Voir Tout Nos Médecins',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Icon(Icons.phone, size: 50, color: Color(0xFF565ACF)),
                      Icon(
                        Icons.access_time,
                        size: 50,
                        color: Color(0xFF565ACF),
                      ),
                      Icon(Icons.map, size: 50, color: Color(0xFF565ACF)),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

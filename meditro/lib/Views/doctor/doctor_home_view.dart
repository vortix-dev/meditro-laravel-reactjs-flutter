import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meditro/Views/widgets/doctor_top_bar.dart';

class DoctorHomeView extends StatelessWidget {
  const DoctorHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: DoctorTopBar(
          doctorId: 'your_user_id',
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

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bienvenue Docteur 👨‍⚕️",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF565ACF),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Barre de recherche
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'Rechercher un patient...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Dernier rendez-vous
                  _buildLastAppointmentCard(context),

                  const SizedBox(height: 20),

                  // Patients récents
                  _buildRecentPatientCard(context),

                  const SizedBox(height: 30),

                  // Boutons existants
                  _buildHomeButton(
                    context,
                    title: "Mes Rendez-vous",
                    icon: Icons.calendar_today,
                    color: const Color(0xFFF17732),
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _buildHomeButton(
                    context,
                    title: "Mon Profil",
                    icon: Icons.person,
                    color: const Color(0xFF565ACF),
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _buildHomeButton(
                    context,
                    title: "Liste des Patients",
                    icon: Icons.people,
                    color: Colors.green,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastAppointmentCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dernier Rendez-vous",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Patient : Sarah Dupuis",
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                Text(
                  "Heure : 14h00 - 3 juin 2025",
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF17732),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    // TODO: naviguer vers la liste de tous les RDV
                  },
                  child: const Text("Tous mes rendez-vous"),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.access_time, color: Color(0xFFF17732), size: 40),
        ],
      ),
    );
  }

  Widget _buildRecentPatientCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          const FaIcon(
            FontAwesomeIcons.user,
            color: Color(0xFFF17732),
            size: 40,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "Patient récent : Maxime Laurent",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.fileMedical,
              color: Color(0xFFF17732),
            ),
            onPressed: () {
              // TODO: naviguer vers la vue dossier médical du patient
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

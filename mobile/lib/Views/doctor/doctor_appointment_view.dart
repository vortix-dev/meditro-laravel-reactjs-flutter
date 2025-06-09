import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorAppointmentView extends StatelessWidget {
  const DoctorAppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    // Fake data pour les rendez-vous
    final List<Map<String, dynamic>> appointments = [
      {
        'patient': 'Alice Dupont',
        'date': '2025-06-10',
        'heure': '14:30',
        'motif': 'Consultation générale'
      },
      {
        'patient': 'Karim B.',
        'date': '2025-06-12',
        'heure': '10:00',
        'motif': 'Suivi diabète'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF565ACF),
        title: const Text(
          'Mes Rendez-vous',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment['patient'],
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF565ACF),
              ),
            ),
            const SizedBox(height: 8),
            Text("Date : ${appointment['date']}"),
            Text("Heure : ${appointment['heure']}"),
            Text("Motif : ${appointment['motif']}"),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Terminer", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    // TODO: Marquer comme terminé
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text("Supprimer", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    // TODO: Supprimer le rendez-vous
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

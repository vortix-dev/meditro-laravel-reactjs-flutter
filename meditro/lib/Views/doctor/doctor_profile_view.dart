import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meditro/Controllers/doctor_controller.dart';
import 'package:meditro/Views/doctor/edit_doctor_field_page.dart.dart';

class ProfileDoctorPage extends StatefulWidget {
  final String doctorId;

  const ProfileDoctorPage({super.key, required this.doctorId});

  @override
  State<ProfileDoctorPage> createState() => _ProfileDoctorPageState();
}

class _ProfileDoctorPageState extends State<ProfileDoctorPage> {
  final DoctorController controller =
      DoctorController(baseUrl: 'https://your-api-base-url.com');

  Map<String, dynamic>? doctor;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    try {
      final data = await controller.getDoctorById(widget.doctorId);
      setState(() {
        doctor = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur : $e");
      setState(() => isLoading = false);
    }
  }

  void _editField(String fieldKey, String label) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditDoctorFieldPage(
          controller: controller,
          doctorId: widget.doctorId,
          fieldKey: fieldKey,
          fieldLabel: label,
          currentValue: doctor?[fieldKey] ?? '',
        ),
      ),
    );

    if (result == true) {
      _loadDoctor(); // recharge les données
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer votre compte ?"),
        content: const Text("Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, "deleted");
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (doctor == null) {
      return const Scaffold(
        body: Center(child: Text('Erreur de chargement')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF565ACF),
        title: const Text('Profil Médecin', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: doctor!['photo'] != null && doctor!['photo'].toString().isNotEmpty
                    ? NetworkImage(doctor!['photo']) as ImageProvider
                    : const AssetImage('assets/img/default_doctor.png'),
              ),
              const SizedBox(height: 20),
              _buildFieldCard("Nom", "nom"),
              _buildFieldCard("Prénom", "prenom"),
              _buildFieldCard("Email", "email"),
              _buildFieldCard("Téléphone", "telephone"),
              _buildFieldCard("Spécialité", "specialite"),
              _buildFieldCard("Adresse du cabinet", "adresse"),
              _buildFieldCard("Numéro d’ordre", "numeroOrdre"),
              _buildFieldCard("Genre", "genre"),
              const SizedBox(height: 30),
              _buildActionButton("Supprimer mon compte", Colors.red, _confirmDeleteAccount),
              const SizedBox(height: 10),
              _buildActionButton("Se déconnecter", const Color(0xFF007BFF), () {
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldCard(String label, String fieldKey) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(
          "$label : ${doctor?[fieldKey] ?? ''}",
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFFF17732)),
          onPressed: () => _editField(fieldKey, label),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

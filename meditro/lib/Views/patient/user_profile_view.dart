import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meditro/Controllers/user_controller.dart';
import 'package:meditro/Views/patient/edit_field_view.dart';

class ProfilePatientPage extends StatefulWidget {
  final String userId;
  const ProfilePatientPage({super.key, required this.userId});

  @override
  State<ProfilePatientPage> createState() => _ProfilePatientPageState();
}

class _ProfilePatientPageState extends State<ProfilePatientPage> {
  late UserController controller;
  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = UserController(userId: widget.userId);
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      isLoading = true;
    });
    // Si getUser est synchrone, supprime le await
    final loadedUser = await controller.getUser();
    setState(() {
      user = loadedUser;
      isLoading = false;
    });
  }

  Future<void> _editField(String field, String label) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditFieldPage(
              userId: widget.userId,
              fieldKey: field,
              fieldLabel: label,
              currentValue: user?[field] ?? '',
            ),
      ),
    );

    if (result == true) {
      await _loadUser();
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirmer la suppression"),
            content: const Text(
              "Voulez-vous vraiment supprimer votre compte ?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              TextButton(
                onPressed: () {
                  controller.deleteUser();
                  Navigator.pop(context);
                  Navigator.pop(context, "deleted");
                },
                child: const Text(
                  "Supprimer",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Utilisateur introuvable",
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    String photoPath = user!['photo'] ?? '';
    // Si c’est une asset locale valide sinon mettre image par défaut
    final imageProvider =
        (photoPath.isNotEmpty && photoPath.startsWith('assets/'))
            ? AssetImage(photoPath)
            : const AssetImage('assets/img/default_user.png');

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 255),
      appBar: AppBar(
        backgroundColor: const Color(0xFF565ACF),
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/imgBg/Backgroundelapps.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(radius: 50, backgroundImage: imageProvider),
                  const SizedBox(height: 20),
                  _buildFieldCard("Nom", "nom"),
                  _buildFieldCard("Prénom", "prenom"),
                  _buildFieldCard("Email", "email"),
                  _buildFieldCard("Téléphone", "telephone"),
                  _buildFieldCard("Date de naissance", "dateNaissance"),
                  _buildFieldCard("Genre", "genre"),
                  _buildFieldCard("Groupe sanguin", "groupSanguin"),
                  _buildFieldCard("Mesure", "mesure"),
                  _buildFieldCard("Poids", "poids"),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _confirmDeleteAccount,
                      child: Text(
                        "Supprimer mon compte",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Se déconnecter",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(String label, String fieldKey) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(
          "$label : ${user?[fieldKey] ?? ''}",
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFFF17732)),
          onPressed: () => _editField(fieldKey, label),
        ),
      ),
    );
  }
}

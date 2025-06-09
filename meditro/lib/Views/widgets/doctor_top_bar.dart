import 'package:flutter/material.dart';
import 'package:meditro/Views/doctor/doctor_profile_view.dart';

class DoctorTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String logoImagePath;
  final VoidCallback? onNotificationTap;
  final String avatarImagePath;
  final String doctorId; // Ajoute l'userId

  const DoctorTopBar({
    Key? key,
    required this.logoImagePath,
    this.onNotificationTap,
    required this.avatarImagePath,
    required this.doctorId, // <-- requis pour navigation
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo image
            SizedBox(
              width: 176,
              height: 43,
              child: Image.asset(logoImagePath, fit: BoxFit.cover),
            ),

            Row(
              children: [
                // Icône notification
                IconButton(
                  onPressed: onNotificationTap,
                  icon: const Icon(Icons.notifications),
                  color: const Color.fromARGB(255, 255, 153, 0),
                  iconSize: 30,
                ),

                const SizedBox(width: 8),

                // Avatar cliquable
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileDoctorPage(doctorId: doctorId),
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromARGB(88, 0, 0, 0),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(avatarImagePath, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

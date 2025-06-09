import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meditro/Controllers/service_controller.dart';

class AllServicesView extends StatefulWidget {
  const AllServicesView({Key? key}) : super(key: key);

  @override
  State<AllServicesView> createState() => _AllServicesViewState();
}

class _AllServicesViewState extends State<AllServicesView> {
  final ServiceController serviceController = ServiceController(baseUrl: 'http://10.0.2.2:8000/api');
  late Future<List<Map<String, dynamic>>> futureServices;

  @override
  void initState() {
    super.initState();
    futureServices = serviceController.getAllServices();
  }

  IconData getServiceIcon(String iconName) {
    switch (iconName) {
      case 'stethoscope':
        return FontAwesomeIcons.stethoscope;
      case 'suitcaseMedical':
        return FontAwesomeIcons.suitcaseMedical;
      case 'tooth':
        return FontAwesomeIcons.tooth;
      case 'truckMedical':
        return FontAwesomeIcons.truckMedical;
      default:
        return FontAwesomeIcons.briefcaseMedical;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 255),
      appBar: AppBar(
        backgroundColor: const Color(0xFF565ACF),
        title: const Text(
          'Tous Nos Services',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: futureServices,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun service disponible.'));
            }

            final services = snapshot.data!;

            return ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F1F1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: FaIcon(
                            getServiceIcon(service["icon"] ?? ''),
                            color: const Color(0xFF565ACF),
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service["title"] ?? '',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFFF17732),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              service["description"] ?? '',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Color(0xFF565ACF),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

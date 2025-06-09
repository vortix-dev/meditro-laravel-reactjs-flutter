import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meditro/Views/widgets/user_top_bar.dart';

class UserAppointmentView extends StatefulWidget {
  const UserAppointmentView({super.key});

  @override
  State<UserAppointmentView> createState() => _UserAppointmentViewState();
}

class _UserAppointmentViewState extends State<UserAppointmentView> {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  String? selectedService;
  String? selectedDoctor;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int? editingIndex;

  // *** Données locales à la place de fake_api ***

  // Exemple de services
  final List<Map<String, String>> services = [
    {'title': 'Cardiologie'},
    {'title': 'Dermatologie'},
    {'title': 'Pédiatrie'},
  ];

  // Exemple de docteurs
  final List<Map<String, String>> doctors = [
    {
      'name': 'Dr. Dupont',
      'specialty': 'Cardiologie',
      'image': 'assets/img/Docteur4.png',
    },
    {
      'name': 'Dr. Martin',
      'specialty': 'Dermatologie',
      'image': 'assets/img/Docteur4.png',
    },
    {
      'name': 'Dr. Leroy',
      'specialty': 'Pédiatrie',
      'image': 'assets/img/Docteur4.png',
    },
  ];

  // Liste des rendez-vous (initialement vide ou avec exemples)
  final List<Map<String, String>> appointments = [
    {
      'service': 'Cardiologie',
      'doctorName': 'Dr. Dupont',
      'date': '2025-06-10',
      'time': '14:30',
      'status': 'Confirmé',
      'image': 'assets/img/Docteur4.png',
    },
    {
      'service': 'Dermatologie',
      'doctorName': 'Dr. Martin',
      'date': '2025-06-12',
      'time': '09:00',
      'status': 'En attente',
      'image': 'assets/imgDoctor/Docteur4.jpg',
    },
  ];

  // Getter filtrant les docteurs selon le service sélectionné
  List<Map<String, String>> get filteredDoctors {
    if (selectedService == null) return [];
    return doctors.where((d) => d['specialty'] == selectedService).toList();
  }

  void openAppointmentForm({int? index}) {
    if (index != null) {
      final appointment = appointments[index];
      selectedService = appointment['service'];
      selectedDoctor = appointment['doctorName'];
      selectedDate = DateTime.tryParse(appointment['date'] ?? '');
      final timeParts = (appointment['time'] ?? '').split(':');
      if (timeParts.length == 2) {
        selectedTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }
      editingIndex = index;
    } else {
      selectedService = null;
      selectedDoctor = null;
      selectedDate = null;
      selectedTime = null;
      editingIndex = null;
    }

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                backgroundColor: const Color.fromARGB(255, 131, 133, 202),
                title: Text(
                  index == null
                      ? 'Ajouter Rendez-vous'
                      : 'Modifier Rendez-vous',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedService,
                        dropdownColor: Colors.white,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Choisir un service',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                        ),
                        items:
                            services
                                .map(
                                  (service) => DropdownMenuItem(
                                    value: service['title'],
                                    child: Text(
                                      service['title']!,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setStateDialog(() {
                            selectedService = val;
                            selectedDoctor = null;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedDoctor,
                        dropdownColor: Colors.white,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Choisir un docteur',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                        ),
                        items:
                            filteredDoctors
                                .map(
                                  (doc) => DropdownMenuItem(
                                    value: doc['name'],
                                    child: Text(
                                      doc['name']!,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setStateDialog(() {
                            selectedDoctor = val;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Colors.orange,
                        ),
                        label: Text(
                          selectedDate == null
                              ? 'Choisir la date'
                              : dateFormat.format(selectedDate!),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontFamily: 'Poppins',
                            fontSize: 20,
                          ),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setStateDialog(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.access_time,
                          color: Colors.orange,
                        ),
                        label: Text(
                          selectedTime == null
                              ? 'Choisir l\'heure'
                              : selectedTime!.format(context),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontFamily: 'Poppins',
                            fontSize: 20,
                          ),
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setStateDialog(() {
                              selectedTime = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 17, 0),
                        fontFamily: 'Poppins',
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      if (selectedService == null ||
                          selectedDoctor == null ||
                          selectedDate == null ||
                          selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Veuillez remplir tous les champs',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                color: Color.fromARGB(255, 255, 17, 0),
                              ),
                            ),
                          ),
                        );
                        return;
                      }

                      final doctorImage =
                          doctors.firstWhere(
                            (d) => d['name'] == selectedDoctor,
                            orElse:
                                () => {
                                  'image': 'assets/img/default_doctor.png',
                                },
                          )['image'] ??
                          'assets/img/default_doctor.png';

                      final appointmentMap = {
                        'service': selectedService!,
                        'doctorName': selectedDoctor!,
                        'date': dateFormat.format(selectedDate!),
                        'time':
                            '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                        'status': 'En attente',
                        'image': doctorImage,
                      };

                      setState(() {
                        if (editingIndex != null) {
                          appointments[editingIndex!] = appointmentMap;
                        } else {
                          appointments.add(appointmentMap);
                        }
                      });

                      Navigator.pop(context);
                    },
                    child: Text(
                      index == null ? 'Ajouter' : 'Modifier',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  void deleteAppointment(int index) {
    setState(() {
      appointments.removeAt(index);
    });
  }

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
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAppointmentForm(),
        backgroundColor: const Color.fromARGB(255, 31, 34, 120),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/img/imgBg/Backgroundelapps.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
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
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          appointment['image'] ??
                              'assets/img/default_doctor.png',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment['doctorName'] ?? 'Inconnu',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color.fromARGB(255, 31, 34, 120),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appointment['service'] ?? 'Service inconnu',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Color(0xFFF17732),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  appointment['date'] ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  appointment['time'] ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appointment['status'] ?? '',
                              style: TextStyle(
                                color:
                                    appointment['status'] == 'Confirmé'
                                        ? Colors.green
                                        : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => openAppointmentForm(index: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteAppointment(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

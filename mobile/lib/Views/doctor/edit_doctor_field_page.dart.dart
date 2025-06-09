import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meditro/Controllers/doctor_controller.dart';

class EditDoctorFieldPage extends StatefulWidget {
  final DoctorController controller;
  final String doctorId;
  final String fieldKey;
  final String fieldLabel;
  final String currentValue;

  const EditDoctorFieldPage({
    super.key,
    required this.controller,
    required this.doctorId,
    required this.fieldKey,
    required this.fieldLabel,
    required this.currentValue,
  });

  @override
  State<EditDoctorFieldPage> createState() => _EditDoctorFieldPageState();
}

class _EditDoctorFieldPageState extends State<EditDoctorFieldPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;
  String? _selectedValue;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.currentValue;
    _controller = TextEditingController(text: _selectedValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveField() async {
    if (_formKey.currentState!.validate()) {
      final newValue =
          (widget.fieldKey == 'genre' || widget.fieldKey == 'specialite')
              ? _selectedValue
              : _controller.text.trim();

      if (newValue != null && newValue.isNotEmpty) {
        setState(() => _isSaving = true);

        final success = await widget.controller.updateDoctorField(
          widget.doctorId,
          widget.fieldKey,
          newValue,
        );

        setState(() => _isSaving = false);

        if (success) {
          Navigator.pop(context, true); // notify success
        } else {
          _showErrorDialog("Échec de la mise à jour du champ.");
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Erreur"),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDropdownField =
        widget.fieldKey == 'genre' || widget.fieldKey == 'specialite';

    List<String> dropdownOptions = [];
    if (widget.fieldKey == 'genre') {
      dropdownOptions = ['Homme', 'Femme'];
    } else if (widget.fieldKey == 'specialite') {
      dropdownOptions = [
        'Généraliste',
        'Cardiologue',
        'Dermatologue',
        'Pédiatre',
        'Gynécologue',
        'Psychiatre',
        'Ophtalmologue',
        'Dentiste',
      ];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF565ACF),
        title: Text(
          'Modifier ${widget.fieldLabel}',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              isDropdownField
                  ? DropdownButtonFormField<String>(
                    value: _selectedValue,
                    decoration: InputDecoration(
                      labelText: widget.fieldLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items:
                        dropdownOptions.map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged:
                        (value) => setState(() => _selectedValue = value),
                    validator:
                        (value) =>
                            value == null
                                ? "Veuillez choisir une option"
                                : null,
                  )
                  : TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: widget.fieldLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Ce champ est requis.";
                      }
                      return null;
                    },
                  ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveField,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF565ACF),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child:
                      _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            "Enregistrer",
                            style: GoogleFonts.poppins(
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
    );
  }
}

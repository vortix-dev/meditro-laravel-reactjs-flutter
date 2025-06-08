import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meditro/Controllers/user_controller.dart';

class EditFieldPage extends StatefulWidget {
  final String userId;
  final String fieldKey;
  final String fieldLabel;
  final String currentValue;
  

  const EditFieldPage({
    super.key,
    required this.userId,
    required this.fieldKey,
    required this.fieldLabel,
    required this.currentValue,
  });

  @override
  State<EditFieldPage> createState() => _EditFieldPageState();
}

class _EditFieldPageState extends State<EditFieldPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;
  late UserController _userController;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
    _selectedValue = widget.currentValue;
    _userController = UserController(userId: widget.userId);
  }

  void _saveField() {
    if (_formKey.currentState!.validate()) {
      final valueToSave = _selectedValue ?? _controller.text;
      _userController.updateField(widget.fieldKey, valueToSave);
      Navigator.pop(context, true); // succès
    }
  }

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(widget.currentValue) ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedValue =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDropdownField =
        widget.fieldKey == 'genre' || widget.fieldKey == 'groupSanguin';
    final isDateField = widget.fieldKey == 'dateNaissance';
    final isNumericField =
        widget.fieldKey == 'poids' || widget.fieldKey == 'mesure';
    final isPhoneField = widget.fieldKey == 'telephone';

    List<String> dropdownOptions = [];
    if (widget.fieldKey == 'genre') {
      dropdownOptions = ['Homme', 'Femme'];
    } else if (widget.fieldKey == 'groupSanguin') {
      dropdownOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 255),
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
              if (isDropdownField)
                DropdownButtonFormField<String>(
                  value: _selectedValue,
                  decoration: InputDecoration(
                    labelText: widget.fieldLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items:
                      dropdownOptions.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (value) => setState(() => _selectedValue = value),
                  validator:
                      (value) =>
                          value == null ? "Veuillez choisir une option" : null,
                )
              else if (isDateField)
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: _selectedValue),
                  onTap: _pickDate,
                  decoration: InputDecoration(
                    labelText: widget.fieldLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? "Veuillez sélectionner une date"
                              : null,
                )
              else
                TextFormField(
                  controller: _controller,
                  keyboardType:
                      isNumericField || isPhoneField
                          ? TextInputType.number
                          : TextInputType.text,
                  decoration: InputDecoration(
                    labelText: widget.fieldLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Ce champ est requis.";
                    if (isPhoneField && !RegExp(r'^\d{10}$').hasMatch(value))
                      return "Le numéro doit contenir 10 chiffres.";
                    if (isNumericField && double.tryParse(value) == null)
                      return "Veuillez entrer un nombre valide.";
                    return null;
                  },
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveField,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF565ACF),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
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

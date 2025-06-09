import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meditro/Services/api_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _sexeController = TextEditingController();
  final _addressController = TextEditingController();
  final _telephoneController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
        sexe: _sexeController.text.trim().toLowerCase(),
        address: _addressController.text.trim(),
        telephone: _telephoneController.text.trim(),
      );

      setState(() => _loading = false);

      if (result != null &&
          (result['error'] == null || result['error'].isEmpty)) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _error = result?['error'] ?? 'Erreur inconnue');
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Erreur réseau ou serveur : $e';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _sexeController.dispose();
    _addressController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Inscription',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Color(0xFF565ACF),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/img/imgBg/Backgroundelapps.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 30),
                      Text(
                        "Créer un compte",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF565ACF),
                        ),
                      ),
                      SizedBox(height: 10),
                      if (_error != null)
                        Text(_error!, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 10),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nom complet',
                      ),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est requis';
                          }
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Mot de passe',
                        obscureText: true,
                        validator:
                            (value) =>
                                value == null || value.length < 6
                                    ? 'Minimum 6 caractères'
                                    : null,
                      ),
                      _buildTextField(
                        controller: _passwordConfirmController,
                        label: 'Confirmer mot de passe',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Ce champ est requis';
                          if (value != _passwordController.text)
                            return 'Les mots de passe ne correspondent pas';
                          return null;
                        },
                      ),
                      _buildDropdownSexe(),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Adresse',
                      ),
                      _buildTextField(
                        controller: _telephoneController,
                        label: 'Téléphone',
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 20),
                      _loading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF17732),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 32,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              "S’inscrire",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "J’ai déjà un compte ? ",
                            style: GoogleFonts.poppins(color: Colors.grey[700]),
                            children: [
                              TextSpan(
                                text: "Se connecter",
                                style: GoogleFonts.poppins(
                                  color: Color(0xFFF17732),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator:
            validator ?? (value) => value!.isEmpty ? 'Champ requis' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSexe() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _sexeController.text.isNotEmpty ? _sexeController.text : null,
        onChanged: (value) {
          setState(() {
            _sexeController.text = value!;
          });
        },
        decoration: InputDecoration(
          labelText: 'Sexe',
          labelStyle: GoogleFonts.poppins(),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        validator:
            (value) =>
                value == null || value.isEmpty
                    ? 'Veuillez choisir un sexe'
                    : null,
        items:
            ['Homme', 'Femme'].map((sexe) {
              return DropdownMenuItem(
                value: sexe.toLowerCase(),
                child: Text(sexe, style: GoogleFonts.poppins()),
              );
            }).toList(),
      ),
    );
  }
}

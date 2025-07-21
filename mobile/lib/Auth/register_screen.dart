import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _addressController = TextEditingController();
  final _telephoneController = TextEditingController();
  String? _sexe;
  bool _isButtonPressed = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _addressController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // Supprime le bouton retour
      ),
      body: Stack(
        children: [
          // Fond d'écran
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Backgroundelapps.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenu
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 48.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Logo
                    Image.asset('assets/logo.png', height: 100),
                    const SizedBox(height: 20),

                    // Titre
                    Text(
                      'Créer un compte',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF565ACF),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Champs
                    _buildField(_nameController, 'Nom complet', Icons.person),
                    const SizedBox(height: 16),
                    _buildField(
                      _emailController,
                      'Email',
                      Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      _passwordController,
                      'Mot de passe',
                      Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      _passwordConfirmationController,
                      'Confirmer mot de passe',
                      Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(),
                    const SizedBox(height: 16),
                    _buildField(_addressController, 'Adresse', Icons.home),
                    const SizedBox(height: 16),
                    _buildField(
                      _telephoneController,
                      'Téléphone',
                      Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),

                    // Bouton
                    authProvider.isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF565ACF),
                            ),
                          )
                        : GestureDetector(
                            onTapDown: (_) =>
                                setState(() => _isButtonPressed = true),
                            onTapUp: (_) =>
                                setState(() => _isButtonPressed = false),
                            onTapCancel: () =>
                                setState(() => _isButtonPressed = false),
                            child: AnimatedScale(
                              scale: _isButtonPressed ? 0.95 : 1.0,
                              duration: const Duration(milliseconds: 100),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      bool success = await authProvider
                                          .register(
                                            name: _nameController.text,
                                            email: _emailController.text,
                                            password: _passwordController.text,
                                            passwordConfirmation:
                                                _passwordConfirmationController
                                                    .text,
                                            sexe: _sexe!,
                                            address: _addressController.text,
                                            telephone:
                                                _telephoneController.text,
                                          );
                                      if (success) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Inscription réussie',
                                            ),
                                          ),
                                        );
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/user',
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF565ACF),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'S\'INSCRIRE',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),

                    // Redirection vers Connexion
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text.rich(
                        TextSpan(
                          text: 'J’ai déjà un compte ? ',
                          style: GoogleFonts.poppins(color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Se connecter',
                              style: GoogleFonts.poppins(
                                color: Color(0xFF565ACF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.black),
        prefixIcon: Icon(icon, color: Color(0xFF565ACF)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF565ACF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF565ACF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF565ACF), width: 2),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Ce champ est requis' : null,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _sexe,
      decoration: InputDecoration(
        labelText: 'Sexe',
        labelStyle: GoogleFonts.poppins(color: Colors.black),
        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF565ACF)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF565ACF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF565ACF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF565ACF), width: 2),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Homme', child: Text('Homme')),
        DropdownMenuItem(value: 'Femme', child: Text('Femme')),
      ],
      onChanged: (value) => setState(() => _sexe = value),
      validator: (value) => value == null ? 'Veuillez choisir un sexe' : null,
    );
  }
}

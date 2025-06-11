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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF26A69A), Color(0xFF7E57C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 600 : screenWidth * 0.9,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.02,
                      ),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
                          child: Form(
                            key: _formKey,
                            child: isTablet
                                ? _buildTabletLayout(authProvider, screenWidth)
                                : _buildMobileLayout(authProvider, screenWidth),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(AuthProvider authProvider, double screenWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Create Account',
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.07,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (authProvider.errorMessage != null)
          Text(
            authProvider.errorMessage!,
            style: GoogleFonts.poppins(
              color: Colors.redAccent,
              fontSize: screenWidth * 0.035,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameController,
          label: 'Name',
          icon: Icons.person,
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter your name' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter your email' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock,
          obscureText: true,
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter your password'
              : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordConfirmationController,
          label: 'Confirm Password',
          icon: Icons.lock,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty)
              return 'Please confirm your password';
            if (value != _passwordController.text)
              return 'Passwords do not match';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildGenderDropdown(screenWidth),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          icon: Icons.location_on,
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter your address'
              : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _telephoneController,
          label: 'Telephone',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter your telephone number'
              : null,
        ),
        const SizedBox(height: 24),
        authProvider.isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF26A69A)),
              )
            : _buildRegisterButton(authProvider, screenWidth),
      ],
    );
  }

  Widget _buildTabletLayout(AuthProvider authProvider, double screenWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Create Account',
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (authProvider.errorMessage != null)
          Text(
            authProvider.errorMessage!,
            style: GoogleFonts.poppins(
              color: Colors.redAccent,
              fontSize: screenWidth * 0.025,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _nameController,
                label: 'Name',
                icon: Icons.person,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your name'
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your email'
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your password'
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _passwordConfirmationController,
                label: 'Confirm Password',
                icon: Icons.lock,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please confirm your password';
                  if (value != _passwordController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildGenderDropdown(screenWidth)),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your address'
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _telephoneController,
          label: 'Telephone',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter your telephone number'
              : null,
        ),
        const SizedBox(height: 24),
        authProvider.isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF26A69A)),
              )
            : _buildRegisterButton(authProvider, screenWidth),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF26A69A)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildGenderDropdown(double screenWidth) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: GoogleFonts.poppins(),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF26A69A)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      value: _sexe,
      items: ['Male', 'Female']
          .map(
            (gender) => DropdownMenuItem(
              value: gender == 'Male' ? 'Homme' : 'Femme',
              child: Text(
                gender,
                style: GoogleFonts.poppins(fontSize: screenWidth * 0.035),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _sexe = value;
        });
      },
      validator: (value) => value == null ? 'Please select your gender' : null,
    );
  }

  Widget _buildRegisterButton(AuthProvider authProvider, double screenWidth) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isButtonPressed = true),
      onTapUp: (_) => setState(() => _isButtonPressed = false),
      onTapCancel: () => setState(() => _isButtonPressed = false),
      child: AnimatedScale(
        scale: _isButtonPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: FractionallySizedBox(
          widthFactor: 1.0,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF26A69A), Color(0xFF7E57C2)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  bool success = await authProvider.register(
                    name: _nameController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                    passwordConfirmation: _passwordConfirmationController.text,
                    sexe: _sexe!,
                    address: _addressController.text,
                    telephone: _telephoneController.text,
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registration successful')),
                    );
                    Navigator.pushReplacementNamed(context, '/user');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Register',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (authProvider.errorMessage != null)
                  Text(
                    authProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordConfirmationController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Gender'),
                  value: _sexe,
                  items: ['Male', 'Female']
                      .map(
                        (gender) => DropdownMenuItem(
                          value: gender == 'Male' ? 'Homme' : 'Femme',
                          child: Text(gender),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _sexe = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _telephoneController,
                  decoration: const InputDecoration(labelText: 'Telephone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your telephone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            bool success = await authProvider.register(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              passwordConfirmation:
                                  _passwordConfirmationController.text,
                              sexe: _sexe!,
                              address: _addressController.text,
                              telephone: _telephoneController.text,
                            );
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Registration successful'),
                                ),
                              );
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          }
                        },
                        child: const Text('Register'),
                      ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

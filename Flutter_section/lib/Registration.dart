import 'dart:convert';
import 'package:fit4/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fit4/login.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    ageController.dispose();
    genderController.dispose();
    heightController.dispose();
    weightController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary.withOpacity(0.15),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              elevation: 6.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add_rounded,
                        size: 64,
                        color: primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                        buildTextField(
                          controller: nameController,
                          label: 'Name',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        buildTextField(
                          controller: emailController,
                          label: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        buildTextField(
                          controller: phoneController,
                          label: 'Phone',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (value.length < 10 || value.length > 15) {
                              return 'Phone number should be 10-15 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        buildTextField(
                          controller: ageController,
                          label: 'Age',
                          icon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your age';
                            }
                            final age = int.tryParse(value);
                            if (age == null || age <= 0) {
                              return 'Please enter a valid age';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        buildTextField(
                          controller: genderController,
                          label: 'Gender',
                          icon: Icons.people,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your gender';
                            }
                            if (!['Male', 'Female', 'Other'].contains(value)) {
                              return 'Please enter Male, Female, or Other';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        buildTextField(
                          controller: heightController,
                          label: 'Height (cm)',
                          icon: Icons.height,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your height';
                            }
                            final height = double.tryParse(value);
                            if (height == null || height <= 0) {
                              return 'Please enter a valid height';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        buildTextField(
                          controller: weightController,
                          label: 'Weight (kg)',
                          icon: Icons.line_weight,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your weight';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null || weight <= 0) {
                              return 'Please enter a valid weight';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        buildTextField(
                          controller: usernameController,
                          label: 'Username',
                          icon: Icons.account_circle,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        buildTextField(
                          controller: passwordController,
                          label: 'Password',
                          icon: Icons.lock,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  final sh = await SharedPreferences.getInstance();
                                  String url = sh.getString("url") ?? "";

                                  var data = await http.post(
                                    Uri.parse(url + "and_res"),
                                    body: {
                                      'name': nameController.text,
                                      "email": emailController.text,
                                      'phone': phoneController.text,
                                      'age': ageController.text,
                                      'gender': genderController.text,
                                      'height': heightController.text,
                                      'weight': weightController.text,
                                      'username': usernameController.text,
                                      'password': passwordController.text,
                                    },
                                  );

                                  var jsonData = json.decode(data.body);
                                  String status = jsonData['status'] ?? "";
                                  if (status == "user") {
                                    if (!context.mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const login(),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Registration failed. Please try again.'),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print("Error===" + e.toString());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('An error occurred. Please try again.'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: primary,
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        labelText: label,
        labelStyle: TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        fillColor: Colors.white,
        filled: true,
      ),
      validator: validator,
    );
  }
}
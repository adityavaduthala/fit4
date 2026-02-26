import 'dart:convert';
import 'package:fit4/home.dart';
import 'package:fit4/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fit4/Registration.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Ambulance()),
        );
        return false;
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary,
                primary.withOpacity(0.8),
                Colors.blue.shade900,
              ],
            ),
          ),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_circle_rounded,
                            size: 72,
                            color: primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          TextFormField(
                            controller: usernameController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.person_outline, color: primary),
                              labelText: 'Username',
                              labelStyle:
                                  const TextStyle(color: Colors.black54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide:
                                    BorderSide(color: primary, width: 2),
                              ),
                              fillColor: Colors.grey.shade50,
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: passwordController,
                            style: const TextStyle(color: Colors.black),
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.lock_outline, color: primary),
                              labelText: 'Password',
                              labelStyle:
                                  const TextStyle(color: Colors.black54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide:
                                    BorderSide(color: primary, width: 2),
                              ),
                              fillColor: Colors.grey.shade50,
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28.0),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      try {
                                        final sh = await SharedPreferences
                                            .getInstance();
                                        String uname =
                                            usernameController.text.trim();
                                        String paswd = passwordController.text;
                                        String url =
                                            sh.getString("url").toString();

                                        var data = await http.post(
                                          Uri.parse(url + "and_login"),
                                          body: {
                                            'username': uname,
                                            'password': paswd
                                          },
                                        );
                                        var jasondata = json.decode(data.body);
                                        String status =
                                            jasondata['status'].toString();

                                        if (status == "user") {
                                          sh.setString("lid",
                                              jasondata['lid'].toString());
                                          if (!context.mounted) return;
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Home()),
                                          );
                                        } else {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Invalid username or password'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'An error occurred. Please try again.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: primary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: const Text('Login',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RegistrationPage()),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    side: BorderSide(color: primary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: primary,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

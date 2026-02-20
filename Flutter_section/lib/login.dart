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
    return Scaffold(

      body: WillPopScope(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Theme.of(context).primaryColor, Colors.blue.shade900],
            ),
          ),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_circle,
                              size: 80,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 24.0),
                            TextFormField(
                              controller: usernameController,
                              style: TextStyle(color: Colors.black), // Set text color to black
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person, color: Theme.of(context).primaryColor),
                                labelText: "Username",
                                labelStyle: TextStyle(color: Colors.black54), // Make label text visible
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                ),
                                fillColor: Colors.white, // White background for input field
                                filled: true,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: passwordController,
                              style: TextStyle(color: Colors.black), // Set text color to black
                              obscureText: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
                                labelText: "Password",
                                labelStyle: TextStyle(color: Colors.black54), // Make label text visible
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                ),
                                fillColor: Colors.white, // White background for input field
                                filled: true,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24.0),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (!_formKey.currentState!.validate()) {
                                        print("Not validated");
                                      } else {
                                        try {
                                          final sh = await SharedPreferences.getInstance();
                                          String Uname = usernameController.text.toString();
                                          String Paswd = passwordController.text.toString();
                                          String url = sh.getString("url").toString();

                                          var data = await http.post(
                                            Uri.parse(url + "and_login"),
                                            body: {
                                              'username': Uname,
                                              "password": Paswd,
                                            },
                                          );
                                          var jasondata = json.decode(data.body);
                                          String status = jasondata['status'].toString();

                                          if (status == "user") {
                                            String lid = jasondata['lid'].toString();
                                            sh.setString("lid", lid);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => Home())
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Invalid username or password'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          print("Error===" + e.toString());
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('An error occurred. Please try again.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 16.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                    ),
                                    child: Text(
                                      "Login",
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => RegistrationPage())
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 16.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                    ),
                                    child: Text(
                                      "Sign Up",
                                      style: TextStyle(fontSize: 16.0),
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
        onWillPop: () async {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Ambulance())
          );
          return true;
        },
      ),
    );
  }
}
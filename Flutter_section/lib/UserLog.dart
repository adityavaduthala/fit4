import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserLog extends StatefulWidget {
  const UserLog({super.key});

  @override
  State<UserLog> createState() => _UserLogState();
}

class _UserLogState extends State<UserLog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _goalController = TextEditingController();

  String? _selectedLevel;
  String? _selectedCategory;
  String? _selectedExercise;

  List<Map<String, dynamic>> _levels = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _exercises = [];

  @override
  void initState() {
    super.initState();
    fetchLevels();
  }

  // Fetch methods remain the same
  Future<void> fetchLevels() async {
    final sh = await SharedPreferences.getInstance();
    String url = sh.getString("url") ?? "";
    if (!url.endsWith('/')) url += '/';

    final response = await http.get(Uri.parse(url + 'get_levels/'));
    if (response.statusCode == 200) {
      setState(() {
        _levels = List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
      });
    } else {
      print("Failed to load levels");
    }
  }

  Future<void> fetchCategories(String levelId) async {
    final sh = await SharedPreferences.getInstance();
    String url = sh.getString("url") ?? "";
    if (!url.endsWith('/')) url += '/';

    final response = await http.get(Uri.parse(url + 'get_categories/?level_id=$levelId'));
    if (response.statusCode == 200) {
      setState(() {
        _categories = List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
        _selectedCategory = null;
        _exercises = [];
      });
    } else {
      print("Failed to load categories");
    }
  }

  Future<void> fetchExercises(String categoryId) async {
    final sh = await SharedPreferences.getInstance();
    String url = sh.getString("url") ?? "";
    if (!url.endsWith('/')) url += '/';

    final response = await http.get(Uri.parse(url + 'get_exercises/?category_id=$categoryId'));
    if (response.statusCode == 200) {
      setState(() {
        _exercises = List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
        _selectedExercise = null;
      });
    } else {
      print("Failed to load exercises");
    }
  }

  Future<void> submitAchievement() async {
    if (_selectedExercise == null || _selectedLevel == null || _selectedCategory == null || _goalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    final sh = await SharedPreferences.getInstance();
    String url = sh.getString("url") ?? "";
    if (!url.endsWith('/')) url += '/';

    String lid = sh.getString("lid").toString();

    final response = await http.post(
      Uri.parse(url + "add_achievement/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": lid,
        "level_id": _selectedLevel,
        "cat_id": _selectedCategory,
        "exercise_id": _selectedExercise,
        "goals": _goalController.text,
        "date": DateTime.now().toIso8601String().split('T')[0]
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(jsonData['message'] ?? 'Saved'),
          backgroundColor: Colors.green,
        ),
      );
      _goalController.clear();
      setState(() {
        _selectedLevel = null;
        _selectedCategory = null;
        _selectedExercise = null;
        _categories = [];
        _exercises = [];
      });
    } else {
      final jsonData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${jsonData['message']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Achievement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Log Your Achievement',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Theme(
                        data: Theme.of(context).copyWith(
                          textTheme: Theme.of(context).textTheme.apply(
                            bodyColor: Colors.black,
                            displayColor: Colors.black,
                          ),
                        ),
                        child: DropdownButtonFormField<String?>(
                          value: _selectedLevel,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedLevel = newValue;
                              _categories = [];
                              _exercises = [];
                            });
                            if (newValue != null) fetchCategories(newValue);
                          },
                          items: _levels.isEmpty
                              ? [const DropdownMenuItem<String?>(value: null, child: Text('No levels available'))]
                              : _levels.map((level) {
                            return DropdownMenuItem(
                              value: level['level_id'].toString(),
                              child: Text(
                                level['lname'] ?? '',
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Select Level',
                            labelStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Theme(
                        data: Theme.of(context).copyWith(
                          textTheme: Theme.of(context).textTheme.apply(
                            bodyColor: Colors.black,
                            displayColor: Colors.black,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                              _exercises = [];
                            });
                            if (newValue != null) fetchExercises(newValue);
                          },
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category['category_id'].toString(),
                              child: Text(
                                category['cname'],
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Select Category',
                            labelStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Theme(
                        data: Theme.of(context).copyWith(
                          textTheme: Theme.of(context).textTheme.apply(
                            bodyColor: Colors.black,
                            displayColor: Colors.black,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedExercise,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedExercise = newValue;
                            });
                          },
                          items: _exercises.map((exercise) {
                            return DropdownMenuItem(
                              value: exercise['exercise_id'].toString(),
                              child: Text(
                                exercise['ename'],
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Select Exercise',
                            labelStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _goalController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Enter Achievement",
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: submitAchievement,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Submit Achievement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimary,
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
}
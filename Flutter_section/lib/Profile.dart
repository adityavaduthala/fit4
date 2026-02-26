import 'dart:convert';
import 'package:fit4/UserLog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<String> pid = <String>[];
  List<String> pname = <String>[];
  List<String> pAge = <String>[];
  List<String> pgender = <String>[];
  List<String> pheight = <String>[];
  List<String> pweight = <String>[];
  String healthStatus = "assets/Normal.jpg"; // Default image path
  List<Map<String, dynamic>> achievements = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
    fetchAchievements();
  }

  Future<void> load() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String ip = sh.getString("url").toString();
      String url = ip + "profile";  // Profile endpoint from Django backend
      var data = await http.post(
        Uri.parse(url),
        body: {},
      );

      var jsondata = jsonDecode(data.body);
      String status = jsondata['status'];
      if (status == "ok") {
        setState(() {
          pid.clear();
          pname.clear();
          pAge.clear();
          pgender.clear();
          pheight.clear();
          pweight.clear();

          var arr = jsondata['data'];
          for (int i = 0; i < arr.length; i++) {
            pid.add(arr[i]['pid'].toString());
            pname.add(arr[i]['pname'].toString());
            pAge.add(arr[i]['pAge'].toString());
            pgender.add(arr[i]['pgender'].toString());
            pheight.add(arr[i]['pheight'].toString());
            pweight.add(arr[i]['pweight'].toString());
          }
          determineHealthStatus(); // Determine health status based on data
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile data'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> fetchAchievements() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String ip = sh.getString("url").toString();
      var userId = sh.getString("lid").toString();

      String url = ip + "get_achievements";
      var data = await http.post(
        Uri.parse(url),
        body: {'user_id': userId},
      );

      var jsondata = jsonDecode(data.body);
      String status = jsondata['status'];
      if (status == "ok") {
        setState(() {
          achievements = List<Map<String, dynamic>>.from(jsondata['data']);
        });
      }
    } catch (e) {
      print("Error loading achievements: $e");
    }
  }

  void determineHealthStatus() {
    if (pweight.isNotEmpty && pheight.isNotEmpty) {
      double weight = double.tryParse(pweight[0]) ?? 0;
      double height = (double.tryParse(pheight[0]) ?? 0) / 100; // Convert cm to meters
      double bmi = weight / (height * height);

      setState(() {
        if (bmi < 18.5) {
          healthStatus = "assets/Underweight.jpg";
        } else if (bmi < 25) {
          healthStatus = "assets/Normal.jpg";
        } else if (bmi < 30) {
          healthStatus = "assets/Overweight.jpg";
        } else if (bmi < 35) {
          healthStatus = "assets/Obese.jpg";
        } else {
          healthStatus = "assets/Extremely Obese.jpg";
        }
      });
    }
  }

  Future<void> updateProfile() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String ip = sh.getString("url").toString();
      String lid = sh.getString("lid").toString();

      String url = ip + "update_profile";

      var data = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': lid,
          'name': nameController.text,
          'age': ageController.text,
          'height': heightController.text,
          'weight': weightController.text,
        }),
      );

      var jsondata = jsonDecode(data.body);
      String status = jsondata['status'];
      if (status == "ok") {
        // Update local state
        setState(() {
          pname[0] = nameController.text;
          pAge[0] = ageController.text;
          pheight[0] = heightController.text;
          pweight[0] = weightController.text;
          determineHealthStatus(); // Recalculate health status
        });

        // Close the dialog
        Navigator.pop(context);

        // Refresh the data
        await load();
        await fetchAchievements();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: pid.isEmpty
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          await load();
          await fetchAchievements();
        },
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                (MediaQuery.of(context).padding.top + kToolbarHeight),
          ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                // Profile hero card
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                healthStatus,
                                width: 140,
                                height: 140,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: showEditProfileDialog,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.primary.withOpacity(0.85),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        pname.isNotEmpty ? pname[0] : '—',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildStatCard('Age', pAge.isNotEmpty ? pAge[0] : '—', Icons.calendar_today_rounded),
                      _buildStatCard('Height', pheight.isNotEmpty ? '${pheight[0]} cm' : '—', Icons.height_rounded),
                      _buildStatCard('Weight', pweight.isNotEmpty ? '${pweight[0]} kg' : '—', Icons.monitor_weight_rounded),
                    ],
                  ),
                ),

                // Achievements card
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.emoji_events_rounded, color: Colors.amber.shade700, size: 26),
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              'Achievements',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      achievements.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                              child: Row(
                                children: [
                                  Icon(Icons.flag_rounded, size: 20, color: Colors.grey.shade400),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Log workouts to earn achievements',
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              itemCount: achievements.length,
                              itemBuilder: (context, index) {
                                var achievement = achievements[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.check_circle_rounded,
                                          color: Theme.of(context).colorScheme.primary,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              achievement['goals']?.toString() ?? 'Goal',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              achievement['date']?.toString() ?? '',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),

                // CTA
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UserLog()),
                        );
                      },
                      icon: const Icon(Icons.add_chart_rounded, size: 22),
                      label: const Text(
                        'Log achievement',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    final primary = Theme.of(context).colorScheme.primary;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: primary, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
  void showEditProfileDialog() {
    // Set initial values
    nameController.text = pname.isNotEmpty ? pname[0] : '';
    ageController.text = pAge.isNotEmpty ? pAge[0] : '';
    heightController.text = pheight.isNotEmpty ? pheight[0] : '';
    weightController.text = pweight.isNotEmpty ? pweight[0] : '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Edit Profile",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, 'Name', Icons.person),
                SizedBox(height: 16),
                _buildTextField(ageController, 'Age', Icons.calendar_today),
                SizedBox(height: 16),
                _buildTextField(heightController, 'Height (cm)', Icons.height),
                SizedBox(height: 16),
                _buildTextField(weightController, 'Weight (kg)', Icons.fitness_center),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                updateProfile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.black), // Add this to make text visible
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade700), // Add this for label color
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        // Add these to ensure hint and input text are visible
        hintStyle: TextStyle(color: Colors.grey.shade600),
        floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
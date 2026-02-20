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
  String healthStatus = "assets/normal.png"; // Default image path
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
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('My Profile', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: pid.isEmpty
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          await load();
          await fetchAchievements();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  healthStatus,
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.edit, color: Colors.white, size: 20),
                              ),
                              onPressed: showEditProfileDialog,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          pname.isNotEmpty ? pname[0] : '',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildStatCard('Age', '${pAge.isNotEmpty ? pAge[0] : ""}', Icons.calendar_today),
                      _buildStatCard('Height', '${pheight.isNotEmpty ? pheight[0] : ""} cm', Icons.height),
                      _buildStatCard('Weight', '${pweight.isNotEmpty ? pweight[0] : ""} kg', Icons.fitness_center),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Achievements',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Icon(Icons.emoji_events, color: Colors.amber),
                          ],
                        ),
                      ),
                      achievements.isEmpty
                          ? Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No achievements yet', style: TextStyle(color: Colors.grey)),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: achievements.length,
                        itemBuilder: (context, index) {
                          var achievement = achievements[index];
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.fitness_center,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              title: Text(
                                achievement['goals'],
                                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                              ),
                              subtitle: Text(
                                achievement['date'],
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserLog()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'User Log Entry',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
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
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                updateProfile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
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
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        // Add these to ensure hint and input text are visible
        hintStyle: TextStyle(color: Colors.grey.shade600),
        floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }
}
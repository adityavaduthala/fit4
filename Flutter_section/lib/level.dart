import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'category.dart';

class Level extends StatefulWidget {
  const Level({super.key});

  @override
  State<Level> createState() => _LevelState();
}

class _LevelState extends State<Level> {
  List<String> Lid = <String>[];
  List<String> Lname = <String>[];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String ip = sh.getString("url").toString();

      String url = ip + "Levels";
      var data = await http.post(
        Uri.parse(url),
        body: {},
      );

      var jsondata = jsonDecode(data.body);
      String status = jsondata['status'];
      if (status == "ok") {
        setState(() {
          Lid.clear();
          Lname.clear();
          var arr = jsondata['data'];
          for (int i = 0; i < arr.length; i++) {
            Lid.add(arr[i]['lid'].toString());
            Lname.add(arr[i]['lname'].toString());
          }
        });
      }
    } catch (e) {
      print("Error loading levels: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading levels'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Color(0xFF4CAF50), // Green
      Color(0xFF2196F3), // Blue
      Color(0xFFF44336), // Red
      Color(0xFF9C27B0), // Purple
      Color(0xFFFF9800), // Orange
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Fitness Levels',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Lid.isEmpty
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: load,
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
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: Lid.length,
            itemBuilder: (context, index) {
              final color = _getColorForIndex(index);
              return Container(
                margin: EdgeInsets.only(bottom: 16),
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Category(lid: Lid[index]),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Level Circle with First Letter of Name
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withOpacity(0.1),
                            ),
                            child: Center(
                              child: Text(
                                Lname[index][0].toUpperCase(),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          // Level Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Lname[index],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tap to explore exercises',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Arrow Icon
                          Icon(
                            Icons.arrow_forward_ios,
                            color: color,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

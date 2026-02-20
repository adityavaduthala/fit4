import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class achievements extends StatefulWidget {
  const achievements({super.key});

  @override
  State<achievements> createState() => _achievementsState();
}

class _achievementsState extends State<achievements> {

  List<String> aid = <String>[];
  List<String> acompelete = <String>[];
  List<String> exercise_id = <String>[];
  List<String> user_id = <String>[];

  @override
  void initState() {
    super.initState();
    load();
  }
  Future<void> load() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String ip = sh.getString("url").toString();

      String url = ip + "achievement";
      var data = await http.post(
        Uri.parse(url),
        body: {},
      );

      var jsondata = jsonDecode(data.body);
      String status = jsondata['status'];
      if (status == "ok") {
        var arr = jsondata['data'];
        for (int i = 0; i < arr.length; i++) {
          aid.add(arr[i]['ach_id'].toString());
          acompelete.add(arr[i]['completed_date'].toString());
          exercise_id.add(arr[i]['exercise_id'].toString());
          user_id.add(arr[i]['user_id'].toString());
        }
        setState(() {}); // Refresh the UI
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
      ),
      body: aid.isEmpty
          ? Center(
        child: CircularProgressIndicator(), // Show loader while data is loading
      )
          : ListView.builder(
        itemCount: aid.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Text(
                  aid[index],
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onTap: () {
                // // Navigate to ExercisePage
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ExercisePage()),
                // );
              },
              title: Text(
                acompelete[index],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  Text(" Ach"
                      ""
                      " Id: ${aid[index]}"),
                  Text(" Exercise : ${exercise_id[index]}"),
                  Text(" User : ${user_id[index]}"),
                ],
              ),

            ),
          );
        },
      ),
    );
  }
}


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
    setState(() {
      aid.clear();
      acompelete.clear();
      exercise_id.clear();
      user_id.clear();
    });
    try {
      final sh = await SharedPreferences.getInstance();
      String ip = sh.getString("url").toString();
      String url = ip + "achievement";
      var data = await http.post(Uri.parse(url), body: {});
      var jsondata = jsonDecode(data.body);
      String status = jsondata['status'];
      if (status == "ok") {
        var arr = jsondata['data'];
        setState(() {
          for (int i = 0; i < arr.length; i++) {
            aid.add(arr[i]['ach_id'].toString());
            acompelete.add(arr[i]['completed_date'].toString());
            exercise_id.add(arr[i]['exercise_id'].toString());
            user_id.add(arr[i]['user_id'].toString());
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading achievements: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Achievements',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: aid.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_outlined, size: 72, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No achievements yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primary.withOpacity(0.08), Colors.white],
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: aid.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: primary.withOpacity(0.2),
                        child: Icon(Icons.check_circle_rounded, color: primary),
                      ),
                      title: Text(
                        acompelete[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Achievement #${aid[index]} · Exercise: ${exercise_id[index]}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}


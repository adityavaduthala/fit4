import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExercisePage extends StatefulWidget {
  final String cid;
  const ExercisePage({Key? key, required this.cid}) : super(key: key);

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  List<String> eid = <String>[];
  List<String> ename = <String>[];
  List<String> eformat = <String>[];
  List<String> efile = <String>[];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String ip = sh.getString("url").toString();
      String url = ip + "exercises";
      var data = await http.post(
        Uri.parse(url),
        body: {'cid': widget.cid},
      );

      var jsondata = jsonDecode(data.body);
      if (jsondata['status'] == "ok") {
        var arr = jsondata['data'];
        setState(() {
          for (var exercise in arr) {
            eid.add(exercise['Exercise_id'].toString());
            ename.add(exercise['Ename'].toString());
            eformat.add(exercise['Format_details'].toString());
            efile.add(exercise['file'].toString());
          }
        });
      }
    } catch (e) {
      print(e.toString());
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
          'Exercises - Level ${widget.cid}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
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
        child: eid.isEmpty
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: load,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: eid.length,
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
                          builder: (context) => DetailPage(
                            ename: ename[index],
                            eformat: eformat[index],
                            efile: efile[index],
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withOpacity(0.1),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.fitness_center,
                                color: color,
                                size: 30,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ename[index],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Exercise ID: ${eid[index]}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class DetailPage extends StatefulWidget {
  final String ename;
  final String eformat;
  final String efile;

  const DetailPage({
    Key? key,
    required this.ename,
    required this.eformat,
    required this.efile,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _timeElapsed = '00:00:00';
  String? _imageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(Duration(seconds: 1), _updateTime);
    _loadImageUrl();
  }

  void _loadImageUrl() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String ip = sh.getString("url").toString();
      setState(() {
        _imageUrl = ip + "/static/" + widget.efile;
        _isLoading = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateTime(Timer timer) {
    if (_stopwatch.isRunning) {
      setState(() {
        _timeElapsed = _stopwatch.elapsed.toString().split('.').first;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          widget.ename,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
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
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Exercise Details',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              widget.eformat,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: Text(
                                _timeElapsed,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _stopwatch.stop();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Complete Exercise',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
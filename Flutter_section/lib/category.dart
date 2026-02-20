import 'dart:async';
import 'dart:convert';
import 'package:fit4/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fit4/exercise.dart';

class Category extends StatefulWidget {
  final String lid;
  const Category({Key? key, required this.lid}) : super(key: key);

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  List<String> Cid = <String>[];
  List<String> Cname = <String>[];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String ip = sh.getString("url").toString();

      String url = "$ip/categorys";
      var data = await http.post(
        Uri.parse(url),
        body: {'lid': widget.lid},
      );

      var jsondata = jsonDecode(data.body);
      String status = jsondata['status'];
      if (status == "ok") {
        var arr = jsondata['data'];
        setState(() {
          Cid.clear();
          Cname.clear();
          for (int i = 0; i < arr.length; i++) {
            Cid.add(arr[i]['Cid'].toString());
            Cname.add(arr[i]['Cname'].toString());
          }
        });
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading categories'),
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

  void _startSession(String cid) async {
    try {
      final sh = await SharedPreferences.getInstance();
      String ip = sh.getString("url").toString();
      String url = "$ip/exercises";
      var data = await http.post(
        Uri.parse(url),
        body: {'cid': cid},
      );

      var jsondata = jsonDecode(data.body);
      if (jsondata['status'] == "ok") {
        var arr = jsondata['data'];
        List<Map<String, String>> exercises = [];
        for (var exercise in arr) {
          exercises.add({
            'ename': exercise['Ename'].toString(),
            'eformat': exercise['Format_details'].toString(),
            'efile': exercise['file'].toString(),
          });
        }

        if (exercises.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseSessionPage(
                exercises: exercises,
                cid: cid,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Fitness Categories',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Cid.isEmpty
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
            itemCount: Cid.length,
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
                          builder: (context) => ExercisePage(cid: Cid[index]),
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
                              child: Text(
                                Cname[index][0].toUpperCase(),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Cname[index],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Category ID: ${Cid[index]}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _startSession(Cid[index]),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Start',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

class ExerciseSessionPage extends StatefulWidget {
  final List<Map<String, String>> exercises;
  final String cid;

  const ExerciseSessionPage({
    Key? key,
    required this.exercises,
    required this.cid,
  }) : super(key: key);

  @override
  _ExerciseSessionPageState createState() => _ExerciseSessionPageState();
}

class _ExerciseSessionPageState extends State<ExerciseSessionPage> {
  int _currentExerciseIndex = 0;
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _timeElapsed = '00:00:00';

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _startStopwatch();
  }

  void _startStopwatch() {
    _stopwatch.start();
    _timer = Timer.periodic(Duration(seconds: 1), _updateTime);
  }

  void _updateTime(Timer timer) {
    if (_stopwatch.isRunning) {
      setState(() {
        _timeElapsed = _stopwatch.elapsed.toString().split('.').first;
      });
    }
  }

  void _nextExercise() {
    _stopwatch.reset();
    _stopwatch.start();

    if (_currentExerciseIndex < widget.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CompletionPage(),
        ),
      );
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
    final exercise = widget.exercises[_currentExerciseIndex];
    return ExerciseDetailPage(
      ename: exercise['ename']!,
      eformat: exercise['eformat']!,
      efile: exercise['efile']!,
      onNext: _nextExercise,
      stopwatch: _stopwatch,
      timeElapsed: _timeElapsed,
      totalExercises: widget.exercises.length,
      currentExerciseIndex: _currentExerciseIndex,
    );
  }
}

class ExerciseDetailPage extends StatefulWidget {
  final String ename;
  final String eformat;
  final String efile;
  final VoidCallback onNext;
  final Stopwatch stopwatch;
  final String timeElapsed;
  final int totalExercises;
  final int currentExerciseIndex;

  const ExerciseDetailPage({
    Key? key,
    required this.ename,
    required this.eformat,
    required this.efile,
    required this.onNext,
    required this.stopwatch,
    required this.timeElapsed,
    required this.totalExercises,
    required this.currentExerciseIndex,
  }) : super(key: key);

  @override
  _ExerciseDetailPageState createState() => _ExerciseDetailPageState();
}
class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  String? _imageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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

  void _resetTimer() {
    setState(() {
      widget.stopwatch.reset();
    });
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
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
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: (widget.currentExerciseIndex + 1) /
                          widget.totalExercises,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Exercise ${widget.currentExerciseIndex + 1}/${widget.totalExercises}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exercise Image
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
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
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Exercise Details Card
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
                                widget.ename,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
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
                                  widget.timeElapsed,
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
              ),

              // Bottom buttons
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _resetTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Reset Timer',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Next Exercise',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}

class CompletionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Workout Complete',
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
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You have completed your workout session',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to your registration or sign-up screen here
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Home()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Return to Home',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
}
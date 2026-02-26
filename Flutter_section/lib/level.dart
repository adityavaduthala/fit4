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
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final sh = await SharedPreferences.getInstance();
      String baseUrl = sh.getString("url") ?? "";
      if (baseUrl.isEmpty) {
        _setLoadedError();
        return;
      }
      if (!baseUrl.endsWith('/')) baseUrl += '/';

      // Prefer GET get_levels/ (same as UserLog); fallback to POST Levels
      http.Response response;
      try {
        response = await http.get(Uri.parse(baseUrl + 'get_levels/'));
      } catch (_) {
        response = await http.post(Uri.parse(baseUrl + "Levels"), body: {});
      }

      if (!mounted) return;
      var jsondata = jsonDecode(response.body) as Map<String, dynamic>?;
      if (jsondata == null) {
        _setLoadedError();
        return;
      }

      // Accept both {"data": [...]} and {"status":"ok","data": [...]}
      Object? dataRaw = jsondata['data'] ?? jsondata['Data'];
      List<dynamic> arr = [];
      if (dataRaw is List) {
        arr = dataRaw;
      }

      String status =
          (jsondata['status'] ?? jsondata['Status'] ?? '').toString();
      setState(() {
        Lid.clear();
        Lname.clear();
        _loading = false;
        _error = false;
        for (int i = 0; i < arr.length; i++) {
          Map<String, dynamic> item = {};
          if (arr[i] is Map) {
            item = Map<String, dynamic>.from(arr[i] as Map);
          }
          Object? id = item['lid'] ?? item['level_id'] ?? item['Lid'];
          Object? name = item['lname'] ?? item['Lname'];
          if (id != null && name != null) {
            Lid.add(id.toString());
            Lname.add(name.toString());
          }
        }
      });
    } catch (e) {
      _setLoadedError();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error loading levels: ${e.toString().split('\n').first}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _setLoadedError() {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = true;
    });
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Color(0xFF4CAF50), // Green
      Color(0xFF2196F3), // Blue
      Color(0xFFE91E63), // Pink
      Color(0xFF9C27B0), // Purple
      Color(0xFFFF9800), // Orange
    ];
    return colors[index % colors.length];
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon,
                      size: 56,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.7)),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(int index, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Category(lid: Lid[index]),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      Lname[index][0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Lname[index],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.touch_app_rounded,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Tap to explore categories',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.arrow_forward_rounded, color: color, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Fitness Levels',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? RefreshIndicator(
                  onRefresh: load,
                  child: _buildEmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Unable to load levels',
                    subtitle: 'Pull down to retry',
                  ),
                )
              : Lid.isEmpty
                  ? RefreshIndicator(
                      onRefresh: load,
                      child: _buildEmptyState(
                        icon: Icons.fitness_center_rounded,
                        title: 'No levels yet',
                        subtitle: 'Check back later or pull to refresh',
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: load,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.06),
                              Colors.white,
                            ],
                          ),
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            20,
                            16,
                            MediaQuery.of(context).padding.bottom +
                                kBottomNavigationBarHeight +
                                24,
                          ),
                          itemCount: Lid.length,
                          itemBuilder: (context, index) {
                            final color = _getColorForIndex(index);
                            return _buildLevelCard(index, color);
                          },
                        ),
                      ),
                    ),
    );
  }
}

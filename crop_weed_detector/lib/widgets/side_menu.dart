import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SideMenu extends StatefulWidget {
  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String _username = "User"; // Default username
  List<Map<String, dynamic>> _history = []; // User history

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _fetchHistory();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("username") ?? "User"; // Load stored username
    });
  }

  Future<void> _fetchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if (token == null) return;

    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/history"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _history = List<Map<String, dynamic>>.from(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.greenAccent),
            accountName: Text(
              _username,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: null,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _history.isEmpty
                ? Center(child: Text("No history available"))
                : ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final record = _history[index];
                      return ListTile(
                        leading: Icon(Icons.image, color: Colors.black),
                        title: Text(record['summary'] ?? "Unknown"),
                        subtitle: Text("Model: ${record['model_chosen']}, Crop: ${record['crop_name']}"),
                        onTap: () {
                          // Implement navigation to detailed view
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "App Version 1.0.0",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

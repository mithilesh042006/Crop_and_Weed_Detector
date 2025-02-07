import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import '../screens/home_screen.dart';
import '../screens/tips_screen.dart';
import '../screens/diseases_screen.dart';
import '../screens/news_screen.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;
  final List<Widget> _screens = [HomeScreen(), TipsScreen(), DiseasesScreen(), NewsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        showElevation: true,
        onItemSelected: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavyBarItem(icon: Icon(Icons.home), title: Text("Home"), activeColor: Colors.blue),
          BottomNavyBarItem(icon: Icon(Icons.eco), title: Text("Tips"), activeColor: Colors.green),
          BottomNavyBarItem(icon: Icon(Icons.local_florist), title: Text("Diseases"), activeColor: Colors.red),
          BottomNavyBarItem(icon: Icon(Icons.article), title: Text("News"), activeColor: Colors.orange),
        ],
      ),
    );
  }
}

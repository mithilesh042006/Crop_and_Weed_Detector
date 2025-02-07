import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/tips_screen.dart';
import 'screens/diseases_screen.dart';
import 'screens/news_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavBar(), // ✅ Now this is the main layout
    );
  }
}

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    TipsScreen(),
    DiseasesScreen(),
    NewsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black, // ✅ Dark background for visibility
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: "Tips"),
          BottomNavigationBarItem(icon: Icon(Icons.local_florist), label: "Diseases"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "News"),
        ],
      ),
    );
  }
}

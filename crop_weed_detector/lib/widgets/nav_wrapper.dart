import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/tips_screen.dart';
import '../screens/diseases_screen.dart';
import '../screens/news_screen.dart';
import 'side_menu.dart'; // ✅ Left Drawer
import 'profile_dropdown.dart'; // ✅ Profile Dropdown

class NavWrapper extends StatefulWidget {
  @override
  _NavWrapperState createState() => _NavWrapperState();
}

class _NavWrapperState extends State<NavWrapper> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    HomeScreen(),
    TipsScreen(),
    DiseasesScreen(),
    NewsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() { _selectedIndex = index; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenu(), // 📂 Left Drawer with Username & History
      appBar: AppBar(
        title: Text(
          "Crop & Weed Detector",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black), // 🔥 Three-line Menu Icon
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          ProfileDropdown(), // 👤 Profile Dropdown (Logout)
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white, // ✅ White background
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.black,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tips"), // 🔍 Replaces Tips Tab
          BottomNavigationBarItem(icon: Icon(Icons.local_florist), label: "Diseases"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "News"),
        ],
      ),
    );
  }
}

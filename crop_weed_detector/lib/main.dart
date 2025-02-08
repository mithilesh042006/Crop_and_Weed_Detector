import 'package:flutter/material.dart';
import 'package:rive/rive.dart'; // 🎬 Rive Animations
import 'screens/auth_screen.dart'; // 🔥 Login & Register Screen
import 'screens/home_screen.dart';
import 'screens/tips_screen.dart';
import 'screens/diseases_screen.dart';
import 'screens/news_screen.dart';
import 'widgets/side_menu.dart';
import 'widgets/profile_dropdown.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthScreen(), // ✅ Shows Login/Register first
    );
  }
}

class NavWrapper extends StatefulWidget {
  @override
  _NavWrapperState createState() => _NavWrapperState();
}

class _NavWrapperState extends State<NavWrapper> 
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // 🔥 Used to open drawer
  final List<Widget> _screens = [
    HomeScreen(),
    TipsScreen(),
    DiseasesScreen(),
    NewsScreen(),
  ];
  late RiveAnimationController _menuAnimation; // 🎬 Menu Button Animation Controller

  @override
  void initState() {
    super.initState();
    _menuAnimation = SimpleAnimation("open"); // 🎬 Default animation state
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenu(), // 📂 Left-side menu (Username & History)
      appBar: AppBar(
        title: Text(
          "Crop & Weed Detector",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white, // ✅ White Background for a Clean UI
        elevation: 0, // ✅ Removes AppBar Shadow
        leading: GestureDetector(
          onTap: () {
            _menuAnimation.isActive = !_menuAnimation.isActive;
            _scaffoldKey.currentState?.openDrawer();
          },
          child: RiveAnimation.asset(
            "assets/samples/ui/rive_app/rive/menu_button.riv", // 🎬 Three-Line Animated Icon
            controllers: [_menuAnimation],
            fit: BoxFit.cover,
          ),
        ),
        actions: [
          ProfileDropdown(), // 👤 Profile Icon with Dropdown
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
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: "Tips"), // ✅ Changed to "Tips"
          BottomNavigationBarItem(icon: Icon(Icons.local_florist), label: "Diseases"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "News"),
        ],
      ),
    );
  }
}

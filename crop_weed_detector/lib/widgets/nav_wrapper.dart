import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/home_screen.dart';
import '../screens/tips_screen.dart';
import '../screens/diseases_screen.dart';
import '../screens/news_screen.dart';
import 'side_menu.dart';
import 'profile_dropdown.dart';

// Import AppLocalizations
import 'package:crop_weed_detector/app_localizations.dart';

class NavWrapper extends StatefulWidget {
  const NavWrapper({Key? key}) : super(key: key);

  @override
  _NavWrapperState createState() => _NavWrapperState();
}

class _NavWrapperState extends State<NavWrapper> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _fadeController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TipsScreen(),
    const DiseasesScreen(),
    const NewsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _fadeController.reset();
      _fadeController.forward();
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    // Localizations reference
    final loc = AppLocalizations.of(context);

    // Titles for the app bar subtitle
    final List<String> localizedTitles = [
      loc?.translate('navWrapperHomeSubtitle') ?? "Home",
      loc?.translate('navWrapperTipsSubtitle') ?? "Tips & Tricks",
      loc?.translate('navWrapperDiseasesSubtitle') ?? "Crop Diseases",
      loc?.translate('navWrapperNewsSubtitle') ?? "News & Updates",
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const SideMenu(),
        appBar: _buildAppBar(loc, localizedTitles),
        body: FadeTransition(
          opacity: _fadeController,
          child: _screens[_selectedIndex],
        ),
        bottomNavigationBar: _buildBottomNav(loc),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    AppLocalizations? loc,
    List<String> localizedTitles,
  ) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc?.translate('navWrapperMainTitle') ?? "Crop & Weed Detector",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            localizedTitles[_selectedIndex],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: _buildMenuButton(),
      actions: const [
        ProfileDropdown(),
        SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black87),
        onPressed: () {
          HapticFeedback.mediumImpact();
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
    );
  }

  Widget _buildBottomNav(AppLocalizations? loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 20,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.white,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey[400],
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
              ),
              items: [
                _buildNavItem(
                  Icons.home_rounded,
                  loc?.translate('navHome') ?? "Home",
                  0,
                ),
                _buildNavItem(
                  Icons.lightbulb_outline,
                  loc?.translate('navTips') ?? "Tips",
                  1,
                ),
                _buildNavItem(
                  Icons.local_florist_rounded,
                  loc?.translate('navDiseases') ?? "Diseases",
                  2,
                ),
                _buildNavItem(
                  Icons.article_rounded,
                  loc?.translate('navNews') ?? "News",
                  3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 24,
        ),
      ),
      label: label,
    );
  }
}

// Custom page route animation
class CustomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomPageRoute({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

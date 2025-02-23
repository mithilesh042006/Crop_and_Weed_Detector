import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rive/rive.dart' as rive;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crop_weed_detector/app_localizations.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/tips_screen.dart';
import 'screens/diseases_screen.dart';
import 'screens/news_screen.dart';
import 'widgets/side_menu.dart';
import 'widgets/profile_dropdown.dart';

void main() {
  runApp(const MyApp());
}

/// A stateful MyApp to handle dynamic locale changes
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  /// Static helper so any widget can change the locale in-place:
  ///   MyApp.setLocale(context, Locale('hi'));
  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?._updateLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // default to English

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  /// Load language code from SharedPreferences
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLangCode = prefs.getString('languageCode');
    if (savedLangCode != null && savedLangCode.isNotEmpty) {
      setState(() {
        _locale = Locale(savedLangCode);
      });
    }
  }

  /// Update the locale in state and store in SharedPreferences
  Future<void> _updateLocale(Locale newLocale) async {
    setState(() {
      _locale = newLocale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', newLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// Use our dynamic locale
      locale: _locale,

      /// Set up localizations
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
        Locale('gu', ''),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale != null) {
          for (var supported in supportedLocales) {
            if (supported.languageCode == deviceLocale.languageCode) {
              return supported;
            }
          }
        }
        return supportedLocales.first; // fallback to en
      },

      /// Basic theme
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
        textTheme: GoogleFonts.poppinsTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      /// Keep AuthScreen as the starting screen
      home: const AuthScreen(),
    );
  }
}

/// After login, you navigate to NavWrapper
class NavWrapper extends StatefulWidget {
  const NavWrapper({Key? key}) : super(key: key);

  @override
  _NavWrapperState createState() => _NavWrapperState();
}

class _NavWrapperState extends State<NavWrapper>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late rive.RiveAnimationController _menuAnimation;
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
    _menuAnimation = rive.SimpleAnimation('open');
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..forward();
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
  }

  @override
  Widget build(BuildContext context) {
    /// Pull localized strings from AppLocalizations
    final loc = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideMenu(),
      appBar: AppBar(
        /// Localize the app bar title if you want
        title: Text(
          loc?.translate('appTitle') ?? "Crop & Weed Detector",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
          ),
          child: GestureDetector(
            onTap: () {
              _menuAnimation.isActive = !_menuAnimation.isActive;
              _scaffoldKey.currentState?.openDrawer();
            },
            child: rive.RiveAnimation.asset(
              "assets/samples/ui/rive_app/rive/menu_button.riv",
              controllers: [_menuAnimation],
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: const [
          /// Remove `const` so it can rebuild if it needs to localize anything
          ProfileDropdown(),
          SizedBox(width: 16),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Color(0xFFFAFAFA),
              ],
            ),
          ),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            /// Do NOT use `const` here so we can rebuild with new translations
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.black54,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
            ),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: [
              _buildNavItem(
                Icons.home_rounded,
                loc?.translate('bottomNavHome') ?? "Home",
              ),
              _buildNavItem(
                Icons.eco_rounded,
                loc?.translate('bottomNavTips') ?? "Tips",
              ),
              _buildNavItem(
                Icons.local_florist_rounded,
                loc?.translate('bottomNavDiseases') ?? "Diseases",
              ),
              _buildNavItem(
                Icons.article_rounded,
                loc?.translate('bottomNavNews') ?? "News",
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      /// No `const` here, we need dynamic strings
      icon: Icon(icon),
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0x1A4CAF50),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}

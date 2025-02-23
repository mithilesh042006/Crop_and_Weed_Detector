import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crop_weed_detector/screens/auth_screen.dart' hide ApiService;
import 'package:crop_weed_detector/services/api_service.dart';
import 'package:crop_weed_detector/app_localizations.dart'; 
// for AppLocalizations
import 'package:crop_weed_detector/main.dart'; 
// for MyApp.setLocale

class ProfileDropdown extends StatefulWidget {
  const ProfileDropdown({Key? key}) : super(key: key);

  @override
  _ProfileDropdownState createState() => _ProfileDropdownState();
}

class _ProfileDropdownState extends State<ProfileDropdown>
    with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  late AnimationController _animationController;
  late Animation<double> _rotateAnimation;
  String _username = "User";
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _loadUsername() async {
    try {
      String? username = await ApiService.getCurrentUsername();
      setState(() {
        _username = username ?? 'User';
      });
    } catch (e) {
      debugPrint('Error loading username: $e');
      setState(() {
        _username = 'User';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We reference "profileMenuTitle" from localizations for the tooltip
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: AnimatedBuilder(
        animation: _rotateAnimation,
        builder: (context, child) {
          return IconButton(
            icon: Transform.rotate(
              angle: _rotateAnimation.value * 3.14159,
              child: const Icon(Icons.person, size: 28),
            ),
            color: Colors.black87,
            onPressed: _toggleMenu,
            tooltip: AppLocalizations.of(context)
                    ?.translate('profileMenuTitle') ??
                'Profile Menu',
          );
        },
      ),
    );
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
        _showOverlay();
      } else {
        _animationController.reverse();
        _removeOverlay();
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          // close if tapped outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            top: offset.dy + size.height,
            right: 20,
            width: 250,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // User Info Section
                    _buildUserSection(context),
                    // Menu Items
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: AppLocalizations.of(context)
                              ?.translate('profileMyProfile') ??
                          'My Profile',
                      subtitle: AppLocalizations.of(context)
                              ?.translate('profileEditProfile') ??
                          'View and edit your profile',
                      onTap: () {
                        _toggleMenu();
                        // TODO: Navigate to profile
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: AppLocalizations.of(context)
                              ?.translate('profileSettings') ??
                          'Settings',
                      subtitle: AppLocalizations.of(context)
                              ?.translate('profileAppSettings') ??
                          'App preferences and settings',
                      onTap: () {
                        _toggleMenu();
                        // TODO: Navigate to settings
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: AppLocalizations.of(context)
                              ?.translate('profileHelpSupport') ??
                          'Help & Support',
                      subtitle: AppLocalizations.of(context)
                              ?.translate('profileHelpSubtitle') ??
                          'Get help and contact support',
                      onTap: () {
                        _toggleMenu();
                        // TODO: Navigate to help
                      },
                    ),
                    // Language Setting
                    _buildMenuItem(
                      icon: Icons.language,
                      title: AppLocalizations.of(context)
                              ?.translate('languageMenuTitle') ??
                          'Change Language',
                      subtitle: '',
                      onTap: () {
                        _toggleMenu();
                        _showLanguageDialog();
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: AppLocalizations.of(context)
                              ?.translate('profileLogout') ??
                          'Logout',
                      subtitle: AppLocalizations.of(context)
                              ?.translate('profileLogoutSubtitle') ??
                          'Sign out of your account',
                      onTap: () {
                        _toggleMenu();
                        _showLogoutDialog(context);
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build user section at top of dropdown
  Widget _buildUserSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context)
                          ?.translate('profileViewProfile') ??
                      'View Profile',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show a dialog with language choices
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)
                  ?.translate('languageDialogTitle') ??
              'Select Language',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _changeLanguage('en', dialogCtx),
              child: Text(
                AppLocalizations.of(context)
                        ?.translate('languageOptionEnglish') ??
                    'English',
              ),
            ),
            ElevatedButton(
              onPressed: () => _changeLanguage('hi', dialogCtx),
              child: Text(
                AppLocalizations.of(context)
                        ?.translate('languageOptionHindi') ??
                    'हिन्दी',
              ),
            ),
            ElevatedButton(
              onPressed: () => _changeLanguage('gu', dialogCtx),
              child: Text(
                AppLocalizations.of(context)
                        ?.translate('languageOptionGujarati') ??
                    'ગુજરાતી',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The missing link: call MyApp.setLocale(...) to change language immediately
  Future<void> _changeLanguage(String langCode, BuildContext dialogCtx) async {
    Navigator.pop(dialogCtx); // close the language dialog

    // Optionally store the preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', langCode);

    // IMMEDIATE update of the locale in MyApp
    MyApp.setLocale(context, Locale(langCode));
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          AppLocalizations.of(context)?.translate('profileLogout') ?? 'Logout',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)?.translate('profileLogoutSubtitle') ??
              'Sign out of your account',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)?.translate('profileLogout') ??
                  'Logout',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        debugPrint("=== Attempting to call clearLocalStorage() ===");
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        }

        // Clear local storage (SharedPreferences)
        await ApiService.clearLocalStorage();

        if (mounted) {
          Navigator.pop(context); // remove loading indicator
        }

        debugPrint("=== Attempting to navigate to AuthScreen... ===");

        // Navigate to AuthScreen, removing all previous routes
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
            (route) => false,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.translate('logoutSuccess') ??
                    'Successfully logged out',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // remove loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppLocalizations.of(context)?.translate('logoutError') ?? 'Error during logout:'} $e',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive ? Colors.redAccent : Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color:
                          isDestructive ? Colors.redAccent : Colors.grey[800],
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

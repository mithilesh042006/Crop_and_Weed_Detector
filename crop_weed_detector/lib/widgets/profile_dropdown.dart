import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crop_weed_detector/screens/auth_screen.dart'hide ApiService;
import 'package:crop_weed_detector/services/api_service.dart';

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
  final LayerLink _layerLink = LayerLink();
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
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.transparent,
              ),
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
                    Container(
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
                              _username.isNotEmpty
                                  ? _username[0].toUpperCase()
                                  : 'U',
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
                    ),

                    // Menu Items
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'My Profile',
                      subtitle: 'View and edit your profile',
                      onTap: () {
                        _toggleMenu();
                        // TODO: Navigate or handle accordingly
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      subtitle: 'App preferences and settings',
                      onTap: () {
                        _toggleMenu();
                        // TODO: Navigate or handle accordingly
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help and contact support',
                      onTap: () {
                        _toggleMenu();
                        // TODO: Navigate or handle accordingly
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
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

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Logout Confirmation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout? You\'ll need to sign in again '
          'to access your account.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        // (A) Debug print before clearing storage
        debugPrint("=== Attempting to call clearLocalStorage() ===");

        // Show a loading indicator
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Clear local storage (SharedPreferences)
        await ApiService.clearLocalStorage();

        // Remove the loading indicator
        if (mounted) {
          Navigator.pop(context);
        }

        // (B) Debug print before navigating
        debugPrint("=== Attempting to navigate to AuthScreen... ===");

        // Navigate to AuthScreen, removing all previous routes
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
            (route) => false,
          );
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully logged out'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Remove loading indicator if it's still up
        if (mounted) {
          Navigator.pop(context);
        }

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error during logout: $e'),
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
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
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
                      color: isDestructive ? Colors.redAccent : Colors.grey[800],
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

  @override
  Widget build(BuildContext context) {
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
            tooltip: 'Profile Menu',
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';
import 'package:crop_weed_detector/services/api_service.dart';
import '../widgets/nav_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // -------------------------------------------------
  // Optional: If you want to load the saved Base URL
  // from SharedPreferences on startup, you can do so
  // here. For demonstration, we'll just keep it simple.
  // -------------------------------------------------

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // _loadSavedBaseUrl(); // <-- Optionally load from SharedPreferences if you'd like
  }

  // Example method if you want to store the baseUrl in SharedPreferences
  // Future<void> _loadSavedBaseUrl() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? savedUrl = prefs.getString('baseUrl');
  //   if (savedUrl != null && savedUrl.isNotEmpty) {
  //     setState(() {
  //       ApiService.baseUrl = savedUrl;
  //     });
  //   }
  // }

  Future<void> _authenticate(bool isLogin) async {
    setState(() {
      _isLoading = true;
    });

    bool success = isLogin
        ? await ApiService.loginUser(
            _usernameController.text, _passwordController.text)
        : await ApiService.registerUser(
            _usernameController.text, _passwordController.text);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const NavWrapper()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(isLogin ? "Invalid credentials!" : "Registration failed!"),
        ),
      );
    }
  }

  // --------------------------------------
  // Show a dialog to update the base URL
  // --------------------------------------
  Future<void> _showBaseUrlDialog() async {
    // Pre-fill with the current baseUrl
    TextEditingController baseUrlController =
        TextEditingController(text: ApiService.baseUrl);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Update Base URL',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: baseUrlController,
            decoration: const InputDecoration(
              labelText: 'New Base URL',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String newUrl = baseUrlController.text.trim();
                if (newUrl.isNotEmpty) {
                  // Update in memory
                  setState(() {
                    ApiService.baseUrl = newUrl;
                  });

                  // Optionally store to SharedPreferences
                  // SharedPreferences prefs = await SharedPreferences.getInstance();
                  // await prefs.setString('baseUrl', newUrl);

                  Navigator.pop(context);

                  // Show a quick success message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Base URL updated to: $newUrl'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  // If user typed nothing
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid URL'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------
  // UI
  // --------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A FAB in the bottom-right corner to open the base URL dialog
      floatingActionButton: FloatingActionButton(
        onPressed: _showBaseUrlDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.link),
        tooltip: 'Change Base URL',
      ),
      backgroundColor: Colors.white, // Clean UI background
      body: Stack(
        children: [
          // Rive background animation
          const RiveAnimation.asset(
              "assets/samples/ui/rive_app/rive/shapes.riv"),
          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Sign In or Register to Continue",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),

                // TabBar container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white,
                    tabs: const [
                      Tab(text: "Login"),
                      Tab(text: "Register"),
                    ],
                  ),
                ),

                // Expand to let TabBarView fill space
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLoginForm(),
                      _buildRegisterForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Login Form UI
  Widget _buildLoginForm() {
    return _buildForm("Login", () => _authenticate(true));
  }

  // 🔹 Register Form UI
  Widget _buildRegisterForm() {
    return _buildForm("Register", () => _authenticate(false));
  }

  // 🔹 Reusable Form Widget
  Widget _buildForm(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTextField(_usernameController, "Username", Icons.person),
          const SizedBox(height: 20),
          _buildTextField(_passwordController, "Password", Icons.lock,
              obscureText: true),
          const SizedBox(height: 30),
          _isLoading
              ? const CircularProgressIndicator()
              : _buildAuthButton(label, onPressed),
        ],
      ),
    );
  }

  // 🔹 Reusable Text Field
  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    IconData icon, {
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // 🔹 Reusable Auth Button
  Widget _buildAuthButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black87,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      child: Text(text),
    );
  }
}

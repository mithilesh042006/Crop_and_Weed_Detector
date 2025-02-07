import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';
import 'package:crop_weed_detector/services/api_service.dart';
import '../widgets/nav_wrapper.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _authenticate(bool isLogin) async {
    setState(() {
      _isLoading = true;
    });

    bool success = isLogin
        ? await ApiService.loginUser(_usernameController.text, _passwordController.text)
        : await ApiService.registerUser(_usernameController.text, _passwordController.text);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NavWrapper()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isLogin ? "Invalid credentials!" : "Registration failed!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean UI
      body: Stack(
        children: [
          const RiveAnimation.asset("assets/samples/ui/rive_app/rive/shapes.riv"), // Background Animation
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Welcome", style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Sign In or Register to Continue", style: GoogleFonts.inter(fontSize: 16)),
                SizedBox(height: 30),

                // 🔹 TabBar for Login/Register
                Container(
                  decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(10)),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white,
                    tabs: [
                      Tab(text: "Login"),
                      Tab(text: "Register"),
                    ],
                  ),
                ),
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
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTextField(_usernameController, "Username", Icons.person),
          SizedBox(height: 20),
          _buildTextField(_passwordController, "Password", Icons.lock, obscureText: true),
          SizedBox(height: 30),
          _isLoading ? CircularProgressIndicator() : _buildAuthButton(label, onPressed),
        ],
      ),
    );
  }

  // 🔹 Reusable Text Field
  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, {bool obscureText = false}) {
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

  // 🔹 Reusable Button
  Widget _buildAuthButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crop_weed_detector/services/api_service.dart';
import '../widgets/nav_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

// Define peach color
const Color peachColor = Color(0xFFFFB6A3);
const Color darkPeachColor = Color(0xFFFF9B84);

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _passwordStrength = '';
  Color _strengthColor = Colors.grey;
  double _strengthPercent = 0.0;

  // Password requirement checks
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _passwordController.addListener(_checkPasswordStrength);
    _loadSavedBaseUrl();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUrl = prefs.getString('baseUrl');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      setState(() {
        ApiService.baseUrl = savedUrl;
      });
    }
  }
  void _checkPasswordStrength() {
    String password = _passwordController.text;
    
    setState(() {
      // Check individual requirements
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      // Calculate overall strength
      int strength = 0;
      if (_hasMinLength) strength++;
      if (_hasUppercase) strength++;
      if (_hasLowercase) strength++;
      if (_hasNumber) strength++;
      if (_hasSpecialChar) strength++;

      switch (strength) {
        case 0:
        case 1:
          _passwordStrength = 'Weak';
          _strengthColor = Colors.red;
          _strengthPercent = 0.2;
          break;
        case 2:
        case 3:
          _passwordStrength = 'Medium';
          _strengthColor = Colors.orange;
          _strengthPercent = 0.5;
          break;
        case 4:
        case 5:
          _passwordStrength = 'Strong';
          _strengthColor = Colors.green;
          _strengthPercent = 1.0;
          break;
      }
    });
  }

  bool _isPasswordValid() {
    return _hasMinLength && _hasUppercase && _hasLowercase && 
           _hasNumber && _hasSpecialChar;
  }

  Future<void> _authenticate(bool isLogin) async {
    if (!isLogin) {
      if (!_isPasswordValid()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please meet all password requirements!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      bool success = isLogin
          ? await ApiService.loginUser(_usernameController.text, _passwordController.text)
          : await ApiService.registerUser(_usernameController.text, _passwordController.text);

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const NavWrapper(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isLogin ? "Invalid credentials!" : "Registration failed!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  Future<void> _showBaseUrlDialog() async {
    TextEditingController baseUrlController = TextEditingController(text: ApiService.baseUrl);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Base URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: baseUrlController,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'Enter API base URL',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              String newUrl = baseUrlController.text.trim();
              if (newUrl.isNotEmpty) {
                setState(() => ApiService.baseUrl = newUrl);
                
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('baseUrl', newUrl);
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Base URL updated to: $newUrl'),
                      backgroundColor: peachColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: peachColor),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showBaseUrlDialog,
        backgroundColor: peachColor,
        child: const Icon(Icons.settings, color: Colors.white),
        tooltip: 'Update Base URL',
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset(
              'assets/loginbg.json',
              fit: BoxFit.cover,
              repeat: true,
              reverse: true,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      "Welcome Back",
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn().slideY(begin: -0.2),
                    const SizedBox(height: 10),
                    Text(
                      "Sign in to continue",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                indicator: BoxDecoration(
                                  color: peachColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.black54,
                                tabs: const [
                                  Tab(text: "LOGIN"),
                                  Tab(text: "REGISTER"),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 320, // Fixed height for both tabs
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildLoginForm(),
                                SingleChildScrollView(
                                  child: _buildRegisterForm(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).scale(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField(
            controller: _usernameController,
            hint: "Username",
            icon: Icons.person_outline,
          ).animate().slideX(),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _passwordController,
            hint: "Password",
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscurePassword,
            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
          ).animate().slideX(delay: 200.ms),
          const SizedBox(height: 30),
          _buildAuthButton("LOGIN", () => _authenticate(true)),
        ],
      ),
    );
  }
  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(
            controller: _usernameController,
            hint: "Username",
            icon: Icons.person_outline,
          ).animate().slideX(),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _passwordController,
            hint: "Password",
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscurePassword,
            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
          ).animate().slideX(delay: 200.ms),
          if (_passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildStrengthIndicator(),
          ],
          const SizedBox(height: 10),
          _buildPasswordRequirements(),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _confirmPasswordController,
            hint: "Confirm Password",
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscureConfirmPassword,
            onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ).animate().slideX(delay: 400.ms),
          const SizedBox(height: 30),
          _buildAuthButton("REGISTER", () => _authenticate(false)),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password Requirements:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          _buildRequirementRow('At least 8 characters', _hasMinLength),
          _buildRequirementRow('One uppercase letter (A-Z)', _hasUppercase),
          _buildRequirementRow('One lowercase letter (a-z)', _hasLowercase),
          _buildRequirementRow('One number (0-9)', _hasNumber),
          _buildRequirementRow('One special character (!@#\$%^&*(),.?":{}|<>)', _hasSpecialChar),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: isMet ? Colors.green : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isMet ? Colors.green : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && obscureText,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[600],
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildStrengthIndicator() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _strengthPercent,
          backgroundColor: Colors.grey[300],
          color: _strengthColor,
          minHeight: 5,
        ),
        const SizedBox(height: 5),
        Text(
          'Password Strength: $_passwordStrength',
          style: TextStyle(color: _strengthColor, fontSize: 12),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildAuthButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: peachColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
      ),
    ).animate().fadeIn(delay: 600.ms).scale();
  }
}

import 'package:test_eco/screens/Home/HomePage.dart';
import 'package:test_eco/services/AuthService.dart';
import 'package:flutter/material.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _rememberMe = false;

  Future<void> _handleLogin() async {
   final authService = AuthService();
  
  // Show a loading indicator here if you want!
  var response = await authService.login(
    _phoneController.text.trim(),
  );

  if (response != null && response.statusCode == 200) {
    // Success! Navigate to Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EcoBiteHomeScreen()),
    );
  } else {
    // Show an error message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login Failed. Please check your credentials.")),
    );
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Use SingleChildScrollView to prevent "keyboard squish" exception
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 80), // Replaced Spacers with fixed heights

              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Phone Input Field
              // Phone Input Field for Login
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Algeria Flag
                    Image.network(
                      'https://flagcdn.com/w40/dz.png',
                      width: 24,
                      errorBuilder: (context, error, stack) =>
                          const Icon(Icons.flag),
                    ),
                    const Icon(Icons.keyboard_arrow_down),
                    const SizedBox(width: 8),
                    const Text("(+213)",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: "0X XX XX XX XX", // Local Algerian format
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    activeColor: Colors.orange[800],
                    value: _rememberMe,
                    onChanged: (val) => setState(() => _rememberMe = val!),
                  ),
                  const Text("Remember me"),
                ],
              ),
              const SizedBox(height: 40),

              // SIGN IN BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Sign in",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),

              const SizedBox(height: 32),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Or sign in with")),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 32),

              // SOCIAL ICONS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon('assets/GoogleLogo.jpg'),
                  const SizedBox(width: 30),
                  _socialIcon('assets/facebook.jpg'),
                  const SizedBox(width: 30),
                  _socialIcon('assets/AppleLogo.jpg'),
                ],
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text("Register",
                        style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialIcon(String assetPath) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Image.asset(
        assetPath,
        width: 30,
        height: 30,
        errorBuilder: (context, error, stack) =>
            const Icon(Icons.broken_image, size: 30),
      ),
    );
  }
}

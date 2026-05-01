import 'package:test_eco/screens/login.dart';
import 'package:test_eco/services/AuthService.dart';
import 'package:flutter/material.dart';
import 'OTP.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _rememberMe = false;

  // Placeholder for Spring Boot API Integration
  Future<void> _handleRegister() async {
   final authService = AuthService();
  
  // Show a loading indicator here if you want!
  var response = await authService.register(
    _nameController.text,
    _emailController.text,
    _phoneController.text
  );

  if (response != null && response.statusCode == 200) {
    // Success! Navigate to OTP Verification
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OtpScreen(phoneNumber: _phoneController.text),
      ),
    );
  } else {
    // Show an error message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registration Failed. Please try again.")),
    );
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: SizedBox(
            // Use the full height of the screen to keep spacing consistent
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Phone Input
                _inputWrapper(Row(
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
                          hintText: "0X XX XX XX XX",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                )),

                const SizedBox(height: 16),

                // Email Input
                _inputWrapper(TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                    hintText: "Email",
                    border: InputBorder.none,
                  ),
                )),

                const SizedBox(height: 16),

                // Name Input
                _inputWrapper(TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                    hintText: "Full Name",
                    border: InputBorder.none,
                  ),
                )),

                const SizedBox(height: 16),

                // Remember Me
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (val) => setState(() => _rememberMe = val!),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    const Text("Remember me"),
                  ],
                ),

                const Spacer(flex: 2),

                // REGISTER BUTTON (FIXED)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                        _handleRegister, // Calls the function with navigation
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Register",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text("Or sign up with")),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // Social Icons
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

                const SizedBox(height: 32),

                // NAVIGATION LINK (FIXED TEXT)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text("Sign In",
                          style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputWrapper(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: child,
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
        width: 38,
        height: 38,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.error, size: 30, color: Colors.grey),
      ),
    );
  }
}

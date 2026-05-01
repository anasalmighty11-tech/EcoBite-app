import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'login.dart';

const Color primary500 = Color(0xFFFF6B4A);
const Color activeIndicator = Color(0xFFFF826C);
const Color neutral50 = Color(0xFFF9FAFB);

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:8080",
    headers: {
      'Authorization': 'Bearer YOUR_API_KEY_HERE',
    },
  ));

  bool _isError = false;
  bool _showResendNotification = false; // New variable for the notification
  Timer? _timer;
  int _start = 45;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _start = 45;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _canResend = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void _resendCode() {
    _startTimer();
    setState(() {
      _showResendNotification = true; // Show the green box
    });

    // Auto-hide the notification after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showResendNotification = false);
    });
  }

  String _maskPhoneNumber(String phone) {
    String localNumber = phone.replaceAll("+213", "");
    if (localNumber.length < 5) return phone;
    return "(+213) ${localNumber.substring(0, 2)} **** *${localNumber.substring(localNumber.length - 3)}";
  }

  Future<void> _verifyOtp() async {
    String otp = _controllers.map((e) => e.text).join();
    if (otp.length < 4) return;
    try {
      final response = await _dio.post(
        "/api/auth/verify-otp",
        data: {"phone": widget.phoneNumber, "code": otp},
      );
      if (response.statusCode == 200 && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isError = true);
      for (var c in _controllers) {
        c.clear();
      }
      FocusScope.of(context).previousFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // THE NOTIFICATION: This pushes text down instead of covering it
              if (_showResendNotification)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F8E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF27AE60),
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "New Verification Code Sent",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(
                  height: 50,
                ), // Normal spacing when no notification is visible

              Text(
                "Code has been send to ${_maskPhoneNumber(widget.phoneNumber)}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => _otpTextField(index)),
              ),

              if (_isError)
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    "Code Invalid",
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 32),
              const Text(
                "Didn't receive code?",
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "00 : ${_start.toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: _canResend ? _resendCode : null,
                child: Text(
                  "Resend Code",
                  style: TextStyle(
                    color: _canResend ? primary500 : Colors.grey[400],
                    fontWeight: FontWeight.w500,
                    decoration: _canResend
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(height: 80),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Verify",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Back to "),
                  GestureDetector(
                    onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: primary500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpTextField(int index) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: neutral50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3)
            FocusScope.of(context).nextFocus();
          else if (value.isEmpty && index > 0)
            FocusScope.of(context).previousFocus();
        },
        decoration: InputDecoration(
          counterText: "",
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _isError ? Colors.red : Colors.grey[200]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: activeIndicator, width: 2),
          ),
        ),
      ),
    );
  }
}

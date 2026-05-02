import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_eco/screens/Home/HomePage.dart';
import 'package:test_eco/screens/authentication/register.dart';

import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';


const Color primary500 = Color(0xFFFF6B4A);
const Color activeIndicator = Color(0xFFFF826C);
const Color neutral50 = Color(0xFFF9FAFB);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EcoBiteSplashScreen(),
    );
  }
}

class EcoBiteSplashScreen extends StatefulWidget {
  const EcoBiteSplashScreen({super.key});

  @override
  State<EcoBiteSplashScreen> createState() => _EcoBiteSplashScreenState();
}

class _EcoBiteSplashScreenState extends State<EcoBiteSplashScreen> {
  late VideoPlayerController _videoController;
  double _progressValue = 0.0;
  bool _showContent = false;
  bool _isWelcomeScreen = false;

  @override
  void initState() {
    super.initState();
    // 1. Hide the status bar for that clean look
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // 2. Initialize the video using your specific filename
    _videoController =
        VideoPlayerController.asset('assets/video_2026-04-25_12-41-26.mp4')
          ..initialize().then((_) {
            setState(
              () {},
            ); // Refresh once the video is ready in the background
          });

    _startLoading();
  }

  @override
  void dispose() {
    _videoController.dispose(); // Important: clean up memory
    super.dispose();
  }

  void _startLoading() {
    // Show logo after half a second
    Timer(const Duration(milliseconds: 500), () {
      setState(() => _showContent = true);
    });

    // Animate the progress bar
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_progressValue < 1.0) {
          _progressValue += 0.02;
        } else {
          timer.cancel();
          _transitionToWelcome();
        }
      });
    });
  }

  void _transitionToWelcome() {
    setState(() {
      _isWelcomeScreen = true;
      _videoController.play(); // Start the fruit stacking animation
    });

    // Stay on this video for exactly 4 seconds as requested
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: _isWelcomeScreen
            ? _buildWelcomeVideoScreen()
            : _buildLoadingScreen(),
      ),
    );
  }

  // --- NEW VIDEO SCREEN ---
  Widget _buildWelcomeVideoScreen() {
    return Container(
      key: const ValueKey('welcome'),
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _videoController.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover, // Ensures video fills the whole screen
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),

          // Text Overlay
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  "Welcome to",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const Text(
                  "ECO BITE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- THE ORIGINAL LOADING SCREEN (KEEP THIS) ---
  Widget _buildLoadingScreen() {
    return Container(
      key: const ValueKey('loading'),
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF084D0B)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          AnimatedOpacity(
            opacity: _showContent ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Image.asset('assets/logo3.png', height: 450),
          ),
          const Spacer(flex: 3),
          const Text(
            "As fast as lightning,\nas delicious as thunder!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: LinearProgressIndicator(
              value: _progressValue,
              backgroundColor: Colors.white10,
              color: const Color(0xFFA5D6A7),
              minHeight: 4,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isAnimating = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {'image': 'assets/step1.png'},
    {'image': 'assets/step2.png'},
    {'image': 'assets/step3.png'},
    {'image': 'assets/step4.png'},
  ];

  @override
  void initState() {
    super.initState();
    _hideSystemUI();
  }

  void _hideSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Extra insurance: Set the status bar to transparent in case it lingers
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // 2. Set the style (makes sure if it does show, it's transparent)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Image.asset(
                    _pages[index]['image']!,
                    height: 320, // Adjusted for Figma look
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => _buildIndicator(index),
            ),
          ),

          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildMainButton(),
                const SizedBox(height: 12),
                _buildSecondaryButton(),
              ],
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? activeIndicator : primary500.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildMainButton() {
    bool isLastPage = _currentPage == _pages.length - 1;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        onPressed: () async {
          if (_isAnimating) return;
          if (!isLastPage) {
            setState(() => _isAnimating = true);
            await _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            setState(() => _isAnimating = false);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EcoBiteHomeScreen(),
              ),
            );
          }
        },
        child: Text(
          isLastPage ? "Start enjoying" : "Next",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    bool isLastPage = _currentPage == _pages.length - 1;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: neutral50,
          side: const BorderSide(color: Colors.transparent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: () {
          if (!isLastPage) {
            // This jumps directly to the last page (Step 4)
            _pageController.animateToPage(
              _pages.length - 1,
              duration: const Duration(milliseconds: 600),
              curve: Curves.fastOutSlowIn,
            );
          } else {
            // 1. First, make sure you have imported the file at the top of main.dart:
            // import 'HomePage.dart';

            // 2. This replaces the print statement and actually moves the screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterScreen()),
            );
          }
        },
        child: Text(
          isLastPage ? "Login / Registration" : "Skip",
          style: const TextStyle(
            color: primary500,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const Color primary500 = Color(0xFFFF6B4A);
  static const Color neutral50 = Color(0xFFF9FAFB);

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  File? _imageFile;
  String? _selectedGender;
  PhoneNumber _number = PhoneNumber(isoCode: 'DZ');

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitProfileToBackend() async {
    final dio = Dio();

    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer YOUR_FRIENDS_API_KEY_HERE', // Put the key here
    };

    FormData formData = FormData.fromMap({
      "name": _nameController.text,
      "email": _emailController.text,
      "phone": _number.phoneNumber,
      "dob": _dobController.text,
      "gender": _selectedGender,
      "location": _locationController.text,
      if (_imageFile != null)
        "profile_image": await MultipartFile.fromFile(
          _imageFile!.path,
          filename: "avatar.jpg",
        ),
    });

    try {
      // 2. Change this to the real URL your friend gives you
      final response = await dio.post(
        "https://YOUR_FRIEND_SERVER_URL.com/api/profile",
        data: formData,
      );

      if (response.statusCode == 200) {
        // Success! Navigate home
      }
    } catch (e) {
      print("Connection failed: $e");
    }

    try {
      // Simulation of API Call
      // final response = await dio.post("https://api.friend.com/v1/profile", data: formData);

      print("Profile setup successful!");

      if (mounted) {
        // NAVIGATE TO HOME SCREEN
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const EcoBiteHomeScreen()),
          (route) => false, // Clears the stack so user can't go back to setup
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imageFile = File(image.path));
  }

  void _openMapPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(36.7538, 3.0588),
            zoom: 12,
          ),
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          onTap: (LatLng latLng) {
            setState(() {
              _locationController.text =
                  "${latLng.latitude}, ${latLng.longitude}";
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
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
        title: const Text(
          "Your Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 65,
                              backgroundColor: neutral50,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : null,
                              child: _imageFile == null
                                  ? Icon(
                                      Icons.person,
                                      size: 70,
                                      color: Colors.grey[300],
                                    )
                                  : null,
                            ),
                            const Positioned(
                              bottom: 0,
                              right: 5,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: primary500,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: neutral50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) =>
                            _number = number,
                        initialValue: _number,
                        textFieldController: _phoneController,
                        countries: const ['DZ'],
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          showFlags: true,
                        ),
                        inputDecoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Phone Number",
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildField(controller: _emailController, hint: "Email"),
                    _buildField(controller: _nameController, hint: "Full Name"),
                    _buildField(
                      controller: _dobController,
                      hint: "--/--/----",
                      suffix: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(
                            () => _dobController.text =
                                "${picked.day}/${picked.month}/${picked.year}",
                          );
                        }
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: neutral50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedGender,
                          hint: const Text("Gender"),
                          items: ["Male", "Female"]
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedGender = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _locationController,
                      hint: "Your Location",
                      suffix: Icons.location_on_outlined,
                      onSuffixTap: _openMapPicker,
                    ),
                    const Spacer(),
                    const SizedBox(height: 40),

                    // --- UPDATED BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _submitProfileToBackend,
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () => print("Skipped"),
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            color: primary500,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    IconData? suffix,
    bool readOnly = false,
    VoidCallback? onTap,
    VoidCallback? onSuffixTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: neutral50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          suffixIcon: suffix != null
              ? IconButton(
                  icon: Icon(suffix, color: Colors.grey),
                  onPressed: onSuffixTap ?? onTap,
                )
              : null,
        ),
      ),
    );
  }
}

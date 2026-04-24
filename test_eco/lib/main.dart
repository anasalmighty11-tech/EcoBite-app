import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  double _progressValue = 0.0;
  bool _showContent = false;
  bool _isWelcomeScreen = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startLoading();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _startLoading() {
    // 1. Brief delay before showing logo/text (Loading_Start -> Loading_Middle)
    Timer(const Duration(milliseconds: 500), () {
      setState(() => _showContent = true);
    });

    // 2. Animate the progress bar
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
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isWelcomeScreen = true);
        Timer(const Duration(milliseconds: 2500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: _isWelcomeScreen ? _buildWelcomeScreen() : _buildLoadingScreen(),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      key: const ValueKey('loading'),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFF084D0B)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          AnimatedOpacity(
            opacity: _showContent ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Column(
              children: [
                Image.asset('assets/logo3.png', height: 450),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const Spacer(flex: 3),
          AnimatedOpacity(
            opacity: _showContent ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "As fast as lightning,\nas delicious as thunder!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
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

  Widget _buildWelcomeScreen() {
    return Container(
      key: const ValueKey('welcome'),
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/welcome_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              child: const Column(
                children: [
                  Text(
                    "Welcome to",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    "ECO BITE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
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
            // TODO: Navigate to your Dashboard or Login page
            print("Navigate to Login");
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
            // This jumps directly to the last page (index 3)
            _pageController.animateToPage(
              _pages.length - 1,
              duration: const Duration(milliseconds: 600),
              curve: Curves.fastOutSlowIn,
            );
          } else {
            // This is the logic for when they are already on Step 4
            print("Navigate to Login / Registration Page");
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

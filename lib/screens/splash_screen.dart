/// File: splash_screen.dart
/// Fungsi: Screen splash yang ditampilkan saat loading aplikasi.
/// Memeriksa apakah pengguna sudah pernah menggunakan aplikasi untuk routing ke onboarding atau main screen.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function toggleTheme;

  const SplashScreen({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Tunggu animasi selesai, lalu navigasi
    Future.delayed(const Duration(milliseconds: 3000), () {
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    final savedDailyTarget = prefs.getInt('dailyTarget') ?? 2000;
    final userName = prefs.getString('userName') ?? "Sahabat";

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => seenOnboarding
              ? MainNavigationScreen(
                  dailyTarget: savedDailyTarget,
                  userName: userName,
                  toggleTheme: widget.toggleTheme,
                )
              : OnboardingScreen(
                  toggleTheme: widget.toggleTheme,
                  themeMode: widget.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0E21) : Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo dengan animasi Lottie
                SizedBox(
                  height: 200,
                  child: Lottie.network(
                    'https://lottie.host/95305007-6c3e-4363-8839-847206f65074/rYt9Q9G8Jk.json',
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.water_drop_rounded,
                        size: 120,
                        color: Color(0xFF4FABF5),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                // Text "AquaMate"
                Text(
                  'AquaMate',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                // Subtitle
                Text(
                  'Stay Hydrated, Stay Healthy',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

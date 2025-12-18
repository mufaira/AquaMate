/// File: my_app.dart
/// Fungsi: Widget utama aplikasi yang mengelola state global aplikasi.
/// Menangani tema (light/dark mode), onboarding flow, user preferences,
/// dan navigasi antar screen utama aplikasi.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aquamate/screens/main_navigation_screen.dart';
import 'package:aquamate/screens/onboarding_screen.dart';
import 'package:aquamate/screens/splash_screen.dart';
import 'theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = true;
  bool _seenOnboarding = false;
  int _savedDailyTarget = 2000;
  String _userName = "Sahabat";

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = (prefs.getBool('isDarkMode') ?? false)
          ? ThemeMode.dark
          : ThemeMode.light;
      _seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
      _savedDailyTarget = prefs.getInt('dailyTarget') ?? 2000;
      _userName = prefs.getString('userName') ?? "Sahabat";
      _isLoading = false;
    });
  }

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AquaMate - Water Tracker',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: SplashScreen(
          isDarkMode: _themeMode == ThemeMode.dark,
          toggleTheme: toggleTheme,
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaMate - Water Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: _seenOnboarding
          ? MainNavigationScreen(
              dailyTarget: _savedDailyTarget,
              userName: _userName,
              toggleTheme: toggleTheme,
            )
          : OnboardingScreen(
              toggleTheme: toggleTheme,
              themeMode: _themeMode,
            ),
    );
  }
}
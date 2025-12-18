/// File: onboarding_screen.dart
/// Fungsi: Screen onboarding yang menampilkan panduan awal aplikasi kepada pengguna baru.
/// Mengumpulkan informasi profil pengguna seperti nama, jenis kelamin, dan berat badan.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../services/storage_service.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final Function toggleTheme;
  final ThemeMode themeMode;

  const OnboardingScreen({
    super.key,
    required this.toggleTheme,
    required this.themeMode,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final StorageService _storage = StorageService();
  final TextEditingController _nameController = TextEditingController();
  
  String _name = "";
  String _gender = "Pria";
  double _weight = 60.0;
  
  int _step = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _storage.init();
  }

  Future<void> _finishOnboarding() async {
    if (_name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan isi nama Anda terlebih dahulu")),
      );
      return;
    }

    final target = (_weight * 31.6).round();

    await _storage.saveUserName(_name);
    await _storage.saveGender(_gender);
    await _storage.saveWeight(_weight);
    await _storage.saveDailyTarget(target);
    await _storage.saveSeenOnboarding(true);

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainNavigationScreen(
            dailyTarget: target,
            userName: _name,
            toggleTheme: widget.toggleTheme,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final totalSteps = 3;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDarkMode ? const Color(0xFF0A0E21) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _step > 0
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDarkMode ? Colors.white : const Color(0xFF4FABF5),
                ),
                onPressed: () {
                  if (_step > 0) {
                    _animationController.reset();
                    setState(() => _step--);
                    _animationController.forward();
                  }
                },
              )
            : null,
        actions: [
          if (_step == 0)
            IconButton(
              icon: Icon(
                widget.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: isDarkMode ? Colors.white : const Color(0xFF4FABF5),
              ),
              onPressed: () => widget.toggleTheme(),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalSteps, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _step == index ? 30 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _step >= index
                          ? const Color(0xFF4FABF5)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SingleChildScrollView(
                  child: _buildCurrentStepContent(isDarkMode),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FABF5), Color(0xFF6C63FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4FABF5).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      if (_step == 0 && _nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Nama tidak boleh kosong")),
                        );
                        return;
                      }
                      if (_step == 0) {
                        setState(() => _name = _nameController.text.trim());
                      }

                      if (_step < totalSteps - 1) {
                        _animationController.reset();
                        setState(() => _step++);
                        _animationController.forward();
                      } else {
                        _finishOnboarding();
                      }
                    },
                    child: Center(
                      child: Text(
                        _step < totalSteps - 1 ? "BERIKUTNYA" : "MULAI SEKARANG",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent(bool isDarkMode) {
    switch (_step) {
      case 0:
        return _buildNameInput(isDarkMode);
      case 1:
        return _buildGenderSelection(isDarkMode);
      case 2:
        return _buildWeightSelection(isDarkMode);
      default:
        return Container();
    }
  }

  Widget _buildNameInput(bool isDarkMode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 150,
          child: Lottie.network(
            'https://lottie.host/95305007-6c3e-4363-8839-847206f65074/rYt9Q9G8Jk.json',
            errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.water_drop_rounded, size: 100, color: Color(0xFF4FABF5)),
          ),
        ),
        const SizedBox(height: 30),
        Text("Selamat Datang!",
            style: GoogleFonts.poppins(
                fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A))),
        Text("Siapa nama panggilan Anda?",
            style: GoogleFonts.poppins(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(height: 40),
        TextField(
          controller: _nameController,
          style: GoogleFonts.poppins(fontSize: 22, color: isDarkMode ? Colors.white : Colors.black87),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: "Nama Anda",
            filled: true,
            fillColor: isDarkMode ? const Color(0xFF1E1E2D) : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection(bool isDarkMode) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text("Halo, ${_name.isNotEmpty ? _name : 'Sahabat'}!",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A))),
        Text("Apa jenis kelamin Anda?", style: GoogleFonts.poppins(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildGenderCard("Pria", Icons.male_rounded, isDarkMode),
            _buildGenderCard("Wanita", Icons.female_rounded, isDarkMode),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderCard(String label, IconData icon, bool isDarkMode) {
    final isSelected = _gender == label;
    // Warna pink untuk "Wanita", biru untuk "Pria"
    final Color selectedColor = label == "Wanita" ? const Color(0xFFFF69B4) : const Color(0xFF4FABF5);
    
    return GestureDetector(
      onTap: () => setState(() => _gender = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withOpacity(0.15) : isDarkMode ? const Color(0xFF1E1E2D) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? selectedColor : Colors.transparent, width: 2),
          boxShadow: isSelected ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            Icon(icon, size: 50, color: isSelected ? selectedColor : Colors.grey),
            const SizedBox(height: 15),
            Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? selectedColor : isDarkMode ? Colors.white : Colors.grey[700])),
            if (isSelected) ...[const SizedBox(height: 10), Icon(Icons.check_circle_rounded, color: selectedColor, size: 20)]
          ],
        ),
      ),
    );
  }

  Widget _buildWeightSelection(bool isDarkMode) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.monitor_weight_rounded, size: 100, color: Color(0xFF4FABF5)),
        const SizedBox(height: 30),
        Text("Berapa berat badan Anda?",
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A))),
        const SizedBox(height: 40),
        Container(
          width: 180, height: 180,
          decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF1E1E2D) : Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF4FABF5).withOpacity(0.2), blurRadius: 30, spreadRadius: 5)]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${_weight.toInt()}", style: GoogleFonts.poppins(fontSize: 56, fontWeight: FontWeight.bold, color: const Color(0xFF4FABF5))),
              Text("kg", style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Slider(value: _weight, min: 30, max: 150, divisions: 120, onChanged: (val) => setState(() => _weight = val)),
      ],
    );
  }
}
/// File: home_screen.dart
/// Fungsi: Screen utama aplikasi yang menampilkan progress asupan air harian.
/// Menampilkan kartu progress, pemilihan ukuran cangkir, animasi lottie,
/// dan pesan reminder yang disesuaikan dengan kondisi cuaca real-time.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import '../widgets/progress_card.dart';
import '../widgets/cup_selection.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  final int dailyTarget;
  final int currentIntake;
  final List<Map<String, dynamic>> history;
  final Function(int, Map<String, dynamic>) onAddWater;
  final String userName;

  const HomeScreen({
    super.key,
    required this.dailyTarget,
    required this.currentIntake,
    required this.history,
    required this.onAddWater,
    required this.userName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCupSize = 250;
  late WeatherService _weatherService;
  WeatherData? _weatherData;
  double _weatherAdjustment = 1.0;
  bool _isLoadingWeather = false;

  static final List<Map<String, dynamic>> cupOptions = [
    {'size': 150, 'icon': Icons.local_cafe_outlined},
    {'size': 200, 'icon': Icons.coffee_outlined},
    {'size': 250, 'icon': Icons.local_drink_outlined},
    {'size': 300, 'icon': Icons.local_bar_outlined},
    {'size': 400, 'icon': Icons.water_drop_outlined},
    {'size': 500, 'icon': Icons.check_box_outline_blank_rounded},
    {'size': 600, 'icon': Icons.sports_bar_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _weatherService = WeatherService();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    if (mounted) {
      setState(() => _isLoadingWeather = true);
    }

    try {
      // Dapatkan cuaca berdasarkan lokasi pengguna saat ini
      final weather = await _weatherService.getWeatherForCurrentLocation();

      if (weather != null && mounted) {
        setState(() {
          _weatherData = weather;
          _weatherAdjustment =
              _weatherService.calculateWeatherAdjustment(weather);
          _isLoadingWeather = false;
        });
      } else if (mounted) {
        // Fallback ke lokasi default jika tidak bisa mendapat lokasi
        _loadDefaultWeatherData();
      }
    } catch (e) {
      print('Error loading weather: $e');
      if (mounted) {
        _loadDefaultWeatherData();
      }
    }
  }

  Future<void> _loadDefaultWeatherData() async {
    try {
      // Fallback ke lokasi default (Jakarta)
      const double latitude = -6.2088;
      const double longitude = 106.8456;

      final weather = await _weatherService.getWeatherByCoordinates(
        latitude,
        longitude,
      );

      if (weather != null && mounted) {
        setState(() {
          _weatherData = weather;
          _weatherAdjustment =
              _weatherService.calculateWeatherAdjustment(weather);
          _isLoadingWeather = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingWeather = false);
      }
    } catch (e) {
      print('Error loading default weather: $e');
      if (mounted) {
        setState(() => _isLoadingWeather = false);
      }
    }
  }

  void _triggerAddWater() {
    // Cari icon dari cupOptions, jika tidak ada gunakan icon default untuk custom
    final iconData = cupOptions
        .firstWhere(
          (e) => e['size'] == _selectedCupSize,
          orElse: () => {'icon': Icons.water_drop_outlined},
        )['icon'];
    
    final entry = {
      'time': DateFormat('HH:mm').format(DateTime.now()),
      'amount': _selectedCupSize,
      'icon': iconData,
    };
    widget.onAddWater(_selectedCupSize, entry);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final double progressValue =
        (widget.currentIntake / widget.dailyTarget);
    final int percentage = (progressValue * 100).toInt().clamp(0, 999);
    final int remaining = max(0, widget.dailyTarget - widget.currentIntake);
    final bool isExceeded = widget.currentIntake > widget.dailyTarget;
    final int excess = widget.currentIntake - widget.dailyTarget;

    return SingleChildScrollView(
      child: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(25, 60, 25, 35),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4FABF5), Color(0xFF6C63FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Halo, ${widget.userName}!",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.95),
                          ),
                        ),
                        Text(
                          "Target: ${widget.dailyTarget} ml",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Lottie.network(
                        'https://lottie.host/95305007-6c3e-4363-8839-847206f65074/rYt9Q9G8Jk.json',
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.face, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Progress Card with Weather
                ProgressCard(
                  currentIntake: widget.currentIntake,
                  dailyTarget: widget.dailyTarget,
                  percentage: percentage,
                  remaining: remaining,
                  isExceeded: isExceeded,
                  excess: excess,
                  weatherData: _weatherData,
                  weatherAdjustment: _weatherAdjustment,
                ),
              ],
            ),
          ),

          // BODY
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pilih Cangkir",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.white
                            : const Color(0xFF1E3A8A),
                      ),
                    ),
                    const Icon(Icons.local_cafe_rounded, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 15),

                // Horizontal Cup List
                CupSelection(
                  cupOptions: cupOptions,
                  selectedCupSize: _selectedCupSize,
                  onCupSelected: (size) => setState(() => _selectedCupSize = size),
                  isDarkMode: isDarkMode,
                ),

                const SizedBox(height: 25),

                // Button Add
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _triggerAddWater,
                    borderRadius: BorderRadius.circular(20),
                    child: Ink(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4FABF5), Color(0xFF6C63FF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4FABF5).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_rounded,
                              color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            "Tambah $_selectedCupSize ml",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "Riwayat Hari Ini",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 15),

                widget.history.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            children: [
                              Opacity(
                                opacity: 0.5,
                                child: Icon(Icons.history_toggle_off_rounded,
                                    size: 60, color: Colors.grey),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Belum ada data minum.",
                                style: GoogleFonts.poppins(
                                    color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: widget.history.map((entry) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF1E1E2D)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4FABF5)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    entry['icon'],
                                    color: const Color(0xFF4FABF5),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${entry['amount']} ml",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        "Air Mineral",
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey[500],
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  entry['time'],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
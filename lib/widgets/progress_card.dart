/// File: progress_card.dart
/// Fungsi: Widget untuk menampilkan kartu progress asupan air harian.
/// Menampilkan persentase progress, target sisa, dan informasi cuaca dengan animasi.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/weather_service.dart';

class ProgressCard extends StatelessWidget {
  final int currentIntake;
  final int dailyTarget;
  final int percentage;
  final int remaining;
  final bool isExceeded;
  final int excess;
  final WeatherData? weatherData;
  final double weatherAdjustment;

  const ProgressCard({
    super.key,
    required this.currentIntake,
    required this.dailyTarget,
    required this.percentage,
    required this.remaining,
    this.isExceeded = false,
    this.excess = 0,
    this.weatherData,
    this.weatherAdjustment = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Progress Icon + Title + Weather Icon (jika ada)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: Colors.white),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Progress Harian",
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontSize: 12)),
                    Text(
                      "$currentIntake / $dailyTarget ml",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Weather info di kanan
              if (weatherData != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _getWeatherIcon(weatherData!.description),
                        const SizedBox(width: 4),
                        Text(
                          '${weatherData!.temperature.toStringAsFixed(1)}°C',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      weatherData!.description,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      '📍 ${weatherData!.cityName}',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 15),
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (currentIntake / dailyTarget).clamp(0.0, 1.0),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: isExceeded ? const Color(0xFF27AE60) : const Color(0xFFFF9F1C),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: (isExceeded ? const Color(0xFF27AE60) : const Color(0xFFFF9F1C))
                            .withOpacity(0.5),
                        blurRadius: 10,
                      )
                    ],
                  ),
                ),
              ),
              if (isExceeded)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(height: 15),
          // Status Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$percentage%${isExceeded ? " Terpenuhi ✓" : " Terpenuhi"}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (weatherData != null && weatherAdjustment != 1.0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: weatherAdjustment > 1.0
                        ? Colors.red.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    weatherAdjustment > 1.0
                        ? '+${((weatherAdjustment - 1.0) * 100).toStringAsFixed(0)}%'
                        : '${((weatherAdjustment - 1.0) * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: weatherAdjustment > 1.0
                          ? Colors.red.shade200
                          : Colors.green.shade200,
                    ),
                  ),
                )
              else
                Text(
                  isExceeded ? "Lebih: +$excess ml" : "Kurang: $remaining ml",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
          // Weather reminder (jika ada)
          if (weatherData != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                WeatherService().getWeatherReminder(weatherData!),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.85),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _getWeatherIcon(String description) {
    IconData icon;
    if (description.contains('Cloud')) {
      icon = Icons.cloud;
    } else if (description.contains('Rain')) {
      icon = Icons.cloud_queue;
    } else if (description.contains('Clear') || description.contains('Sunny')) {
      icon = Icons.wb_sunny;
    } else if (description.contains('Snow')) {
      icon = Icons.ac_unit;
    } else {
      icon = Icons.cloud;
    }
    return Icon(icon, color: Colors.white, size: 24);
  }
}
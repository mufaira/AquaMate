/// File: weather_card.dart
/// Fungsi: Widget untuk menampilkan kartu informasi cuaca dengan detail suhu, kelembaban, dan rekomendasi.
/// Menampilkan pengaruh cuaca terhadap adjustment target minum air pengguna.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/weather_service.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData weather;
  final double adjustmentMultiplier;
  final int originalDailyTarget;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.adjustmentMultiplier,
    required this.originalDailyTarget,
  });

  @override
  Widget build(BuildContext context) {
    final adjustedTarget = (originalDailyTarget * adjustmentMultiplier).toInt();
    final adjustmentPercent =
        ((adjustmentMultiplier - 1.0) * 100).toStringAsFixed(0);
    final weatherReminder =
        WeatherService().getWeatherReminder(weather);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Suhu & Icon + Info
          Row(
            children: [
              // Left: Suhu & Icon
              Column(
                children: [
                  Row(
                    children: [
                      _getWeatherIcon(weather.description),
                      const SizedBox(width: 8),
                      Text(
                        '${weather.temperature.toStringAsFixed(1)}°C',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    weather.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Right: Humidity & Feels Like
              Expanded(
                child: Column(
                  children: [
                    _buildWeatherDetailRow(
                      icon: Icons.opacity,
                      label: 'Kelembaban',
                      value: '${weather.humidity}%',
                    ),
                    const SizedBox(height: 6),
                    _buildWeatherDetailRow(
                      icon: Icons.thermostat,
                      label: 'Terasa',
                      value: '${weather.feelsLike.toStringAsFixed(1)}°C',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2: Reminder message - single line
          Text(
            weatherReminder,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Row 3: Target adjustment - compact
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Target: ',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  '$originalDailyTarget → $adjustedTarget ml',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: adjustmentMultiplier > 1.0
                        ? Colors.red.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    adjustmentMultiplier > 1.0
                        ? '+$adjustmentPercent%'
                        : '$adjustmentPercent%',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: adjustmentMultiplier > 1.0
                          ? Colors.red.shade200
                          : Colors.green.shade200,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
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

    return Icon(icon, color: Colors.white, size: 40);
  }
}

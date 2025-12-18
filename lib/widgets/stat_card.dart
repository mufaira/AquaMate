/// File: stat_card.dart
/// Fungsi: Widget untuk menampilkan kartu statistik dengan label dan nilai.
/// Digunakan untuk menampilkan berbagai metrik statistik di history screen.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatCard extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const StatCard({
    super.key,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 15),
              Text(label, style: GoogleFonts.poppins(fontSize: 14)),
            ],
          ),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF4FABF5), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
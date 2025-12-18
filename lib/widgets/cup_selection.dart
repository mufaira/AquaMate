/// File: cup_selection.dart
/// Fungsi: Widget untuk menampilkan pilihan ukuran cangkir/gelas air yang dapat dipilih pengguna.
/// Menampilkan berbagai opsi ukuran mulai dari 150ml hingga 600ml dengan ikon yang berbeda.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CupSelection extends StatelessWidget {
  final List<Map<String, dynamic>> cupOptions;
  final int selectedCupSize;
  final Function(int) onCupSelected;
  final bool isDarkMode;

  const CupSelection({
    super.key,
    required this.cupOptions,
    required this.selectedCupSize,
    required this.onCupSelected,
    required this.isDarkMode,
  });

  void _showCustomCupDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Custom Cangkir',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan jumlah ml yang diinginkan:',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: 350',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.water_drop_outlined),
                  suffixText: 'ml',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FABF5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value > 0 && value <= 10000) {
                  onCupSelected(value);
                  Navigator.pop(dialogContext);
                } else {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Masukkan nilai antara 1 - 10000 ml',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text(
                'Pilih',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Custom Cup Button - Paling Kiri
          GestureDetector(
            onTap: () => _showCustomCupDialog(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF1E1E2D)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
                border: Border.all(
                  color: const Color(0xFF4FABF5).withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF4FABF5),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Custom",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4FABF5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Predefined Cup Options
          ...cupOptions.map((size) {
            final isSelected = selectedCupSize == size['size'];
            return GestureDetector(
              onTap: () => onCupSelected(size['size']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4FABF5)
                      : isDarkMode
                          ? const Color(0xFF1E1E2D)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFF4FABF5).withOpacity(0.4)
                          : Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      size['icon'],
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF4FABF5),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${size['size']} ml",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
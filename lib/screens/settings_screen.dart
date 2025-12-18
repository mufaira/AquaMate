/// File: settings_screen.dart
/// Fungsi: Screen pengaturan untuk mengubah preferensi pengguna seperti target harian,
/// tema, nama pengguna, dan reset data. Juga menampilkan informasi bantuan aplikasi.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../app/my_app.dart';

class SettingsScreen extends StatefulWidget {
  final Function toggleTheme;
  final VoidCallback onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.toggleTheme,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();
  
  int _target = 2000;
  String _name = "Sahabat";
  String _gender = "Pria";
  double _weight = 60.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _storage.init();
    final target = await _storage.getDailyTarget();
    final name = await _storage.getUserName();
    final gender = await _storage.getGender();
    final weight = await _storage.getWeight();
    
    setState(() {
      _target = target;
      _name = name;
      _gender = gender;
      _weight = weight;
    });
  }

  Future<void> _recalculateTarget({double? newWeight}) async {
    double calcWeight = newWeight ?? _weight;
    int newTarget = (calcWeight * 31.6).round();
    
    await _storage.saveDailyTarget(newTarget);
    setState(() => _target = newTarget);
    widget.onSettingsChanged();
  }

  Future<void> _updateValue(String title, String key, bool isInt) async {
    final controller = TextEditingController(text: isInt ? _target.toString() : _weight.toInt().toString());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ubah $title"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(suffixText: isInt ? "ml" : "kg"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              if (isInt) {
                int val = int.tryParse(controller.text) ?? _target;
                await _storage.saveDailyTarget(val);
                setState(() => _target = val);
              } else {
                double val = double.tryParse(controller.text) ?? _weight;
                await _storage.saveWeight(val);
                setState(() => _weight = val);
                await _recalculateTarget(newWeight: val);
              }
              widget.onSettingsChanged();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  Future<void> _updateGender() async {
    await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Pilih Jenis Kelamin"),
        children: [
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: const Text("Pria"),
            onPressed: () async {
              await _storage.saveGender('Pria');
              setState(() => _gender = 'Pria');
              await _recalculateTarget();
              widget.onSettingsChanged();
              if (mounted) Navigator.pop(context);
            },
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: const Text("Wanita"),
            onPressed: () async {
              await _storage.saveGender('Wanita');
              setState(() => _gender = 'Wanita');
              await _recalculateTarget();
              widget.onSettingsChanged();
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Setel Ulang Data"),
        content: const Text("Tindakan ini akan menghapus semua riwayat minum dan profil Anda. Aplikasi akan kembali ke awal."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              showDialog(
                context: context, 
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator())
              );

              try {
                await _storage.clearAllData();
              } catch(e) {
                debugPrint("Error saat reset: $e");
              }
              
              if (mounted) {
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MyApp()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            child: const Text("Ya, Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1E1E2D) : Colors.white;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0E21) : const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4FABF5), Color(0xFF6C63FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pengaturan", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                      Text(_name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSettingsCard(
                    title: "Tampilan",
                    children: [
                      _buildTile(Icons.dark_mode_rounded, Colors.purple, "Tema Aplikasi", 
                        isDarkMode ? "Gelap" : "Terang", () => widget.toggleTheme()),
                    ],
                    color: cardColor,
                  ),
                  
                  const SizedBox(height: 20),

                  _buildSettingsCard(
                    title: "Data Pribadi",
                    children: [
                      _buildTile(Icons.wc, Colors.blue, "Jenis Kelamin", _gender, _updateGender),
                      _buildTile(Icons.monitor_weight_rounded, Colors.orange, "Berat Badan", "${_weight.toInt()} kg", 
                        () => _updateValue("Berat Badan", 'weight', false)),
                      _buildTile(Icons.water_drop, Colors.cyan, "Target Harian", "$_target ml", 
                        () => _updateValue("Target", 'dailyTarget', true)), 
                    ],
                    color: cardColor,
                  ),

                  const SizedBox(height: 20),

                  _buildSettingsCard(
                    title: "Reset Data",
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                        ),
                        title: Text("Setel Ulang Data", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.redAccent)),
                        subtitle: Text("Hapus semua data & mulai dari awal", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                        onTap: _resetData,
                      ),
                    ],
                    color: cardColor,
                  ),
                  
                  const SizedBox(height: 30),
                  Text("AquaMate v1.2.0", style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12)),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required String title, required List<Widget> children, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10),
          child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
        ),
        Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile(IconData icon, Color iconColor, String title, String value, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF4FABF5))),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}
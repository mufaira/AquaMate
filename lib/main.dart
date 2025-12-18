/// File: main.dart
/// Fungsi: Entry point aplikasi Water Reminder.
/// Menginisialisasi Flutter dan menjalankan aplikasi MyApp sebagai root widget.

import 'package:flutter/material.dart';
import 'app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
/// File: storage_service.dart
/// Fungsi: Service untuk mengelola penyimpanan data lokal menggunakan SharedPreferences.
/// Menyimpan dan mengambil data pengguna, preferensi, dan riwayat asupan air.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> _ensureInit() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Preferences
  Future<void> saveUserName(String name) async {
    await _ensureInit();
    await _prefs!.setString('userName', name);
  }

  Future<String> getUserName() async {
    await _ensureInit();
    return _prefs?.getString('userName') ?? "Sahabat";
  }

  Future<void> saveGender(String gender) async {
    await _ensureInit();
    await _prefs!.setString('gender', gender);
  }

  Future<String> getGender() async {
    await _ensureInit();
    return _prefs?.getString('gender') ?? "Pria";
  }

  Future<void> saveWeight(double weight) async {
    await _ensureInit();
    await _prefs!.setDouble('weight', weight);
  }

  Future<double> getWeight() async {
    await _ensureInit();
    return _prefs?.getDouble('weight') ?? 60.0;
  }

  Future<void> saveDailyTarget(int target) async {
    await _ensureInit();
    await _prefs!.setInt('dailyTarget', target);
  }

  Future<int> getDailyTarget() async {
    await _ensureInit();
    return _prefs?.getInt('dailyTarget') ?? 2000;
  }

  Future<void> saveSeenOnboarding(bool seen) async {
    await _ensureInit();
    await _prefs!.setBool('seenOnboarding', seen);
  }

  Future<bool> getSeenOnboarding() async {
    await _ensureInit();
    return _prefs?.getBool('seenOnboarding') ?? false;
  }

  Future<bool> getThemeMode() async {
    await _ensureInit();
    return _prefs?.getBool('isDarkMode') ?? false;
  }

  // Water Intake Data
  Future<void> saveCurrentIntake(int intake) async {
    await _ensureInit();
    await _prefs!.setInt('currentIntake', intake);
    debugPrint('💾 Saved currentIntake: $intake');
  }

  Future<int> getCurrentIntake() async {
    await _ensureInit();
    final value = _prefs?.getInt('currentIntake') ?? 0;
    debugPrint('📖 Loaded currentIntake: $value');
    return value;
  }

  Future<void> saveTodayHistory(List<Map<String, dynamic>> history) async {
    await _ensureInit();
    // Konversi icon ke string representation agar bisa di-serialize
    final historyToSave = history.map((e) {
      return {
        'time': e['time'],
        'amount': e['amount'],
        'iconName': _getIconName(e['icon']),
      };
    }).toList();
    final historyString = jsonEncode(historyToSave);
    await _prefs!.setString('history', historyString);
    debugPrint('💾 Saved history with ${history.length} entries');
  }

  Future<List<Map<String, dynamic>>> getTodayHistory() async {
    await _ensureInit();
    final historyString = _prefs?.getString('history');
    if (historyString == null) {
      debugPrint('📖 No history found');
      return [];
    }
    final List<dynamic> decoded = jsonDecode(historyString);
    final result = decoded.map((e) {
      final map = e as Map<String, dynamic>;
      return {
        'time': map['time'],
        'amount': map['amount'],
        'icon': _getIconFromName(map['iconName']),
      };
    }).toList();
    debugPrint('📖 Loaded history with ${result.length} entries');
    return result;
  }

  // Helper untuk convert icon ke string
  String _getIconName(IconData? icon) {
    if (icon == null) return 'water_drop_outlined';
    if (icon == Icons.local_cafe_outlined) return 'local_cafe_outlined';
    if (icon == Icons.coffee_outlined) return 'coffee_outlined';
    if (icon == Icons.local_drink_outlined) return 'local_drink_outlined';
    if (icon == Icons.local_bar_outlined) return 'local_bar_outlined';
    if (icon == Icons.water_drop_outlined) return 'water_drop_outlined';
    if (icon == Icons.check_box_outline_blank_rounded) return 'check_box_outline_blank_rounded';
    if (icon == Icons.sports_bar_outlined) return 'sports_bar_outlined';
    return 'water_drop_outlined';
  }

  // Helper untuk convert string ke icon
  IconData _getIconFromName(String? name) {
    switch (name) {
      case 'local_cafe_outlined':
        return Icons.local_cafe_outlined;
      case 'coffee_outlined':
        return Icons.coffee_outlined;
      case 'local_drink_outlined':
        return Icons.local_drink_outlined;
      case 'local_bar_outlined':
        return Icons.local_bar_outlined;
      case 'water_drop_outlined':
        return Icons.water_drop_outlined;
      case 'check_box_outline_blank_rounded':
        return Icons.check_box_outline_blank_rounded;
      case 'sports_bar_outlined':
        return Icons.sports_bar_outlined;
      default:
        return Icons.water_drop_outlined;
    }
  }

  Future<void> saveLongTermHistory(Map<String, int> history) async {
    await _ensureInit();
    final historyString = jsonEncode(history);
    await _prefs!.setString('longTermHistory', historyString);
  }

  Future<Map<String, int>> getLongTermHistory() async {
    await _ensureInit();
    final historyString = _prefs?.getString('longTermHistory');
    if (historyString == null) return {};
    final Map<String, dynamic> decoded = jsonDecode(historyString);
    return decoded.map((key, value) => MapEntry(key, value as int));
  }

  Future<void> saveLastDate(String date) async {
    await _ensureInit();
    await _prefs!.setString('lastDate', date);
  }

  Future<String> getLastDate() async {
    await _ensureInit();
    return _prefs?.getString('lastDate') ?? "";
  }

  String getTodayDate() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> clearAllData() async {
    await _ensureInit();
    await _prefs!.clear();
  }
}
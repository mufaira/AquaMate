/// File: main_navigation_screen.dart
/// Fungsi: Screen navigasi utama yang mengelola bottom navigation bar.
/// Menyediakan akses ke Home, History, dan Settings screen dengan state management.

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../services/storage_service.dart';

class MainNavigationScreen extends StatefulWidget {
  final int dailyTarget;
  final String userName;
  final Function toggleTheme;

  const MainNavigationScreen({
    super.key,
    required this.dailyTarget,
    required this.userName,
    required this.toggleTheme,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver {
  final StorageService _storage = StorageService();
  int _currentIndex = 0;
  int _currentIntake = 0;
  int _currentDailyTarget = 2000;
  String _currentUserName = "Sahabat";
  List<Map<String, dynamic>> _todayHistory = [];
  Map<String, int> _longTermHistory = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _storage.init();
    _currentDailyTarget = widget.dailyTarget;
    _currentUserName = widget.userName;
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔄 App resumed - reloading data');
      _loadData();
    } else if (state == AppLifecycleState.paused) {
      debugPrint('⏸️ App paused - saving data');
      _saveAllData();
    } else if (state == AppLifecycleState.detached) {
      debugPrint('❌ App detached - final save');
      _saveAllData();
    }
  }

  Future<void> _saveAllData() async {
    try {
      final today = _storage.getTodayDate();
      await _storage.saveCurrentIntake(_currentIntake);
      await _storage.saveTodayHistory(_todayHistory);
      await _storage.saveLastDate(today);
      await _storage.saveLongTermHistory(_longTermHistory);
      debugPrint("✓ All data successfully saved");
    } catch (e) {
      debugPrint("❌ Error saving data: $e");
    }
  }

  Future<void> _refreshData() async {
    await _storage.init();
    setState(() {
      _currentDailyTarget = _storage.getTodayDate().length; // Will be updated below
      _currentUserName = "Sahabat"; // Will be updated below
    });
    _currentDailyTarget = await _storage.getDailyTarget();
    _currentUserName = await _storage.getUserName();
    await _loadData();
  }

  Future<void> _loadData() async {
    final today = _storage.getTodayDate();
    final lastSavedDate = await _storage.getLastDate();

    _currentDailyTarget = await _storage.getDailyTarget();
    _longTermHistory = await _storage.getLongTermHistory();

    if (lastSavedDate != today) {
      setState(() {
        _currentIntake = 0;
        _todayHistory = [];
      });
      await _storage.saveLastDate(today);
      await _storage.saveCurrentIntake(0);
      await _storage.saveTodayHistory([]);
    } else {
      final savedHistory = await _storage.getTodayHistory();
      final currentIntake = await _storage.getCurrentIntake();

      setState(() {
        _currentIntake = currentIntake;
        _todayHistory = savedHistory.map((e) {
          return {
            'time': e['time'],
            'amount': e['amount'],
            'icon': e['icon'],
          };
        }).toList();
      });
    }
  }

  Future<void> _addWater(int amount, Map<String, dynamic> logEntry) async {
    final today = _storage.getTodayDate();

    setState(() {
      _currentIntake += amount;
      _todayHistory.insert(0, logEntry);
      _longTermHistory[today] = _currentIntake;
    });

    // Simpan data immediately
    await _storage.saveCurrentIntake(_currentIntake);
    await _storage.saveTodayHistory(_todayHistory);
    await _storage.saveLastDate(today);
    await _storage.saveLongTermHistory(_longTermHistory);
    
    debugPrint("✓ Water added: +$amount ml, Total: $_currentIntake ml");
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      HomeScreen(
        dailyTarget: _currentDailyTarget,
        currentIntake: _currentIntake,
        history: _todayHistory,
        onAddWater: _addWater,
        userName: _currentUserName,
      ),
      HistoryScreen(
        dailyTarget: _currentDailyTarget,
        longTermHistory: _longTermHistory,
        todayIntake: _currentIntake,
      ),
      SettingsScreen(
        toggleTheme: widget.toggleTheme,
        onSettingsChanged: _refreshData,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF4FABF5),
        unselectedItemColor: Colors.grey,
        backgroundColor: isDarkMode ? const Color(0xFF1E1E2D) : Colors.white,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop_rounded),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: "Riwayat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: "Pengaturan",
          ),
        ],
      ),
    );
  }
}
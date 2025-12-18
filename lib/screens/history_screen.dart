/// File: history_screen.dart
/// Fungsi: Screen untuk menampilkan riwayat asupan air pengguna dalam jangka panjang.
/// Menampilkan statistik harian, grafik progress, dan analisis tren minum air.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/stat_card.dart';

class HistoryScreen extends StatefulWidget {
  final int dailyTarget;
  final Map<String, int> longTermHistory;
  final int todayIntake;

  const HistoryScreen({
    super.key,
    required this.dailyTarget,
    required this.longTermHistory,
    required this.todayIntake,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isYearView = false;
  DateTime _selectedDate = DateTime.now();

  Map<String, dynamic> _getChartData(Map<String, int> fullHistory, bool isYear) {
    if (!isYear) {
      int daysInMonth =
          DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);
      List<int> dailyData = List.filled(daysInMonth, 0);

      fullHistory.forEach((key, value) {
        DateTime date = DateTime.parse(key);
        if (date.month == _selectedDate.month &&
            date.year == _selectedDate.year) {
          dailyData[date.day - 1] = value;
        }
      });
      return {'data': dailyData, 'labels': ['1', '7', '14', '21', '28']};
    } else {
      List<int> monthlyData = List.filled(12, 0);
      fullHistory.forEach((key, value) {
        DateTime date = DateTime.parse(key);
        if (date.year == _selectedDate.year) {
          monthlyData[date.month - 1] += value;
        }
      });
      for (int i = 0; i < 12; i++) {
        int days = DateUtils.getDaysInMonth(_selectedDate.year, i + 1);
        monthlyData[i] = (monthlyData[i] / days).round();
      }

      return {
        'data': monthlyData,
        'labels': ['Jan', 'Mar', 'Mei', 'Jul', 'Sep', 'Nov']
      };
    }
  }

  Map<String, String> _calculateStatistics(Map<String, int> fullHistory) {
    double sumWeekly = 0;
    for (int i = 0; i < 7; i++) {
      DateTime d = DateTime.now().subtract(Duration(days: i));
      String key = DateFormat('yyyy-MM-dd').format(d);
      sumWeekly += fullHistory[key] ?? 0;
    }
    String weeklyAvg = "${(sumWeekly / 7).round()} ml / hari";

    double sumMonthly = 0;
    int daysPassed = DateTime.now().day;
    for (int i = 1; i <= daysPassed; i++) {
       String key = DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, i));
       sumMonthly += fullHistory[key] ?? 0;
    }
    String monthlyAvg = "${(sumMonthly / daysPassed).round()} ml / hari";

    double totalPercent = 0;
    int activeDays = 0;
    
    fullHistory.forEach((key, value) {
      DateTime d = DateTime.parse(key);
      if(d.month == DateTime.now().month && d.year == DateTime.now().year) {
          double p = (value / widget.dailyTarget).clamp(0.0, 1.0);
          totalPercent += p;
          activeDays++;
      }
    });
    
    String completionRate = activeDays > 0 
        ? "${((totalPercent / activeDays) * 100).round()} %" 
        : "0 %";

    double sumAll = 0;
    int countAll = 0;
    fullHistory.forEach((_, value) {
      if(value > 0) {
        sumAll += value;
        countAll++;
      }
    });
    String avgDailyConsumption = countAll > 0 
        ? "${(sumAll/countAll).round()} ml / hari" 
        : "0 ml / hari";

    return {
      'weekly': weeklyAvg,
      'monthly': monthlyAvg,
      'completion': completionRate,
      'avgDaily': avgDailyConsumption
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Map<String, int> displayHistory = Map.from(widget.longTermHistory);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    displayHistory[todayStr] = widget.todayIntake;

    final stats = _calculateStatistics(displayHistory);
    final chartData = _getChartData(displayHistory, _isYearView);
    final List<int> barValues = chartData['data'];
    final List<String> xAxisLabels = chartData['labels'];

    String headerTitle = _isYearView 
        ? "${_selectedDate.year}" 
        : DateFormat('MMMM yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0E21) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Riwayat"),
        backgroundColor: const Color(0xFF4FABF5),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFF4FABF5),
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 16),
                          onPressed: () {
                             setState(() {
                               if(_isYearView) {
                                 _selectedDate = DateTime(_selectedDate.year - 1);
                               } else {
                                 _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
                               }
                             });
                          },
                        ),
                        Text(
                          headerTitle,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                          onPressed: () {
                             setState(() {
                               if(_isYearView) {
                                 _selectedDate = DateTime(_selectedDate.year + 1);
                               } else {
                                 _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
                               }
                             });
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1E1E2D) : Colors.white,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text("100%", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  Text("75%", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  Text("50%", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  Text("25%", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  Text("0", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    double barWidth = (constraints.maxWidth / barValues.length) - (_isYearView ? 6 : 2);
                                     
                                    return Stack(
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: List.generate(5, (index) => Container(height: 1, color: Colors.grey.withOpacity(0.1))),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: barValues.map((val) {
                                            double percent = (val / widget.dailyTarget).clamp(0.0, 1.0);
                                            if(_isYearView) percent = (val / widget.dailyTarget).clamp(0.0, 1.0);

                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  width: barWidth > 0 ? barWidth : 5,
                                                  height: 180 * percent, 
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF4FABF5),
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: xAxisLabels.map((l) => Text(l, style: const TextStyle(fontSize: 10, color: Colors.grey))).toList(),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF4FABF5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _isYearView = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: !_isYearView ? const Color(0xFF4FABF5) : Colors.transparent,
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7)),
                                  ),
                                  child: Text("Bulan", style: GoogleFonts.poppins(color: !_isYearView ? Colors.white : const Color(0xFF4FABF5), fontWeight: FontWeight.bold)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _isYearView = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _isYearView ? const Color(0xFF4FABF5) : Colors.transparent,
                                    borderRadius: const BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6)),
                                  ),
                                  child: Text("Tahun", style: GoogleFonts.poppins(color: _isYearView ? Colors.white : const Color(0xFF4FABF5), fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                   colors: [Color(0xFF4FABF5), Color(0xFF6C63FF)],
                   begin: Alignment.topCenter,
                   end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Minggu Ini",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      DateTime now = DateTime.now();
                      DateTime date = now.subtract(Duration(days: now.weekday - 1)).add(Duration(days: index));
                      String dateKey = DateFormat('yyyy-MM-dd').format(date);
                      bool isDone = (displayHistory[dateKey] ?? 0) >= widget.dailyTarget;
                      List<String> days = ["Sen", "Sel", "Rab", "Kam", "jum", "Sab", "Min"];
                      
                      return Column(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: isDone ? const Color(0xFF4FABF5) : Colors.white.withOpacity(0.2), 
                              shape: BoxShape.circle,
                              border: isDone ? Border.all(color: Colors.white, width: 2) : null,
                            ),
                            child: isDone ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            days[index],
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                          )
                        ],
                      );
                    }),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              color: isDarkMode ? const Color(0xFF1E1E2D) : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Laporan air minum", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  StatCard(
                    color: Colors.green,
                    label: "Rata-rata mingguan",
                    value: stats['weekly']!,
                  ),
                  const Divider(),
                  StatCard(
                    color: Colors.blue,
                    label: "Rata-rata bulanan",
                    value: stats['monthly']!,
                  ),
                  const Divider(),
                  StatCard(
                    color: Colors.orange,
                    label: "Penyelesaian rata-rata",
                    value: stats['completion']!,
                  ),
                  const Divider(),
                  StatCard(
                    color: Colors.redAccent,
                    label: "Rata-rata Konsumsi",
                    value: stats['avgDaily']!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
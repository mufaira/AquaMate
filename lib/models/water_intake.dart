/// File: water_intake.dart
/// Fungsi: Model data untuk pencatatan asupan air yang berisi informasi
/// jumlah air yang diminum, waktu, ikon, dan catatan tambahan.

import 'package:intl/intl.dart';

class WaterIntake {
  final String id;
  final int amount;
  final DateTime time;
  final String icon;
  final String note;

  WaterIntake({
    required this.amount,
    required this.time,
    this.icon = 'local_drink_outlined',
    this.note = 'Air Mineral',
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  String get formattedTime => DateFormat('HH:mm').format(time);
  String get formattedDate => DateFormat('yyyy-MM-dd').format(time);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'time': time.toIso8601String(),
      'icon': icon,
      'note': note,
    };
  }

  factory WaterIntake.fromMap(Map<String, dynamic> map) {
    return WaterIntake(
      id: map['id'],
      amount: map['amount'],
      time: DateTime.parse(map['time']),
      icon: map['icon'] ?? 'local_drink_outlined',
      note: map['note'] ?? 'Air Mineral',
    );
  }
}
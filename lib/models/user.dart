/// File: user.dart
/// Fungsi: Model data untuk User yang menyimpan informasi profil pengguna.
/// Berisi data seperti nama, jenis kelamin, berat badan, dan target minum air harian.

import '../services/storage_service.dart';

class User {
  String name;
  String gender;
  double weight;
  int dailyTarget;

  User({
    required this.name,
    required this.gender,
    required this.weight,
    required this.dailyTarget,
  });

  static Future<User> fromStorage(StorageService storage) async {
    return User(
      name: await storage.getUserName(),
      gender: await storage.getGender(),
      weight: await storage.getWeight(),
      dailyTarget: await storage.getDailyTarget(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'weight': weight,
      'dailyTarget': dailyTarget,
    };
  }
}
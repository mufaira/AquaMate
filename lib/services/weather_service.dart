/// File: weather_service.dart
/// Fungsi: Service untuk mengambil data cuaca dari OpenWeatherMap API.
/// Menyesuaikan target minum air berdasarkan suhu, kelembaban, dan kondisi cuaca.
/// Menyediakan pesan reminder yang dinamis dan variatif sesuai kondisi cuaca.

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'location_service.dart';

class WeatherData {
  final double temperature;
  final String description;
  final int humidity;
  final double feelsLike;
  final int uvIndex;
  final String cityName;

  WeatherData({
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.feelsLike,
    required this.uvIndex,
    required this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['main'] as String,
      humidity: json['main']['humidity'] as int,
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      uvIndex: 0, // Default, akan diupdate dari API terpisah
      cityName: json['name'] as String? ?? 'Unknown Location',
    );
  }
}

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  // Ganti dengan API key Anda
  static const String apiKey = '829c69bdb9993a44fcdce2632e6131b7';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Ambil data cuaca berdasarkan lokasi pengguna saat ini
  Future<WeatherData?> getWeatherForCurrentLocation() async {
    try {
      // Dapatkan lokasi pengguna
      final position = await LocationService.getCurrentLocation();
      
      if (position == null) {
        print('Tidak bisa mendapatkan lokasi pengguna');
        return null;
      }

      // Ambil cuaca berdasarkan koordinat
      return await getWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      print('Error mendapatkan cuaca lokasi current: $e');
      return null;
    }
  }

  /// Ambil data cuaca berdasarkan koordinat (latitude, longitude)
  Future<WeatherData?> getWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url =
          '$baseUrl/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('timeout', 408),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(json);
      } else if (response.statusCode == 401) {
        print('Error: Invalid API Key');
      } else if (response.statusCode == 404) {
        print('Error: Location not found');
      }
      return null;
    } catch (e) {
      print('Weather Service Error: $e');
      return null;
    }
  }

  /// Ambil data cuaca berdasarkan nama kota
  Future<WeatherData?> getWeatherByCity(String cityName) async {
    try {
      final url =
          '$baseUrl/weather?q=$cityName&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('timeout', 408),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(json);
      } else if (response.statusCode == 401) {
        print('Error: Invalid API Key');
      } else if (response.statusCode == 404) {
        print('Error: City not found');
      }
      return null;
    } catch (e) {
      print('Weather Service Error: $e');
      return null;
    }
  }

  /// Kalkulasi adjusted daily target berdasarkan cuaca
  /// Return: multiplier untuk daily target (contoh: 1.2 = 20% lebih tinggi)
  double calculateWeatherAdjustment(WeatherData weather) {
    double adjustment = 1.0;

    // Adjustment berdasarkan suhu
    if (weather.temperature > 35) {
      adjustment += 0.30; // +30% untuk cuaca sangat panas
    } else if (weather.temperature > 30) {
      adjustment += 0.20; // +20% untuk cuaca panas
    } else if (weather.temperature > 25) {
      adjustment += 0.10; // +10% untuk cuaca hangat
    } else if (weather.temperature < 5) {
      adjustment -= 0.10; // -10% untuk cuaca dingin
    }

    // Adjustment berdasarkan kelembaban
    if (weather.humidity < 30) {
      adjustment += 0.15; // +15% untuk udara kering
    } else if (weather.humidity > 80) {
      adjustment -= 0.10; // -10% untuk udara sangat lembab
    }

    // Clamp antara 0.7 dan 1.5
    return adjustment.clamp(0.7, 1.5);
  }

  /// Get reminder message berdasarkan cuaca dengan pesan yang variatif
  String getWeatherReminder(WeatherData weather) {
    final List<String> veryHotMessages = [
      '🔥 HATI-HATI! Suhu mencapai ${weather.temperature.toStringAsFixed(1)}°C. Minum air lebih sering untuk hindari dehidrasi!',
      '🔥 Panas Ekstrem! Tingkatkan minum air hingga 2-3 gelas setiap jam.',
      '🔥 Suhu sangat tinggi (${weather.temperature.toStringAsFixed(1)}°C)! Prioritaskan minum air sekarang juga.',
      '🔥 Awas! Kondisi panas berbahaya. Minum air secara berkala dan istirahat di tempat sejuk.',
      '🔥 Cuaca ekstrem! Minum air dalam jumlah besar dan hindari aktivitas berat.',
    ];

    final List<String> hotMessages = [
      '☀️ Cuaca panas (${weather.temperature.toStringAsFixed(1)}°C). Pastikan minum cukup air hari ini.',
      '☀️ Hari yang panas! Jangan lupa minum air secara teratur.',
      '☀️ Suhu tinggi hari ini. Perbanyak minum air untuk menjaga stamina.',
      '☀️ Cuaca cerah dan panas. Minum air lebih banyak dari biasanya.',
    ];

    final List<String> warmMessages = [
      '🌤️ Cuaca hangat hari ini. Tetap minum air secara teratur untuk hidrasi optimal.',
      '🌤️ Suhu sedang hangat. Jangan lupa minum air cukup sepanjang hari.',
      '🌤️ Hari yang sejuk-hangat. Ingat minum air teratur untuk kesehatan.',
    ];

    final List<String> normalMessages = [
      '💧 Ingat minum air secara teratur hari ini!',
      '💧 Jangan lupa minum air untuk menjaga kesehatan tubuh.',
      '💧 Minum air cukup setiap hari sangat penting. Yuk mulai sekarang!',
      '💧 Hidrasi tubuh dengan minum air yang cukup.',
    ];

    final List<String> dryMessages = [
      '💨 Udara sangat kering hari ini. Tingkatkan minum air untuk jaga kelembaban kulit.',
      '💨 Kelembaban rendah! Minum lebih banyak untuk hindari kulit kering.',
      '💨 Udara kering sekali. Perlu minum air lebih banyak dari biasanya.',
    ];

    final List<String> rainMessages = [
      '🌧️ Meskipun hujan, tetap jaga keseimbangan cairan tubuh dengan minum cukup air.',
      '🌧️ Hujan hari ini, tapi tetap perlu minum air yang cukup untuk kesehatan.',
      '🌧️ Cuaca basah, jangan lupakan asupan air Anda hari ini.',
    ];

    final List<String> coldMessages = [
      '❄️ Cuaca dingin dapat mengurangi rasa haus. Pastikan tetap minum air cukup.',
      '❄️ Meskipun dingin, minum air tetap penting untuk tubuh Anda.',
      '❄️ Cuaca sejuk dapat membuat Anda lupa minum. Ingat tetap terhidrasi!',
    ];

    // Fungsi helper untuk memilih pesan random
    String _getRandomMessage(List<String> messages) {
      return messages[Random().nextInt(messages.length)];
    }

    // Logika pemilihan pesan berdasarkan suhu dan kondisi cuaca
    if (weather.temperature > 34) {
      return _getRandomMessage(veryHotMessages);
    } else if (weather.temperature > 30) {
      return _getRandomMessage(hotMessages);
    } else if (weather.temperature > 25) {
      return _getRandomMessage(warmMessages);
    } else if (weather.temperature < 5) {
      return _getRandomMessage(coldMessages);
    } else if (weather.humidity < 30) {
      return _getRandomMessage(dryMessages);
    } else if (weather.description.contains('Rain')) {
      return _getRandomMessage(rainMessages);
    }
    
    return _getRandomMessage(normalMessages);
  }

  /// Validate API Key
  Future<bool> validateApiKey() async {
    if (apiKey == 'YOUR_API_KEY_HERE') {
      return false;
    }

    try {
      final url = '$baseUrl/weather?q=Jakarta&appid=$apiKey&units=metric';
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
        onTimeout: () => http.Response('timeout', 408),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

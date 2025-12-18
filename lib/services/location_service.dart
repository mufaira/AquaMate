/// File: location_service.dart
/// Fungsi: Service untuk mengelola akses lokasi GPS pengguna.
/// Mendapatkan koordinat latitude/longitude untuk pengambilan data cuaca yang akurat.

import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Cek apakah location services sudah aktif
  static Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Request location permission
  static Future<LocationPermission> requestLocationPermission() {
    return Geolocator.requestPermission();
  }

  /// Cek permission status
  static Future<LocationPermission> checkLocationPermission() {
    return Geolocator.checkPermission();
  }

  /// Dapatkan lokasi pengguna saat ini
  static Future<Position?> getCurrentLocation() async {
    try {
      // Cek apakah location service aktif
      final isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        print('Location service tidak aktif');
        return null;
      }

      // Cek permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('Location permission ditolak');
        return null;
      }

      // Dapatkan lokasi dengan timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Location request timeout'),
      );
      return position;
    } catch (e) {
      print('Error mendapatkan lokasi: $e');
      return null;
    }
  }

  /// Stream lokasi pengguna (untuk real-time location updates)
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream();
  }

  /// Ambil last known position (lebih cepat)
  static Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('Error mendapatkan last known position: $e');
      return null;
    }
  }
}

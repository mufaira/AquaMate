# 💧 AquaMate - Water Intake Reminder App

**AquaMate** adalah aplikasi mobile berbasis Flutter yang membantu Anda melacak dan mengelola asupan air harian untuk gaya hidup sehat. Dengan fitur reminder pintar, tracking progress real-time, dan integrasi cuaca, AquaMate membuat menjaga hidrasi menjadi lebih mudah dan menyenangkan!

Dibuat Untuk Menyelesaikan UAS PPB Kelompok 7
Anggota :
Glidsi Isnayni Novgirl Ummaeroh - K3523033
Muhammad Irfan Dwi Putra - K3523049
Najela Najwa Anjani - K3523055

![AquaMate Logo](assets/icon/icon.png)

---

## ✨ Fitur Utama

### 🎯 **Progress Tracking Real-Time**
- Visualisasi progress asupan air harian dengan progress card yang interaktif
- Target harian yang dapat disesuaikan
- Animasi Lottie yang menarik untuk motivasi tambahan

### 💧 **Pencatatan Asupan Air**
- Pilih ukuran cangkir yang berbeda (200ml, 250ml, 300ml, 400ml, 500ml, dll)
- Catat waktu dan tanggal setiap kali Anda minum
- Catatan tambahan untuk setiap pencatatan

### 🌤️ **Integrasi Data Cuaca**
- Rekomendasi asupan air yang disesuaikan berdasarkan cuaca real-time
- Penyesuaian otomatis target harian berdasarkan temperatur dan kelembaban
- Fetch lokasi perangkat Anda untuk prediksi cuaca yang akurat

### 📊 **Riwayat & Statistik**
- Lihat riwayat lengkap asupan air Anda
- Statistik harian, mingguan, dan bulanan
- Grafik visual untuk memudahkan analisis

### ⚙️ **Pengaturan Personal**
- Kustomisasi target asupan air harian
- Atur nama pengguna
- Notifikasi reminder yang dapat dikonfigurasi
- Dark mode dan light mode support

### 🎨 **User Interface Intuitif**
- Desain modern dengan Google Fonts (Poppins)
- Navigasi bawah yang user-friendly
- Animasi smooth dan responsive

---

## 📱 Teknologi & Dependencies

### Platform Support
- ✅ **Android** (API 21+)
- ✅ **iOS** (13.0+)
- ✅ **Web**
- ✅ **Windows**
- ✅ **macOS**
- ✅ **Linux**

### Key Dependencies
```yaml
flutter:
  sdk: flutter
cupertino_icons: ^1.0.8
intl: ^0.18.0                 # Format waktu dan tanggal
lottie: ^3.3.2               # Animasi
google_fonts: ^6.3.3         # Font Poppins
shared_preferences: ^2.5.3   # Penyimpanan data lokal
http: ^1.1.0                 # API calls
geolocator: ^11.1.0          # Akses lokasi
```

---

## 🚀 Memulai

### Prasyarat
- Flutter SDK ^3.9.0 atau lebih tinggi
- Dart ^3.9.0 atau lebih tinggi
- Android Studio / Xcode (untuk build native)

### Instalasi

1. **Clone Repository**
   ```bash
   git clone https://github.com/mufaira/AquaMate.git
   cd AquaMate
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run Aplikasi**
   ```bash
   flutter run
   ```

### Build untuk Production

**Android:**
```bash
flutter build apk --release
# atau untuk App Bundle
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

---

## 📂 Struktur Proyek

```
lib/
├── main.dart                    # Entry point aplikasi
├── app/
│   ├── my_app.dart            # Root widget
│   └── theme.dart             # Tema aplikasi
├── models/
│   ├── user.dart              # Model data pengguna
│   └── water_intake.dart      # Model data asupan air
├── screens/
│   ├── splash_screen.dart     # Layar splash/loading
│   ├── onboarding_screen.dart # Layar onboarding
│   ├── home_screen.dart       # Layar utama
│   ├── history_screen.dart    # Layar riwayat
│   ├── settings_screen.dart   # Layar pengaturan
│   └── main_navigation_screen.dart # Navigasi utama
├── services/
│   ├── storage_service.dart   # Service penyimpanan data lokal
│   ├── location_service.dart  # Service lokasi
│   └── weather_service.dart   # Service cuaca
└── widgets/
    ├── progress_card.dart     # Widget kartu progress
    ├── cup_selection.dart     # Widget pemilihan ukuran cangkir
    ├── stat_card.dart         # Widget kartu statistik
    └── weather_card.dart      # Widget informasi cuaca
```

---

## 🎮 Cara Menggunakan

### Onboarding
1. Buka aplikasi AquaMate
2. Ikuti proses onboarding
3. Masukkan nama Anda dan atur target asupan air harian

### Mencatat Asupan Air
1. Di layar **Home**, pilih ukuran cangkir
2. Tekan tombol untuk menambahkan asupan
3. Catat waktu dan catatan (opsional)

### Melihat Riwayat
1. Navigasi ke tab **History**
2. Lihat semua pencatatan asupan air Anda
3. Filter berdasarkan tanggal atau periode

### Pengaturan
1. Buka tab **Settings**
2. Ubah profil pengguna Anda
3. Kustomisasi preferensi dan notifikasi

---

## 📊 Fitur Detail

### Smart Weather Adjustment
- Aplikasi otomatis menyesuaikan rekomendasi asupan berdasarkan:
  - Temperatur udara (lebih panas = lebih banyak air)
  - Kelembaban relatif
  - Kondisi cuaca

### Data Persistence
- Semua data disimpan secara lokal menggunakan SharedPreferences
- Tidak ada data yang dikirim ke server eksternal
- Data dapat di-export dan di-backup

### Responsive Design
- Adaptive layout untuk semua ukuran layar
- Support untuk landscape dan portrait
- Touch-friendly buttons dan controls

---

## 🔒 Privacy & Security

- ✅ Semua data disimpan secara lokal di perangkat
- ✅ Tidak ada tracking atau analytics pihak ketiga
- ✅ Lokasi hanya digunakan untuk fetch data cuaca
- ✅ Tidak ada login atau akun yang diperlukan

---

## 🐛 Troubleshooting

### Aplikasi crash saat membuka
```bash
flutter clean
flutter pub get
flutter run
```

### Location permission denied
- Android: Berikan izin lokasi di Settings > Apps > AquaMate
- iOS: Periksa Info.plist untuk NSLocationWhenInUseUsageDescription

### Data tidak tersimpan
- Pastikan SharedPreferences tidak diblokir
- Clear app cache di device settings

---

## 📝 Lisensi

Proyek ini menggunakan lisensi MIT. Lihat file [LICENSE](LICENSE) untuk detail lebih lanjut.

---

## 🤝 Kontribusi

Kontribusi sangat diterima! Untuk kontribusi:

1. Fork repository
2. Buat branch fitur (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buka Pull Request

---

## 👨‍💻 Developer

**AquaMate** dikembangkan oleh komunitas pengembang Flutter.

Untuk pertanyaan atau saran, silakan buat **Issues** di repository ini.

---

## 🙏 Terimakasih

Terima kasih telah menggunakan **AquaMate**! Mari jaga kesehatan dengan tetap terhidrasi!

💧 **Minum air, hidup lebih sehat!** 💧

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

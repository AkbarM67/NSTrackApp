# 📱 Home Widget Setup - NSTrackApp

## Cara Install Widget di Home Screen

### 1️⃣ Install Dependencies
```bash
flutter pub get
```

### 2️⃣ Build APK
```bash
flutter build apk --release
```

### 3️⃣ Install di HP
Install APK yang sudah di-build ke HP Android Anda.

### 4️⃣ Tambah Widget ke Home Screen

1. **Long press** di home screen HP
2. Pilih **Widgets**
3. Cari **NsTrack** atau **nstrackapp**
4. **Drag & drop** widget ke home screen
5. Widget akan menampilkan:
   - Total Saldo
   - Pemasukan
   - Pengeluaran
   - Tombol "Tambah Transaksi"

### 5️⃣ Cara Pakai

- Widget akan **auto-update** setiap kali ada perubahan transaksi
- Klik tombol **"+ Tambah Transaksi"** untuk langsung buka form tambah transaksi
- Data akan **real-time sync** dengan aplikasi

## 🎨 Tampilan Widget

```
┌─────────────────────────┐
│ NsTrack                 │
│                         │
│ ┌─────────────────────┐ │
│ │ Total Saldo         │ │
│ │ Rp 5.000.000        │ │
│ └─────────────────────┘ │
│                         │
│ ┌──────────┬──────────┐ │
│ │Pemasukan │Pengeluaran│ │
│ │Rp 8.000K │Rp 3.000K │ │
│ └──────────┴──────────┘ │
│                         │
│ [+ Tambah Transaksi]    │
└─────────────────────────┘
```

## 🔧 Troubleshooting

### Widget tidak muncul?
- Pastikan sudah install APK terbaru
- Restart HP
- Coba hapus dan tambah widget lagi

### Data tidak update?
- Buka aplikasi sekali
- Widget akan auto-update setelah transaksi baru

### Tombol tidak berfungsi?
- Pastikan aplikasi tidak di-force stop
- Cek permission aplikasi di Settings

## 📦 File yang Dibuat

- `lib/core/services/home_widget_service.dart` - Service untuk manage widget
- `android/app/src/main/res/layout/nstrack_widget.xml` - Layout widget
- `android/app/src/main/res/xml/nstrack_widget_info.xml` - Widget info
- `android/app/src/main/kotlin/.../NsTrackWidgetProvider.kt` - Widget provider
- `android/app/src/main/AndroidManifest.xml` - Updated manifest

## ✨ Fitur Widget

✅ Tampilkan saldo real-time  
✅ Tampilkan pemasukan & pengeluaran  
✅ Quick action: Tambah transaksi  
✅ Auto-update setiap ada perubahan  
✅ Desain modern & minimalis  

Selamat menggunakan! 🎉

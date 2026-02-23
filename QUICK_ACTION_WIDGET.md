# 🚀 Quick Action Widget - NSTrackApp

## ✨ Fitur Baru: Input Transaksi TANPA Buka App!

Sekarang widget punya **Quick Action Buttons** yang bisa langsung simpan transaksi **tanpa perlu buka aplikasi**!

---

## 🎯 Cara Kerja

### **Widget Tampilan:**
```
┌─────────────────────────────┐
│ NsTrack                     │
│ ┌─────────────────────────┐ │
│ │ Saldo: Rp 5.000.000     │ │
│ │ ↓ Masuk: Rp 8.000K      │ │
│ │ ↑ Keluar: Rp 3.000K     │ │
│ └─────────────────────────┘ │
│                             │
│ Quick Actions:              │
│ [☕ 20K] [🚗 10K] [🛒 50K]  │ ← KLIK LANGSUNG SIMPAN!
│                             │
│ [+ Custom Transaksi]        │ ← Buka form lengkap
│                             │
│ Berhasil: Makan             │ ← Status terakhir
└─────────────────────────────┘
```

---

## 🎮 Cara Pakai

### **1. Quick Actions (Tanpa Buka App)**

Klik tombol quick action:

| Tombol | Kategori | Jumlah | Deskripsi |
|--------|----------|--------|-----------|
| ☕ 20K | Makanan | Rp 20.000 | Makan |
| 🚗 10K | Transport | Rp 10.000 | Transport |
| 🛒 50K | Belanja | Rp 50.000 | Belanja |

**Proses:**
1. Klik tombol (misal: ☕ 20K)
2. **Langsung tersimpan** ke database
3. Widget update otomatis
4. Tampil status: "Berhasil: Makan"
5. **TIDAK perlu buka app!** ✅

---

### **2. Custom Transaksi (Buka App)**

Klik tombol **"+ Custom Transaksi"**:
- App terbuka
- Langsung ke form tambah transaksi
- Bisa input jumlah & kategori custom

---

## 🔧 Teknologi

### **Background Callback**
```dart
@pragma('vm:entry-point')
static Future<void> backgroundCallback(Uri? uri) async {
  // Jalan di background tanpa buka app
  if (uri.host == 'quickexpense') {
    await _addQuickExpense(
      category: uri.queryParameters['category'],
      amount: double.parse(uri.queryParameters['amount']),
      description: uri.queryParameters['description'],
    );
  }
}
```

**Cara kerja:**
1. User klik tombol widget
2. Android kirim URI: `nstrackapp://quickexpense?category=Makanan&amount=20000`
3. Flutter background callback tangkap
4. Langsung simpan ke Firestore
5. Update widget
6. **Selesai tanpa buka app!**

---

## ⚙️ Kustomisasi

### **Ubah Quick Actions**

Edit file: `NsTrackWidgetProvider.kt`

```kotlin
// Contoh: Tambah tombol "Kopi 15K"
val kopiIntent = Intent(context, MainActivity::class.java).apply {
    data = Uri.parse("nstrackapp://quickexpense?category=Makanan&amount=15000&description=Kopi")
}
```

Edit file: `nstrack_widget.xml`

```xml
<Button
    android:id="@+id/btn_kopi"
    android:text="☕ 15K"
    android:backgroundTint="#795548" />
```

---

## 📊 Keuntungan

| Fitur | Sebelum | Sesudah |
|-------|---------|---------|
| Input transaksi | Buka app → Form → Simpan | **Klik 1x → Selesai!** |
| Waktu | ~10 detik | **~1 detik** |
| Langkah | 5 langkah | **1 langkah** |
| Buka app | ✅ Harus | ❌ Tidak perlu |

---

## 🎨 Tampilan Widget

### **Compact Mode (4x2)**
```
┌─────────────────┐
│ NsTrack         │
│ Saldo: Rp 5.000K│
│ [☕][🚗][🛒]    │
│ [+ Custom]      │
└─────────────────┘
```

### **Full Mode (4x3)**
```
┌─────────────────────┐
│ NsTrack             │
│ ┌─────────────────┐ │
│ │ Saldo: Rp 5.000K│ │
│ │ ↓ Masuk: 8.000K │ │
│ │ ↑ Keluar: 3.000K│ │
│ └─────────────────┘ │
│ Quick Actions:      │
│ [☕ 20K] [🚗 10K]   │
│ [🛒 50K]            │
│ [+ Custom Transaksi]│
│ Berhasil: Makan     │
└─────────────────────┘
```

---

## 🚨 Troubleshooting

### **Quick action tidak jalan?**
- Pastikan sudah login di app
- Cek koneksi internet
- Lihat status di widget (baris terakhir)

### **Status "Gagal"?**
- Buka app sekali untuk refresh auth
- Cek Firebase connection

### **Widget tidak update?**
- Tunggu 1-2 detik
- Atau buka app untuk force update

---

## 📝 Catatan Penting

⚠️ **Keterbatasan Android Widget:**
- ❌ Tidak bisa input text/angka custom
- ❌ Tidak bisa dropdown/picker
- ✅ Hanya bisa tombol dengan nilai fixed

💡 **Solusi:**
- Quick actions untuk transaksi rutin (makan, transport, dll)
- Custom button untuk transaksi yang perlu input detail

---

## 🎉 Kesimpulan

**Sekarang bisa input transaksi SUPER CEPAT!**

- ☕ Beli kopi → Klik tombol → Selesai!
- 🚗 Naik ojek → Klik tombol → Selesai!
- 🛒 Belanja → Klik tombol → Selesai!

**Tidak perlu buka app sama sekali!** 🚀

---

Build & Install:
```bash
flutter pub get
flutter build apk --release
```

Selamat mencoba! 🎊

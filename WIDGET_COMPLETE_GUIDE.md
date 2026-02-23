# 🎯 NSTrack Widget - Complete Guide

## ✨ Fitur Widget

### 📊 **Tampilan Data**
- 💰 Total Saldo
- 📈 Pemasukan
- 📉 Pengeluaran
- 👁️ Toggle Hide/Show Angka

### ⚡ **Quick Actions (Tanpa Buka App)**

#### **Pengeluaran:**
| Tombol | Kategori | Jumlah | Deskripsi |
|--------|----------|--------|-----------|
| 🍔 20K | Makanan | Rp 20.000 | Makan |
| 🚗 10K | Transport | Rp 10.000 | Transport |
| 🛒 50K | Belanja | Rp 50.000 | Belanja |

#### **Pemasukan:**
| Tombol | Kategori | Jumlah | Deskripsi |
|--------|----------|--------|-----------|
| 💰 Gaji | Gaji | Rp 5.000.000 | Gaji |
| 🎁 Bonus | Bonus | Rp 1.000.000 | Bonus |
| 💵 100K | Lainnya | Rp 100.000 | Pemasukan Lainnya |

---

## 🎨 Tampilan Widget

```
┌─────────────────────────────┐
│ 💰 NsTrack          [👁️]   │ ← Toggle Hide
│                             │
│ ┌─────────────────────────┐ │
│ │ Saldo                   │ │
│ │ Rp 5.000.000            │ │ ← Bisa di-hide
│ │                         │ │
│ │ ↓ Masuk    ↑ Keluar     │ │
│ │ Rp 8.000K  Rp 3.000K    │ │
│ └─────────────────────────┘ │
│                             │
│ ⚡ Quick Actions            │
│ [🍔 20K][🚗 10K][🛒 50K]   │ ← Pengeluaran
│ [💰 Gaji][🎁 Bonus][💵 100K]│ ← Pemasukan
│                             │
│ ✓ Makan                     │ ← Status
└─────────────────────────────┘
```

### **Mode Hide:**
```
┌─────────────────────────────┐
│ 💰 NsTrack          [👁️]   │
│                             │
│ ┌─────────────────────────┐ │
│ │ Saldo                   │ │
│ │ Rp ••••••••             │ │ ← Hidden
│ │                         │ │
│ │ ↓ Masuk    ↑ Keluar     │ │
│ │ Rp ••••    Rp ••••      │ │ ← Hidden
│ └─────────────────────────┘ │
│                             │
│ ⚡ Quick Actions            │
│ [🍔 20K][🚗 10K][🛒 50K]   │
│ [💰 Gaji][🎁 Bonus][💵 100K]│
└─────────────────────────────┘
```

---

## 🚀 Cara Pakai

### **1. Toggle Hide/Show Angka**
- Klik icon **👁️** di kanan atas
- Angka akan berubah jadi **••••••**
- Klik lagi untuk show
- **TIDAK perlu buka app!**

### **2. Quick Transaction**

#### **Pengeluaran:**
1. Klik tombol (misal: 🍔 20K)
2. Langsung tersimpan ke database
3. Widget update otomatis
4. Status: "✓ Makan"

#### **Pemasukan:**
1. Klik tombol (misal: 💰 Gaji)
2. Langsung tersimpan Rp 5.000.000
3. Saldo bertambah otomatis
4. Status: "✓ Gaji"

---

## ⚙️ Kustomisasi Jumlah

Edit file: `NsTrackWidgetProvider.kt`

### **Ubah Jumlah Gaji:**
```kotlin
// Dari 5jt jadi 7jt
val gajiIntent = Intent(context, MainActivity::class.java).apply {
    data = Uri.parse("nstrackapp://quicktransaction?type=income&category=Gaji&amount=7000000&description=Gaji")
}
```

### **Ubah Jumlah Makan:**
```kotlin
// Dari 20K jadi 30K
val makanIntent = Intent(context, MainActivity::class.java).apply {
    data = Uri.parse("nstrackapp://quicktransaction?type=expense&category=Makanan&amount=30000&description=Makan")
}
```

### **Tambah Tombol Baru:**

1. Edit `nstrack_widget.xml`:
```xml
<Button
    android:id="@+id/btn_kopi"
    android:text="☕ 15K"
    android:backgroundTint="#795548" />
```

2. Edit `NsTrackWidgetProvider.kt`:
```kotlin
val kopiIntent = Intent(context, MainActivity::class.java).apply {
    data = Uri.parse("nstrackapp://quicktransaction?type=expense&category=Makanan&amount=15000&description=Kopi")
}
views.setOnClickPendingIntent(R.id.btn_kopi, PendingIntent.getActivity(
    context, 7, kopiIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
))
```

---

## 🔧 Teknologi

### **Background Processing**
```dart
@pragma('vm:entry-point')
static Future<void> backgroundCallback(Uri? uri) async {
  // Jalan di background tanpa buka app
  if (uri.host == 'quicktransaction') {
    await _addQuickTransaction(
      type: uri.queryParameters['type'],
      category: uri.queryParameters['category'],
      amount: double.parse(uri.queryParameters['amount']),
    );
  } else if (uri.host == 'togglehide') {
    await _toggleHideAmount();
  }
}
```

### **Alur Kerja:**
```
User klik tombol widget
    ↓
Android kirim URI
    ↓
Flutter background callback
    ↓
Simpan ke Firestore
    ↓
Update widget
    ↓
Selesai! (tanpa buka app)
```

---

## 📊 Perbandingan

| Fitur | Tanpa Widget | Dengan Widget |
|-------|--------------|---------------|
| Input transaksi | Buka app → Form → Simpan | **Klik 1x** |
| Waktu | ~10 detik | **~1 detik** |
| Langkah | 5 langkah | **1 langkah** |
| Lihat saldo | Buka app | **Langsung lihat** |
| Hide angka | Tidak bisa | **Klik toggle** |

---

## 🎯 Use Cases

### **Scenario 1: Beli Makan**
```
Beli nasi goreng Rp 20.000
→ Klik 🍔 20K di widget
→ Selesai! (1 detik)
```

### **Scenario 2: Terima Gaji**
```
Gaji masuk Rp 5.000.000
→ Klik 💰 Gaji di widget
→ Saldo langsung update!
```

### **Scenario 3: Privacy Mode**
```
Ada orang di samping
→ Klik 👁️ toggle
→ Angka jadi ••••••
→ Privacy terjaga!
```

---

## 🚨 Troubleshooting

### **Tombol tidak jalan?**
✅ Pastikan sudah login di app
✅ Cek koneksi internet
✅ Lihat status di widget

### **Toggle hide tidak jalan?**
✅ Tunggu 1-2 detik
✅ Atau refresh widget (remove & add lagi)

### **Widget tidak update?**
✅ Buka app sekali untuk sync
✅ Atau tunggu 30 menit (auto update)

---

## 📦 Install

```bash
# 1. Install dependencies
flutter pub get

# 2. Build APK
flutter build apk --release

# 3. Install di HP
# 4. Long press home screen → Widgets → NsTrack
# 5. Drag ke home screen
# 6. Done! 🎉
```

---

## 🎊 Kesimpulan

**Widget ini SUPER POWERFUL karena:**

✅ Input transaksi **TANPA buka app**
✅ Support **Pemasukan & Pengeluaran**
✅ **Toggle hide** untuk privacy
✅ **Auto-update** real-time
✅ **6 quick actions** siap pakai
✅ **Customizable** sesuai kebutuhan

**10x LEBIH CEPAT dari cara biasa!** 🚀

---

Selamat menggunakan! 💰✨

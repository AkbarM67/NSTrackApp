# 📱 NSTrack Widget - Simple & Clean

## ✨ Fitur Widget

### 📊 **Tampilan Data**
- 💰 Total Saldo (Format: Rp 5.000.000)
- 📈 Pemasukan (Format: Rp 8.000.000)
- 📉 Pengeluaran (Format: Rp 3.000.000)
- 👁️ Toggle Hide/Show (Format: Rp 5.xxx.xxx)

### 🎯 **Quick Action**
- ➕ **Tambah Transaksi** (Buka app ke form transaksi)

---

## 🎨 Tampilan Widget

### **Normal Mode:**
```
┌─────────────────────────────┐
│ 💰 NsTrack          [👁️]   │
│                             │
│ ┌─────────────────────────┐ │
│ │ Total Saldo             │ │
│ │ Rp 5.000.000            │ │ ← Format pakai titik
│ │                         │ │
│ │ ↓ Pemasukan             │ │
│ │ Rp 8.000.000            │ │
│ │                         │ │
│ │ ↑ Pengeluaran           │ │
│ │ Rp 3.000.000            │ │
│ └─────────────────────────┘ │
│                             │
│ [+ Tambah Transaksi]        │
└─────────────────────────────┘
```

### **Hide Mode:**
```
┌─────────────────────────────┐
│ 💰 NsTrack          [👁️]   │
│                             │
│ ┌─────────────────────────┐ │
│ │ Total Saldo             │ │
│ │ Rp 5.xxx.xxx            │ │ ← Cuma digit depan
│ │                         │ │
│ │ ↓ Pemasukan             │ │
│ │ Rp 8.xxx.xxx            │ │
│ │                         │ │
│ │ ↑ Pengeluaran           │ │
│ │ Rp 3.xxx.xxx            │ │
│ └─────────────────────────┘ │
│                             │
│ [+ Tambah Transaksi]        │
└─────────────────────────────┘
```

---

## 🚀 Cara Pakai

### **1. Lihat Saldo**
- Widget otomatis tampilkan saldo terbaru
- Format: **Rp 5.000.000** (pakai titik, bukan koma)
- Update otomatis setiap ada transaksi baru

### **2. Toggle Hide/Show**
- Klik icon **👁️** di kanan atas
- **Normal:** Rp 5.000.000
- **Hide:** Rp 5.xxx.xxx (cuma digit depan yang keliatan)
- Klik lagi untuk show
- **TIDAK perlu buka app!**

### **3. Tambah Transaksi**
- Klik tombol **"+ Tambah Transaksi"**
- App terbuka langsung ke form transaksi
- Input data → Simpan
- Widget update otomatis

---

## 📋 Format Angka

### **Normal Mode:**
| Jumlah | Format Widget |
|--------|---------------|
| 5000000 | Rp 5.000.000 |
| 8500000 | Rp 8.500.000 |
| 123456789 | Rp 123.456.789 |

### **Hide Mode:**
| Jumlah | Format Widget |
|--------|---------------|
| 5000000 | Rp 5.xxx.xxx |
| 8500000 | Rp 8.xxx.xxx |
| 123456789 | Rp 123.xxx.xxx |

**Logic:** Cuma digit pertama yang keliatan, sisanya jadi `xxx`

---

## 🔧 Teknologi

### **Format Rupiah (Dart)**
```dart
static String _formatRupiah(double amount) {
  return amount.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
}
```

**Hasil:**
- 5000000 → "5.000.000"
- 8500000 → "8.500.000"

### **Hide Logic (Kotlin)**
```kotlin
private fun hideNumber(number: String): String {
    val parts = number.split(".")
    val firstPart = parts[0]
    val hiddenParts = parts.drop(1).map { "xxx" }
    return (listOf(firstPart) + hiddenParts).joinToString(".")
}
```

**Hasil:**
- "5.000.000" → "5.xxx.xxx"
- "8.500.000" → "8.xxx.xxx"

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

## 🎯 Keuntungan

| Fitur | Benefit |
|-------|---------|
| Format Titik | Mudah dibaca (5.000.000) |
| Hide Smart | Privacy terjaga (5.xxx.xxx) |
| Simple UI | Tidak ribet, fokus ke data |
| Quick Access | Langsung ke form transaksi |
| Auto Update | Real-time sync |

---

## 🚨 Troubleshooting

### **Format angka salah?**
✅ Pastikan sudah rebuild APK terbaru
✅ Remove widget → Add lagi

### **Toggle hide tidak jalan?**
✅ Tunggu 1-2 detik
✅ Atau refresh widget

### **Widget tidak update?**
✅ Buka app sekali untuk sync
✅ Atau tunggu 30 menit (auto update)

---

## 📝 Catatan

✅ Format pakai **titik** (5.000.000) bukan koma
✅ Hide mode: **5.xxx.xxx** (cuma digit depan)
✅ Cuma **1 tombol** "Tambah Transaksi"
✅ Tombol buka app (bukan background process)
✅ Simple, clean, fokus ke data

---

Selamat menggunakan! 💰✨

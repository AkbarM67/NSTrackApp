# Setup Google Sheets API (Versi Sederhana dengan API Key)

## Langkah 1: Buat Project di Google Cloud Console

1. Buka https://console.cloud.google.com/
2. Klik "Select a project" → "New Project"
3. Beri nama project (contoh: "NsTrack App")
4. Klik "Create"

## Langkah 2: Enable Google Sheets API

1. Di menu kiri, pilih "APIs & Services" → "Library"
2. Cari "Google Sheets API"
3. Klik dan pilih "Enable"

## Langkah 3: Buat API Key

1. Di menu kiri, pilih "APIs & Services" → "Credentials"
2. Klik "Create Credentials" → "API Key"
3. Copy API Key yang muncul
4. (Opsional) Klik "Restrict Key" untuk keamanan:
   - Application restrictions: Pilih "Android apps" atau "iOS apps"
   - API restrictions: Pilih "Restrict key" → Centang "Google Sheets API"
5. Klik "Save"

## Langkah 4: Buat Google Sheets

1. Buka https://sheets.google.com/
2. Buat spreadsheet baru
3. Beri nama (contoh: "NsTrack Transactions")
4. Buat sheet dengan nama "Transaksi"
5. Copy ID dari URL:
   ```
   https://docs.google.com/spreadsheets/d/SPREADSHEET_ID_INI_YANG_DICOPY/edit
   ```

## Langkah 5: Set Permissions

1. Klik tombol "Share" di kanan atas
2. Ubah "Restricted" menjadi "Anyone with the link"
3. Pilih role "Editor"
4. Klik "Done"

⚠️ **PENTING**: Spreadsheet harus public atau "Anyone with the link" agar API Key bisa akses!

## Langkah 6: Update Code

1. Buka `lib/core/services/google_sheets_service.dart`
2. Ganti `YOUR_API_KEY_HERE` dengan API Key Anda
3. Ganti `YOUR_SPREADSHEET_ID_HERE` dengan Spreadsheet ID Anda

Contoh:
```dart
static const _apiKey = 'AIzaSyAcm0DGRxhlCxhZeOxyXQHv4WECVzK07lY';
static const _spreadsheetId = '1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms';
```

## Format Data di Google Sheets:

| Tanggal | Tipe | Kategori | Jumlah | Deskripsi | User ID |
|---------|------|----------|--------|-----------|----------|
| 01/01/2024 10:30 | Pengeluaran | Makanan | 50000 | Makan siang | user123 |

## Testing:

Setelah setup, setiap transaksi baru akan otomatis tersimpan ke Google Sheets!

## Keamanan:

⚠️ Untuk production, sebaiknya:
1. Restrict API Key ke aplikasi Android/iOS Anda saja
2. Atau gunakan Service Account (lebih aman tapi lebih kompleks)
3. Jangan commit API Key ke Git public repository

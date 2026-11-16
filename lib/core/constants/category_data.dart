/// Definisi subkategori (turunan) untuk setiap kategori induk.
/// Kategori yang tidak ada di map ini tidak menampilkan dropdown subkategori.
class CategoryData {
  static const Map<String, List<String>> subcategories = {
    'Transport': ['Bensin', 'Service Motor', 'Parkir', 'Tol', 'Oli', 'Sparepart', 'Lainnya'],
    'Makanan': ['Makan Siang', 'Makan Malam', 'Jajan', 'Minum', 'Lainnya'],
    'Belanja': ['Kebutuhan Rumah', 'Pakaian', 'Elektronik', 'Lainnya'],
    'Hiburan': ['Nonton', 'Game', 'Jalan-jalan', 'Lainnya'],
    'Ojol': ['Grab', 'ShopeeFood', 'Lainnya'],
  };

  /// Mengembalikan daftar subkategori untuk [category], atau null jika tidak punya.
  static List<String>? subcategoriesFor(String category) {
    return subcategories[category];
  }
}

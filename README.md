# 🌱 Tandur - Digital Agronomy Ecosystem

**Tandur** adalah aplikasi ekosistem agrikultur digital yang dirancang untuk menghubungkan Petani lokal (*Mitra Tani*) langsung dengan Pembeli. Proyek ini dikembangkan sebagai bagian dari inisiatif **Google Developer Group On Campus (GDGOC)** untuk memecahkan masalah rantai pasok pangan menggunakan teknologi modern.

---

## 📱 Alur Aplikasi (Application Flow)

Aplikasi Tandur mengimplementasikan sistem **Dual Role** (Dua Peran) di mana pengguna dapat mendaftar sebagai **Petani** atau **Pembeli**. Berikut adalah alur lengkap aplikasinya:

### 1. Pra-Autentikasi (Pre-Auth)
- **Splash Screen**: Menampilkan logo dengan animasi yang mulus. Mengecek memori perangkat secara otomatis untuk menentukan arah navigasi berdasarkan status login.
- **Onboarding**: Halaman pengenalan fitur aplikasi bagi pengguna yang baru pertama kali menginstal aplikasi.
- **Autentikasi (Login & Register)**:
  - Pendaftaran dapat dilakukan secara manual atau menggunakan **Google Sign-In** untuk kemudahan akses (1-tap login).
  - Saat pendaftaran, pengguna diwajibkan memilih *Role* (Petani atau Pembeli).
  - Mendukung unggah foto profil (Multipart Form-Data) langsung saat registrasi.

### 2. Alur Pembeli (Buyer Flow)
- **Beranda (Home)**: Menampilkan banner promosi, insight cuaca/agrikultur, dan rekomendasi produk teratas.
- **Pasar (Marketplace)**: 
  - Menampilkan daftar seluruh produk agrikultur menggunakan *Lazy Loading* & *Pagination* (didukung oleh backend).
  - Dilengkapi filter kategori yang dinamis (Sayuran, Buah, Benih, dll).
  - Menggunakan **Skeleton Loading / Shimmer** agar transisi data terasa sangat responsif dan premium.
- **Detail Produk**: Menampilkan detail harga, deskripsi, informasi stok (*in-stock/out-of-stock*), dan gambar produk.
- **Keranjang (Cart)**: Fitur pengelolaan produk yang ingin dibeli, penyesuaian kuantitas (*increment/decrement*), dan total harga dinamis.
- **Checkout & Lokasi**: Proses konfirmasi pesanan dengan kemampuan deteksi titik lokasi pengiriman (menggunakan **Google Maps**).

### 3. Alur Petani (Farmer Flow)
- **Dashboard Petani (Home)**: Tampilan ringkas untuk petani memantau aktivitas dan performa penjualan mereka.
- **Manajemen Produk (Manage Products)**: 
  - Petani dapat melihat daftar produk yang mereka miliki.
  - Memantau status produk (apakah *Active* atau *Pending* dari admin).
- **Unggah Produk (Upload Product)**:
  - Form komprehensif bagi petani untuk menambahkan produk baru.
  - Input mencakup gambar (dari galeri/kamera), nama produk, kategori, harga, tipe stok (kg, gram, ikat), dan jumlah stok.

---

## 🛠️ Teknologi & Google Ecosystem Integration

Aplikasi ini dibangun menggunakan framework **Flutter** dan sangat mengandalkan ekosistem Google untuk menghasilkan performa, UX, dan fungsionalitas terbaik. Berikut adalah beberapa *package* utama yang terintegrasi:

### 🌐 Google-Related Packages
*   **[`google_sign_in`](https://pub.dev/packages/google_sign_in)**: Digunakan untuk fitur autentikasi SSO (Single Sign-On). Memungkinkan pengguna mendaftar dan masuk menggunakan akun Google mereka secara instan, aman, dan tanpa hambatan.
*   **[`google_maps_flutter`](https://pub.dev/packages/google_maps_flutter)**: Diintegrasikan untuk fitur peta interaktif, khususnya pada saat *Checkout* dan pengaturan alamat profil.
*   **[`geocoding`](https://pub.dev/packages/geocoding)**: Bekerja berdampingan dengan Google Maps untuk melakukan *Reverse Geocoding* (mengubah titik koordinat *latitude/longitude* menjadi alamat jalan yang bisa dibaca manusia).
*   **[`google_fonts`](https://pub.dev/packages/google_fonts)**: Menghasilkan tipografi modern yang indah dan konsisten. Kami memadukan font **Be Vietnam Pro** (untuk *Heading*) dan **Inter** (untuk *Body Text*).

### 📦 Core Architecture Packages
*   **[`go_router`](https://pub.dev/packages/go_router)**: Sistem *routing* tingkat lanjut yang kami gunakan untuk memproteksi halaman (Auth Guard). Memastikan pengguna yang belum login tidak bisa mengakses halaman beranda, dan pengguna yang sudah login otomatis melewati halaman otentikasi.
*   **[`provider`](https://pub.dev/packages/provider)**: Solusi *State Management* reaktif yang mengatur keranjang belanja, status login pengguna, dan data marketplace secara efisien.
*   **[`dio`](https://pub.dev/packages/dio)**: HTTP client canggih untuk mengelola komunikasi dengan REST API, mendukung fitur kompleks seperti *Interceptor*, pengelolaan JWT Token, dan unggah file (*Multipart Form-Data*).
*   **[`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv)**: Manajemen konfigurasi rahasia (*Environment Variables*) untuk menyembunyikan API keys dan Base URL.

---

## 🎨 UI/UX & Desain
Tandur tidak hanya fokus pada fungsionalitas, tetapi juga pada estetika:
- **Animasi Transisi**: Navigasi antar halaman menggunakan animasi `Slide` dan `Fade` kustom (*CurvedAnimation*) untuk *feel* yang lebih elegan.
- **Shimmer Effect**: Penggunaan kerangka (*Skeleton*) beranimasi saat memuat API, meminimalisir *layout shift* yang mengganggu.
- **Glassmorphism & Shadows**: Penggunaan bayangan lembut (*soft shadows*) dan sudut membulat (*pill shapes*) agar aplikasi terasa berkelas (Premium Design).

---

*Dibuat dengan ❤️ untuk inisiatif Google Developer Group On Campus.*

# 🌱 Tandur - Digital Agronomy Ecosystem

**Tandur** adalah aplikasi ekosistem agrikultur digital yang dirancang untuk menghubungkan Petani lokal (*Mitra Tani*) langsung dengan Pembeli secara transparan dan efisien. Proyek ini dikembangkan sebagai bagian dari inisiatif **Google Developer Group On Campus (GDGOC)** untuk memecahkan masalah rantai pasok pangan dan meningkatkan kesejahteraan petani menggunakan teknologi modern.

---

## 🏗️ Arsitektur & Pola Desain (Architecture)

Proyek ini mengadopsi pendekatan **Feature-First / Clean Architecture Sederhana**. Struktur *codebase* dipisahkan berdasarkan fitur bisnis untuk memastikan aplikasi bersifat modular, *scalable*, dan mudah dipelihara.

1. **`lib/core/` (Inti Aplikasi)**
   - Berisi utilitas fundamental: konfigurasi REST API (`api_client.dart`), token desain/warna (`color.dart`), konfigurasi *routing* (`app_router.dart`), serta komponen *widget* global yang dapat digunakan kembali (*reusable widgets*) seperti *Skeleton Loader* dan *Location Picker*.
2. **`lib/features/` (Modul Bisnis)**
   Setiap folder fitur (misal: `auth`, `buyer`, `farmer`) dipisah menjadi beberapa lapisan fungsionalitas:
   - **Models**: Representasi struktur *JSON* dari *backend* (menggunakan `factory .fromJson`).
   - **Services**: Lapisan abstraksi data untuk berkomunikasi murni dengan REST API menggunakan `Dio`, menangani HTTP *Request*, dan memetakan *Response* atau *DioException*.
   - **Providers**: Lapisan *State Management* (menggunakan `ChangeNotifier`). Bertindak sebagai perantara UI dan *Service*, memegang *state*, serta memperbarui tampilan menggunakan `notifyListeners()`.
   - **Screens & Widgets**: Tampilan UI deklaratif yang merespons perubahan *state* (*Reactive UI*) menggunakan `Consumer` atau `ListenableBuilder`.

---

## 📱 Alur Aplikasi (Application Flow)

Aplikasi Tandur mengimplementasikan sistem **Dual Role** (Dua Peran) di mana pengguna dapat mendaftar sebagai **Petani** atau **Pembeli**.

### 1. Pra-Autentikasi (Pre-Auth)
- **Splash Screen**: Menampilkan logo animasi dan versi aplikasi (App Versioning). Mengecek *local storage* untuk menentukan arah rute (*routing*) pengguna.
- **Onboarding**: Tayangan *slider* edukatif mengenai fitur aplikasi untuk pengguna yang baru pertama kali menginstal.
- **Autentikasi (Login & Register)**:
  - Tersedia opsi pendaftaran manual dengan kelengkapan *form* dan pemilihan *Role* pengguna (Petani/Pembeli).
  - Integrasi dengan **Google Sign-In** untuk kemudahan pendaftaran secara instan (*SSO*).
  - Mendukung unggah foto profil (menggunakan *Multipart Form-Data*) langsung ke *server*.

### 2. Alur Pembeli (Buyer Flow)
- **Beranda (Home)**: Tampilan visual interaktif dengan *banner* promo dinamis dan etalase produk-produk agrikultur paling segar.
- **Pasar (Marketplace)**: Menampilkan seluruh katalog hasil panen petani. Didukung oleh *Skeleton Loading* saat memuat data, serta fitur penyaringan (kategori/pencarian) untuk pencarian produk yang efisien.
- **Keranjang (Cart)**: Antarmuka *compact* dan premium untuk memanajemen item yang akan dibeli. Menyediakan *Qty Controller* interaktif, kalkulasi harga *real-time*, dan aksi *checklist* produk yang intuitif.
- **Checkout & Lokasi Pengiriman**: Layar konfirmasi akhir. Terintegrasi dengan **Google Maps** (`LocationPickerScreen`) agar pembeli dapat menandai titik koordinat (*latitude/longitude*) pengiriman secara akurat, disertai *Reverse Geocoding* untuk mendapatkan alamat tekstual lengkap.
- **Riwayat Pesanan (Orders)**: Papan pantau pesanan dengan fungsionalitas *Pull-to-refresh*. Menampilkan indikator warna spesifik (Pending, Diterima, Ditolak, Selesai) dan memetakan nama profil *real-time* dari petani yang bersangkutan (bukan sekadar menampilkan *ID* anonim).

### 3. Alur Petani (Farmer Flow)
- **Dashboard Petani (Home)**: Panel pemantauan yang menampilkan secara *real-time* saldo/total pendapatan petani. Data saldo tersinkronisasi otomatis dengan API profil pengguna (`/users/me`), dan memiliki kapabilitas *Pull-to-refresh*.
- **Manajemen Pesanan Masuk (Transactions)**: Petani dapat meninjau pesanan yang datang dari para pembeli. Terintegrasi dengan endpoint mutasi data (`PATCH /transactions/{id}/status`) yang memungkinkan petani untuk langsung **Menerima** atau **Menolak** transaksi dari UI.
- **Manajemen & Unggah Produk (Manage Products)**: Antarmuka manajemen stok. Formulir *Upload* memungkinkan petani mengunggah rincian barang, kategori, menetapkan spesifikasi (Kg, Gram, Ikat), serta melampirkan beberapa visualisasi (foto) aset sekaligus menggunakan kamera atau galeri.
- **Harga Pangan (Market Price Info)**: Fitur esensial yang terintegrasi dengan API data ketahanan pangan. Memungkinkan petani melihat harga-harga pasaran komoditas terkini di berbagai wilayah/pasar, membantu mereka dalam menentukan harga jual panen yang kompetitif dan menguntungkan.

---

## 🛠️ Teknologi & Ekosistem (Tech Stack)

Aplikasi ini dibangun menggunakan framework **Flutter** dan memadukan ekosistem Google secara ekstensif untuk mencapai standar fungsionalitas dan UX berskala komersial:

### 🌐 Google-Related Integrations
*   **[`google_sign_in`](https://pub.dev/packages/google_sign_in)**: Sistem SSO terotentikasi dan aman tanpa menggunakan *password*.
*   **[`google_maps_flutter`](https://pub.dev/packages/google_maps_flutter)**: Rendering Peta 3D/2D di layar *Checkout* (pembeli) serta visualisasi peta profil toko (petani) untuk akurasi rantai pasok.
*   **[`geocoding`](https://pub.dev/packages/geocoding)**: Translasi balik (*Reverse Geocoding*) untuk mendapatkan teks nama jalan/daerah dari penempatan pin (*pin-drop*) Google Maps.
*   **[`google_fonts`](https://pub.dev/packages/google_fonts)**: Menyediakan fondasi desain tipografi (*Be Vietnam Pro* & *Inter*) tanpa harus mengunduh aset statis ke aplikasi, memperkecil ukuran *bundle*.

### 📦 Core Engineering Packages
*   **[`provider`](https://pub.dev/packages/provider)**: *Vanilla State Management* pilihan yang ringan. Kami menerapkan pola `ChangeNotifier` dipadu dengan `Consumer`/`ListenableBuilder` untuk merender ulang komponen secara *granular* dan efisien (tanpa membebani memori).
*   **[`go_router`](https://pub.dev/packages/go_router)**: Sistem rute deklaratif tingkat lanjut (*Auth Guards* / Perlindungan Navigasi). Digunakan secara masif untuk implementasi `ShellRoute` guna menjaga *state Bottom Navigation Bar* tidak hilang saat *routing*.
*   **[`dio`](https://pub.dev/packages/dio)**: Manajemen konektivitas REST tingkat mahir. Konfigurasi `Interceptors` secara otomatis menyematkan otorisasi (*Bearer Token*) ke setiap panggilan internal dan melakukan pengamanan (*logging*).
*   **[`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv)**: Manajemen kerahasiaan (*Environment Variable / .env*) agar URL server backend atau _Secret Key_ tetap terlindungi dengan aman.
*   **[`shared_preferences`](https://pub.dev/packages/shared_preferences)**: Persistensi data lokal, mencatat *Token JWT* untuk mempertahankan sesi serta flag status penayangan layar (*Onboarding*).
*   **[`image_picker`](https://pub.dev/packages/image_picker)**: Pustaka asali dalam mengolah jepretan kamera / input berkas multimedia lokal (di-bantu `image_picker_helper.dart` bawaan arsitektur Tandur).

---

## 🎨 UI/UX & Standar Kualitas (Quality Standard)

Tandur dirancang dengan standar kualitas desain *Premium UI*:
- **Responsivitas & Shimmer Effect**: Hampir seluruh pengambilan data (*fetching*) dilindungi oleh komponen `SkeletonBox`. Menghapus efek visual canggung (*Layout Shifts*) dari layar putih kosong ke konten utama.
- **Glassmorphism & Elevasi Dinamis**: Implementasi komponen dengan saturasi warna rendah (efek transparan) dikombinasi dengan *box shadow*, menciptakan kesan kedalaman desain.
- **Konsistensi Format Numerik & Tanggal**: Standardisasi *helper* secara sentral, untuk memisahkan logika pemrosesan string tanggal standar ISO, dan konversi harga ke format Rupiah secara natural (mengabaikan desimal/fragmen mata uang ganjil di belakang koma dari sisi backend).

---

*Dibuat dengan ❤️ untuk inisiatif Google Developer Group On Campus.*

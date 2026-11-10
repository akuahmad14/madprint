# MADprint Mobile

Aplikasi mobile untuk membantu operasional percetakan dalam mengelola pesanan pelanggan, membuat Surat Perintah Kerja (SPK) dengan QR Code, memantau proses produksi, dan memperbarui status pesanan. Proyek ini dikembangkan menggunakan Flutter dan Supabase serta digunakan sebagai objek pengujian pada UTS mata kuliah **Mobile Testing**.

> **Nama proyek:** Pengujian Aplikasi Mobile dengan User Acceptance Testing dan Maestro  
> **Mata kuliah:** Mobile Testing — S1 Teknik Informatika, TI23B

## Identitas Pengembang

| Nama | NIM | Kelas | Peran |
|---|---|---|---|
| Ahmad Saifudin | 230103214 | TI23B | Pengembang aplikasi, penyusun skenario UAT, dan penguji otomatisasi Maestro |

Lengkapi NIM sebelum pengumpulan. Jika proyek dikerjakan bersama anggota lain, tambahkan nama, NIM, kelas, dan peran setiap anggota pada tabel ini serta cantumkan kembali dalam video penjelasan.

## 1. Gambaran Umum Aplikasi

MADprint Mobile ditujukan untuk admin, operator, dan staf percetakan. Aplikasi membantu pencatatan pesanan dan pemantauan pengerjaan agar informasi pesanan dapat diakses sesuai hak pengguna.

### Fitur utama

- Autentikasi pengguna menggunakan Supabase Auth.
- Dashboard ringkasan pesanan dengan pembaruan data.
- Pembuatan, pencarian, dan pengelolaan pesanan.
- Pembuatan SPK dengan QR Code unik untuk setiap pesanan.
- Pemindaian QR Code untuk membuka detail pesanan.
- Pembaruan status pesanan dan pencatatan riwayat pengerjaan.
- Pembatasan tindakan berdasarkan peran admin, operator, dan staf.

### Alur pengguna utama

1. Pengguna membuka aplikasi dan masuk menggunakan akun yang telah terdaftar.
2. Aplikasi memuat profil serta menampilkan menu sesuai peran pengguna.
3. Admin membuka menu **Pesanan** dan membuat pesanan baru.
4. Setelah data valid disimpan, aplikasi menampilkan detail pesanan dan QR Code SPK.
5. Pengguna yang memiliki hak akses dapat memindai QR dan memperbarui status pesanan sesuai aturan aplikasi.

### Batasan pengujian

Pengujian UTS difokuskan pada perangkat Android dan peran Admin, meliputi autentikasi, validasi input, pembuatan pesanan, dan navigasi. Pengujian ini bukan audit keamanan menyeluruh, pengujian beban, atau pengujian kompatibilitas pada seluruh versi Android. Hasil PASS/FAIL hanya boleh ditetapkan berdasarkan eksekusi dan bukti aktual.

## 2. Teknologi

| Komponen | Teknologi |
|---|---|
| Framework | Flutter |
| Bahasa | Dart |
| Backend dan autentikasi | Supabase |
| Database | PostgreSQL |
| State management | Riverpod |
| QR Code | qr_flutter |
| Pemindai QR | mobile_scanner |
| Otomatisasi UI | Maestro |
| Platform pengujian | Android |

## 3. Struktur Repository

Folder aplikasi Flutter berada di dalam direktori `madprint/`.

```text
madprint/
├── .maestro/
│   ├── 01_launch_login.yaml
│   ├── 02_login_admin.yaml
│   ├── 03_order_form_validation.yaml
│   ├── 04_create_order.yaml
│   ├── 05_navigation_admin.yaml
│   └── 06_login_validation.yaml
├── android/
├── assets/
├── docs/
│   ├── MAESTRO_TESTING.md
│   └── UAT_MADPRINT.md
├── lib/
├── supabase/
│   └── schema.sql
├── test/
├── pubspec.yaml
└── README.md
```

## 4. Persiapan dan Menjalankan Aplikasi

### Prasyarat

- Flutter SDK dan Dart SDK sesuai batas versi pada `pubspec.yaml`.
- Android SDK serta perangkat Android atau emulator.
- Akun dan proyek Supabase yang telah dikonfigurasi.
- Koneksi internet untuk mengakses layanan Supabase.

### Konfigurasi Supabase

1. Buat atau gunakan proyek Supabase.
2. Buka **SQL Editor** pada dashboard Supabase.
3. Jalankan isi file `madprint/supabase/schema.sql` untuk menyiapkan tabel, kebijakan akses, trigger, dan fungsi database yang dibutuhkan aplikasi.
4. Siapkan akun pengujian melalui Supabase Authentication dan pastikan profil serta perannya sesuai skenario.
5. Siapkan URL proyek dan **publishable/anon key** untuk konfigurasi aplikasi. Jangan gunakan atau memasukkan `service_role key` ke aplikasi, file konfigurasi yang di-commit, screenshot, maupun repository.

### Instalasi dependency

Jalankan perintah dari root repository:

```powershell
cd madprint
flutter pub get
```

### Menjalankan aplikasi

Gunakan nilai konfigurasi proyek Supabase milik lingkungan pengujian:

```powershell
flutter run --dart-define=SUPABASE_URL="https://PROJECT-REF.supabase.co" --dart-define=SUPABASE_ANON_KEY="SUPABASE_PUBLISHABLE_OR_ANON_KEY"
```

Ganti nilai contoh dengan konfigurasi milik sendiri. Jangan menuliskan kredensial akun Admin ke dalam source code atau repository.

### Membuat APK

```powershell
flutter build apk --release --dart-define=SUPABASE_URL="https://PROJECT-REF.supabase.co" --dart-define=SUPABASE_ANON_KEY="SUPABASE_PUBLISHABLE_OR_ANON_KEY"
```

Jika proses build berhasil, APK release tersedia di:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 5. Pengujian Maestro

Flow Maestro disimpan pada `madprint/.maestro/`. Enam flow yang tersedia mencakup pembukaan aplikasi, login, validasi, transaksi pesanan, dan navigasi.

| Flow | Tujuan |
|---|---|
| `01_launch_login.yaml` | Membuka aplikasi dan memeriksa elemen halaman login |
| `02_login_admin.yaml` | Login Admin dan memeriksa dashboard |
| `03_order_form_validation.yaml` | Memeriksa validasi form pesanan kosong |
| `04_create_order.yaml` | Membuat pesanan uji dan memeriksa detailnya |
| `05_navigation_admin.yaml` | Memeriksa navigasi menu Admin |
| `06_login_validation.yaml` | Memeriksa validasi email pada halaman login |

### Menjalankan flow

Gunakan **Maestro Studio Desktop** (bukan Maestro CLI) untuk membuka dan menjalankan flow YAML. Flow berada di folder `madprint/.maestro/`.

#### Persiapan perangkat

1. Aktifkan **Developer options** dan **USB debugging** pada ponsel Android.
2. Hubungkan ponsel ke komputer menggunakan kabel data dan izinkan USB debugging pada layar ponsel.
3. Pastikan Android SDK Platform-Tools tersedia. Studio memakai ADB untuk menemukan perangkat.
4. Buka Maestro Studio Desktop.
5. Buka workspace/folder flow `madprint/.maestro/` (atau folder proyek `madprint/`, lalu pilih flow di dalam `.maestro`, sesuai versi Studio).
6. Pilih perangkat Android yang terhubung pada daftar device di Studio.

Jika perangkat tidak muncul, tutup aplikasi lain yang mengelola ADB, periksa kabel dan izin USB debugging, lalu buka kembali Studio. Jangan menjalankan `adb kill-server` ketika Studio sedang memakai perangkat.

#### Menjalankan flow di Studio

1. Pilih file YAML yang ingin diuji pada panel workspace.
2. Periksa isi flow dan pastikan `appId: com.example.madprint` sesuai dengan aplikasi yang terpasang.
3. Tekan tombol **Run/Play** pada flow di Maestro Studio.
4. Amati interaksi pada perangkat dan hasil setiap perintah/assertion pada panel hasil Studio.
5. Ulangi untuk flow lainnya. Jalankan flow login sebelum flow yang membutuhkan sesi Admin; jika flow memulai ulang aplikasi atau membersihkan state, lakukan login kembali.
6. Simpan screenshot, log, atau rekaman yang disediakan Studio ke `madprint/docs/evidence/bukti_Maestro`.

Flow login menggunakan variabel lokal `MAESTRO_EMAIL` dan `MAESTRO_PASSWORD`. Masukkan nilainya melalui mekanisme environment/secrets lokal yang didukung versi Maestro Studio yang digunakan. Jangan mengganti variabel dengan password literal dan jangan commit kredensial. Jika versi Studio yang dipakai tidak mendukung environment variable pada flow, siapkan mekanisme lokal yang aman sebelum menjalankan flow login; jangan mengunggah file rahasia.

**Hasil pelaksanaan:** Berdasarkan konfirmasi penguji, keenam flow Maestro telah berhasil dijalankan melalui Maestro Studio Desktop. Ringkasan hasil dan daftar bukti yang perlu dilampirkan dicatat pada [Panduan pengujian Maestro](madprint/docs/MAESTRO_TESTING.md).

## 6. User Acceptance Testing (UAT)

Hasil UAT dan tabel skenario tersedia pada [Laporan UAT MadPrint](madprint/docs/UAT_MADPRINT.md). Enam skenario UAT (UAT-01 sampai UAT-06) telah dinyatakan lolos oleh penguji.

Enam skenario yang telah diuji:

1. Login Admin dengan kredensial valid.
2. Login dengan kredensial tidak valid.
3. Validasi format email.
4. Validasi formulir pesanan kosong.
5. Membuat pesanan dengan data valid.
6. Navigasi menu Admin.

**Rekap UAT: 6 PASS, 0 FAIL.** Skenario tampilan QR terpisah tidak termasuk ruang lingkup pengujian yang dilaporkan.

## 7. Dokumentasi dan Bukti

- [Laporan UAT](madprint/docs/UAT_MADPRINT.md)
- [Panduan pengujian Maestro](madprint/docs/MAESTRO_TESTING.md)
- [Folder flow Maestro](madprint/.maestro/)
- [Screenshot Bukti Maestro](madprint/docs/evidence/bukti_Maestro/)
- [Screenshot Bukti UAT](madprint/docs/evidence/bukti_UAT/)

## 8. Video Penjelasan dan File APK

**Tautan video:** https://drive.google.com/file/d/1kOQTRP3ULojsL3lJQfQidhD2RGq7acKd/view?usp=sharing
**Tautan APK:** https://drive.google.com/file/d/1qHMQkPEHC6L0YgRHwDOulvQY7bvN7eBk/view?usp=sharing
Video menjelaskan identitas dan peran anggota, tujuan serta fitur aplikasi, demonstrasi alur utama, pelaksanaan UAT, eksekusi flow Maestro, hasil pengujian, dan temuan/batasan yang diketahui.

## 9. Repository

**GitHub:** https://github.com/akuahmad14/madprint

Pastikan repository dapat diakses dosen. Riwayat Git harus memuat sedikitnya lima commit yang bermakna. Jangan menyimpan password, API key rahasia, access token, atau kredensial lain di repository.

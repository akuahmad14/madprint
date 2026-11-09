# MADprint Mobile

Aplikasi mobile untuk membantu operasional percetakan dalam mengelola pesanan pelanggan, membuat Surat Perintah Kerja (SPK) dengan QR Code, memantau proses produksi, dan memperbarui status pesanan. Proyek ini dikembangkan menggunakan Flutter dan Supabase serta digunakan sebagai objek pengujian pada UTS mata kuliah **Mobile Testing**.

> **Nama proyek:** Pengujian Aplikasi Mobile dengan User Acceptance Testing dan Maestro  
> **Mata kuliah:** Mobile Testing — S1 Teknik Informatika, TI23B

## Identitas Pengembang

| Nama | NIM | Kelas | Peran |
|---|---|---|---|
| Ahmad Saifudin | **[Isi NIM]** | TI23B | Pengembang aplikasi, penyusun skenario UAT, dan penguji otomatisasi Maestro |

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

Pengujian UTS difokuskan pada perangkat Android dan peran Admin, meliputi autentikasi, validasi input, pembuatan pesanan, navigasi, serta tampilan QR. Pengujian ini bukan audit keamanan menyeluruh, pengujian beban, atau pengujian kompatibilitas pada seluruh versi Android. Hasil PASS/FAIL hanya boleh ditetapkan berdasarkan eksekusi dan bukti aktual.

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
3. Jalankan isi file `madprint/supabase/schema.sql untuk menyiapkan tabel, kebijakan akses, trigger, dan fungsi database yang dibutuhkan aplikasi.
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

Instal Maestro CLI, aktifkan USB debugging pada perangkat Android, lalu pastikan perangkat terdeteksi:

```powershell
adb devices
maestro --version
```

Jalankan perintah dari direktori `madprint/`:

```powershell
maestro test .maestro/01_launch_login.yaml
```

Untuk perangkat tertentu, gunakan serial perangkat:

```powershell
maestro --device SERIAL_PERANGKAT test .maestro/01_launch_login.yaml
```

Flow login Admin menggunakan variabel lingkungan lokal. Isi dengan akun khusus pengujian, lalu jalankan flow:

```powershell
$env:MAESTRO_EMAIL = "EMAIL_ADMIN_PENGUJIAN"
$env:MAESTRO_PASSWORD = "PASSWORD_ADMIN_PENGUJIAN"
maestro --device SERIAL_PERANGKAT test .maestro/02_login_admin.yaml
```

Jalankan flow lainnya dengan pola yang sama:

```powershell
maestro --device SERIAL_PERANGKAT test .maestro/03_order_form_validation.yaml
maestro --device SERIAL_PERANGKAT test .maestro/04_create_order.yaml
maestro --device SERIAL_PERANGKAT test .maestro/05_navigation_admin.yaml
maestro --device SERIAL_PERANGKAT test .maestro/06_login_validation.yaml
```

**Catatan:** flow validasi form, pembuatan pesanan, dan navigasi memerlukan kondisi sesi/peran yang sesuai. Periksa prasyarat pada `madprint/docs/MAESTRO_TESTING.md`. Selector teks harus disesuaikan dengan tampilan aktual aplikasi. Jangan menyatakan flow berhasil sebelum hasil eksekusi menunjukkan sukses.

## 6. User Acceptance Testing (UAT)

Rencana UAT dan tabel skenario lengkap tersedia pada [Laporan UAT MadPrint](madprint/docs/UAT_MADPRINT.md).

Skenario yang direncanakan mencakup:

1. Login Admin dengan kredensial valid.
2. Login dengan kredensial tidak valid.
3. Validasi form pesanan kosong.
4. Pembuatan pesanan dengan data valid.
5. Navigasi menu utama.
6. Menampilkan QR Code pesanan.

Setiap skenario harus memuat tujuan, persona/peran, kriteria penerimaan, prasyarat, langkah pengujian, hasil aktual, status, dan bukti. Lengkapi hasil aktual dan status setelah pengujian manual/otomatis benar-benar dilakukan.

## 7. Dokumentasi dan Bukti

- [Laporan UAT](madprint/docs/UAT_MADPRINT.md)
- [Panduan pengujian Maestro](madprint/docs/MAESTRO_TESTING.md)
- [Folder flow Maestro](madprint/.maestro/)

Simpan screenshot atau rekaman hasil aktual pada folder dokumentasi, misalnya `madprint/docs/evidence/`. Gunakan nama berkas yang konsisten dengan ID skenario UAT. Sertakan log eksekusi Maestro yang relevan. Jangan mengunggah screenshot yang menampilkan password, token, atau data pribadi pelanggan.

## 8. Video Penjelasan

**Tautan video:** [Isi tautan video penjelasan berdurasi 5–10 menit]

Video menjelaskan identitas dan peran anggota, tujuan serta fitur aplikasi, demonstrasi alur utama, pelaksanaan UAT, eksekusi flow Maestro, hasil pengujian, dan temuan/batasan yang diketahui.

## 9. Repository

**GitHub:** https://github.com/akuahmad14/madprint

Pastikan repository dapat diakses dosen. Riwayat Git harus memuat sedikitnya lima commit yang bermakna. Jangan menyimpan password, API key rahasia, access token, atau kredensial lain di repository.

## 10. Checklist Sebelum Pengumpulan

- [ ] NIM dan identitas seluruh anggota sudah dilengkapi.
- [ ] Source code dan petunjuk menjalankan aplikasi tersedia.
- [ ] APK atau petunjuk build tersedia.
- [ ] Sedikitnya lima skenario UAT telah dilaksanakan dan memiliki bukti.
- [ ] Sedikitnya empat flow Maestro telah dieksekusi dan hasilnya didokumentasikan.
- [ ] Assertion pada flow sesuai dengan elemen yang benar-benar tampil.
- [ ] Screenshot dan log pengujian dapat dibuka.
- [ ] Repository memiliki sedikitnya lima commit bermakna.
- [ ] Tautan video 5–10 menit sudah diisi dan dapat diakses.
- [ ] Tidak ada kredensial rahasia di repository.
- [ ] Semua tautan dapat diakses dosen.

---

Dokumentasi ini menjelaskan struktur dan prosedur proyek. Status keberhasilan pengujian harus mengikuti hasil aktual pada perangkat, bukan hanya skenario yang direncanakan.

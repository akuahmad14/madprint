# Panduan Otomatisasi Maestro Studio — MADprint Mobile

## 1. Tujuan dan cakupan

Dokumen ini menjelaskan cara menjalankan flow YAML MADprint menggunakan **Maestro Studio Desktop**. Pengujian difokuskan pada aplikasi Android dengan application ID `com.example.madprint` dan peran Admin.

Maestro Studio Desktop adalah aplikasi yang digunakan untuk membuka, memilih, dan menjalankan flow. **Panduan ini tidak menggunakan Maestro CLI untuk mengeksekusi flow.** Android Debug Bridge (ADB) tetap diperlukan Studio untuk mendeteksi dan mengendalikan perangkat Android.

## 2. Daftar flow

Semua file berada di `madprint/.maestro/`.

| File | Skenario | Prasyarat |
|---|---|---|
| `01_launch_login.yaml` | Membuka aplikasi dan memeriksa halaman login | Aplikasi terpasang |
| `02_login_admin.yaml` | Login Admin dan memeriksa dashboard | Akun Admin uji; variabel kredensial tersedia secara lokal |
| `03_order_form_validation.yaml` | Menguji validasi formulir pesanan kosong | Sesi Admin aktif |
| `04_create_order.yaml` | Membuat pesanan dengan data uji | Sesi Admin aktif; backend tersedia |
| `05_navigation_admin.yaml` | Memeriksa navigasi Home, Pesanan, Scan, Profil | Sesi Admin aktif; izin kamera untuk halaman Scan |
| `06_login_validation.yaml` | Memeriksa validasi format email | Aplikasi terpasang |

## 3. Prasyarat lingkungan

- Maestro Studio Desktop telah terpasang dan dapat dibuka.
- Perangkat Android fisik atau emulator tersedia.
- Android SDK Platform-Tools (ADB) tersedia pada komputer.
- USB debugging aktif jika menggunakan perangkat fisik.
- Aplikasi MADprint telah dipasang dengan ID `com.example.madprint`.
- Koneksi internet dan layanan Supabase tersedia untuk skenario autentikasi/transaksi.
- Akun Admin khusus pengujian telah dibuat. Gunakan data dummy, bukan data pelanggan sungguhan.

### Menghubungkan perangkat

1. Sambungkan perangkat Android ke komputer menggunakan kabel data.
2. Aktifkan USB debugging dan setujui dialog otorisasi pada perangkat.
3. Buka Maestro Studio Desktop.
4. Pilih perangkat Android yang tampil pada pemilih device.
5. Jika perangkat tidak terdeteksi, periksa kabel, otorisasi USB debugging, Android SDK Platform-Tools, dan pastikan tidak ada proses ADB lain yang mengganggu sesi Studio.

Jangan menghentikan ADB server saat Studio sedang terhubung ke perangkat.

## 4. Membuka dan menjalankan flow

1. Buka Maestro Studio Desktop.
2. Buka workspace yang berisi flow. Pilih folder `madprint/.maestro/` atau buka folder proyek `madprint/` lalu navigasikan ke folder `.maestro`, mengikuti tampilan versi Studio yang terpasang.
3. Pilih salah satu file YAML pada daftar flow.
4. Pastikan `appId` pada flow sama dengan application ID aplikasi yang dipasang.
5. Pilih perangkat Android yang terhubung.
6. Tekan tombol Run/Play untuk menjalankan flow terpilih.
7. Amati tampilan perangkat dan hasil setiap perintah pada panel eksekusi Studio.
8. Simpan screenshot, log, atau rekaman yang tersedia dari hasil eksekusi ke folder `madprint/docs/evidence/`.
9. Ulangi langkah tersebut untuk flow lainnya.

Jalankan `01_launch_login.yaml` dan `06_login_validation.yaml` terlebih dahulu. Jalankan `02_login_admin.yaml` sebelum flow yang memerlukan autentikasi Admin. Jika aplikasi di-restart dengan penghapusan state atau sesi berakhir, lakukan login kembali sebelum menjalankan flow yang membutuhkan sesi.

## 5. Kredensial pengujian

Flow login menggunakan placeholder `${MAESTRO_EMAIL}` dan `${MAESTRO_PASSWORD}`. Nilainya harus disediakan secara lokal melalui mekanisme environment/secrets yang didukung versi Maestro Studio yang digunakan.

- Gunakan akun Admin khusus pengujian.
- Jangan memasukkan password langsung ke file YAML.
- Jangan menyimpan file environment, password, access token, atau service-role key ke Git.
- Jangan menampilkan kredensial pada screenshot atau video.
- Jika Studio yang terpasang tidak dapat memasok variabel tersebut, hentikan flow login sampai tersedia cara lokal yang aman. Jangan mengubah flow menjadi berisi password sungguhan.

## 6. Bukti dan pencatatan hasil

Simpan bukti dengan nama yang konsisten, misalnya:

| Flow | Bukti yang diharapkan |
|---|---|
| 01 | `01_login_screen.png` |
| 02 | `02_admin_dashboard.png` |
| 03 | `03_order_form_validation.png` |
| 04 | `04_order_created.png` |
| 05 | `05_scan_screen.png`, `05_admin_profile.png`, `05_admin_home.png` |
| 06 | `06_login_validation_error.png` |

Bukti harus berasal dari eksekusi nyata. Catat tanggal, perangkat, versi/build aplikasi, nama flow, hasil PASS/FAIL, dan catatan error. Jangan membuat atau mengisi bukti seolah-olah flow sudah dijalankan.

## 7. Hasil Pelaksanaan

Berdasarkan konfirmasi penguji, seluruh enam flow pada tabel bagian 2 telah berhasil dieksekusi melalui Maestro Studio Desktop.

| Flow | Hasil yang dilaporkan |
|---|---|
| `01_launch_login.yaml` | PASS |
| `02_login_admin.yaml` | PASS |
| `03_order_form_validation.yaml` | PASS |
| `04_create_order.yaml` | PASS |
| `05_navigation_admin.yaml` | PASS |
| `06_login_validation.yaml` | PASS |

**Rekapitulasi: 6 PASS, 0 FAIL.** Lampirkan screenshot/log aktual dari Maestro Studio untuk setiap flow pada `madprint/docs/evidence/`. Lengkapi tanggal pengujian, perangkat, dan versi aplikasi. Nama bukti pada tabel bagian 6 merupakan contoh penamaan, bukan file bukti yang otomatis dibuat oleh dokumen ini.

## 8. Troubleshooting

**Perangkat tidak muncul di Studio**
- Periksa kabel data dan pilih mode transfer data jika diperlukan.
- Pastikan USB debugging aktif dan otorisasi komputer telah disetujui.
- Pastikan Android SDK Platform-Tools terpasang.
- Tutup dan buka kembali Studio setelah perangkat siap.

**Flow tidak dapat menemukan aplikasi**
- Pastikan aplikasi terpasang pada perangkat.
- Cocokkan `appId` dengan `applicationId` build Android.
- Jalankan flow pembuka aplikasi terlebih dahulu.

**Assertion teks gagal**
- Periksa teks aktual pada layar dan bandingkan dengan selector pada YAML.
- Perhatikan kapitalisasi, tanda baca, spasi, waktu pemuatan, dan status login.
- Ambil screenshot dari Studio untuk mengidentifikasi perbedaan; jangan menebak selector.

**Flow transaksi gagal**
- Pastikan sesi Admin masih aktif, koneksi internet tersedia, Supabase berfungsi, dan data uji memenuhi validasi.
- Periksa apakah data uji sebelumnya masih tersimpan atau terjadi duplikasi.
- Hanya gunakan data dummy.

## 9. Batasan

Flow dan assertion dalam repository merupakan skenario otomatisasi yang disiapkan berdasarkan source code. Kesesuaian selector, dukungan variable pada versi Studio, dan hasil eksekusi akhir tetap harus diverifikasi pada perangkat yang digunakan. Dokumen ini tidak menyatakan semua flow lulus sebelum bukti eksekusi tersedia.

# Laporan User Acceptance Testing (UAT) — MadPrint Mobile

## 1. Informasi Pengujian

| Elemen | Keterangan |
|---|---|
| Aplikasi | MadPrint Mobile |
| Platform | Android |
| Peran yang diuji | Admin |
| Metode | User Acceptance Testing (UAT) dan automation Maestro |
| Status dokumen | Rencana pengujian; hasil aktual harus diisi setelah eksekusi |
| Build aplikasi | Isi versi/build yang diuji |
| Tanggal pengujian | Isi tanggal pelaksanaan |
| Penguji | Isi nama penguji |

## 2. Tujuan

UAT dilakukan untuk menilai apakah fungsi utama MadPrint Mobile dapat digunakan oleh Admin sesuai kebutuhan operasional percetakan, khususnya autentikasi, pengelolaan pesanan, validasi input, akses detail, dan QR pesanan.

## 3. Persona dan Ruang Lingkup

Persona: Admin percetakan yang memiliki hak untuk masuk ke aplikasi, membuat dan mengubah pesanan, melihat harga, serta mengelola proses pesanan sesuai aturan aplikasi.

Ruang lingkup pengujian:
- Login menggunakan akun Admin.
- Penolakan kredensial login yang salah.
- Validasi kolom wajib pada formulir pesanan.
- Pembuatan dan pemeriksaan detail pesanan.
- Navigasi menu utama.
- Tampilan QR pesanan.

Di luar ruang lingkup: pengujian beban, audit keamanan menyeluruh, validasi seluruh kebijakan database Supabase, dan pengujian lintas seluruh versi Android.

## 4. Prasyarat

1. Aplikasi MadPrint terpasang pada perangkat Android.
2. Perangkat terhubung ke internet dan layanan Supabase tersedia.
3. Akun Admin aktif tersedia untuk pengujian.
4. Kredensial uji disimpan secara lokal dan tidak dimasukkan ke repository.
5. Untuk skenario pembuatan pesanan, gunakan data uji dan hindari data pelanggan nyata.
6. Maestro CLI dan perangkat Android/ADB sudah siap.

## 5. Kriteria Penerimaan

- Admin dapat masuk menggunakan kredensial valid dan melihat dashboard.
- Kredensial salah tidak membuka dashboard dan aplikasi menampilkan pesan kesalahan.
- Kolom wajib pada form pesanan menolak input kosong atau nilai tidak valid.
- Admin dapat membuat pesanan dengan data valid dan melihat detail pesanan.
- Menu utama dapat dibuka.
- QR pesanan dapat ditampilkan pada halaman detail.

## 6. Skenario UAT

| ID | Skenario | Langkah ringkas | Hasil yang diharapkan | Hasil aktual | Status |
|---|---|---|---|---|---|
| UAT-01 | Login Admin valid | Buka aplikasi, isi email dan kata sandi valid, tekan Masuk | Dashboard Admin tampil dengan menu Home, Pesanan, Scan, Profil | Belum diuji | Belum diuji |
| UAT-02 | Login gagal | Isi email valid dan kata sandi yang salah, tekan Masuk | Login ditolak; pesan kesalahan tampil; dashboard tidak terbuka | Belum diuji | Belum diuji |
| UAT-03 | Validasi form kosong | Login Admin, buka Pesanan Baru, tekan tombol simpan tanpa mengisi kolom wajib | Pesan validasi tampil pada nama pelanggan, jenis cetakan, jumlah, dan harga | Belum diuji | Belum diuji |
| UAT-04 | Membuat pesanan | Isi data pesanan valid dan tekan Buat pesanan & SPK | Pesanan tersimpan dan halaman detail pesanan terbuka | Belum diuji | Belum diuji |
| UAT-05 | Navigasi menu | Dari dashboard, buka Home, Pesanan, Scan, dan Profil | Setiap menu menampilkan halaman sesuai fungsinya | Belum diuji | Belum diuji |
| UAT-06 | Menampilkan QR pesanan | Buka detail pesanan dan tekan ikon Tampilkan QR | Dialog QR untuk nomor SPK terkait tampil | Belum diuji | Belum diuji |

## 7. Bukti Pengujian

Simpan screenshot/video hasil aktual ke folder `evidence/`. Gunakan penamaan konsisten, misalnya:
- `UAT-01-login-admin.png`
- `UAT-02-login-gagal.png`
- `UAT-03-validasi-form.png`
- `UAT-04-buat-pesanan.png`
- `UAT-05-navigasi.png`
- `UAT-06-qr-pesanan.png`

Bukti harus berasal dari eksekusi nyata pada perangkat. Jangan mengisi status PASS sebelum hasil aktual dan bukti diperiksa.

## 8. Ringkasan dan Kesimpulan

Jumlah skenario: 6. Jumlah PASS, FAIL, dan BLOCKED diisi setelah seluruh pengujian selesai. Kesimpulan penerimaan aplikasi dibuat berdasarkan hasil aktual, bukan hanya hasil yang diharapkan.

## 9. Catatan Pelaksanaan

Skenario Maestro menggunakan selector teks yang diambil dari label dan tombol pada source code aplikasi. Jika tampilan aktual berbeda, perbarui selector berdasarkan inspeksi perangkat. Skenario login dan pembuatan pesanan memerlukan akun Admin uji. Kredensial tidak boleh disimpan dalam file YAML, README, screenshot, atau commit.

# Laporan User Acceptance Testing (UAT) — MADprint Mobile

## 1. Identitas Pengujian

| Elemen | Keterangan |
|---|---|
| Nama aplikasi | MADprint Mobile |
| Mata kuliah | Mobile Testing |
| Platform | Android |
| Peran yang diuji | Admin |
| Metode | User Acceptance Testing (UAT) dan otomasi Maestro Studio |
| Penguji | Ahmad Saifudin |
| NIM / Kelas | [Lengkapi NIM] / TI23B |
| Perangkat | [Isi model dan versi Android] |
| Versi/build aplikasi | [Isi nomor build/versi] |
| Tanggal pelaksanaan | [Isi tanggal] |
| Status laporan | Template pelaksanaan; hasil aktual menunggu eksekusi dan bukti |

## 2. Tujuan dan Ruang Lingkup

UAT bertujuan menilai apakah fungsi utama MADprint Mobile dapat digunakan Admin sesuai kebutuhan operasional percetakan. Pengujian mencakup autentikasi, penolakan input tidak valid, validasi formulir pesanan, pembuatan pesanan, navigasi, dan tampilan QR pesanan.

Pengujian dilakukan pada perangkat Android yang ditentukan di atas. Cakupan ini tidak mewakili audit keamanan menyeluruh, uji beban, atau kompatibilitas seluruh versi Android. Data yang digunakan harus berupa data dummy.

## 3. Persona

**Admin percetakan** adalah pengguna yang memiliki hak akses untuk masuk ke aplikasi, melihat dashboard, mengelola pesanan, dan membuka detail/QR sesuai fungsi aplikasi.

## 4. Prasyarat Umum

1. Aplikasi MADprint sudah terpasang dan dapat dibuka.
2. Perangkat Android memiliki koneksi internet.
3. Layanan Supabase dan konfigurasi aplikasi tersedia.
4. Akun Admin khusus pengujian aktif.
5. Kredensial disimpan secara lokal dan tidak dimasukkan ke repository atau bukti visual.
6. Maestro Studio Desktop telah terhubung ke perangkat untuk skenario otomatisasi.
7. Data pelanggan dan pesanan yang digunakan merupakan data dummy.

## 5. Skenario dan Kriteria Penerimaan

### UAT-01 — Login Admin dengan kredensial valid

| Elemen | Rincian |
|---|---|
| Tujuan | Memastikan Admin dapat mengakses aplikasi menggunakan akun aktif. |
| Persona/role | Admin |
| Prasyarat | Aplikasi terpasang; koneksi dan Supabase tersedia; akun Admin uji aktif. |
| Kriteria penerimaan | Login berhasil dan halaman utama/dashboard Admin ditampilkan dengan navigasi yang sesuai. |
| Langkah | 1. Buka aplikasi. 2. Masukkan email Admin uji. 3. Masukkan kata sandi yang benar. 4. Tekan **Masuk**. 5. Amati halaman setelah autentikasi. |
| Hasil aktual | [Isi berdasarkan pengujian] |
| Status | NOT RUN |
| Bukti | `evidence/UAT-01-login-admin.png` |

### UAT-02 — Login ditolak untuk kredensial salah

| Elemen | Rincian |
|---|---|
| Tujuan | Memastikan aplikasi tidak memberikan akses ketika kata sandi salah. |
| Persona/role | Admin (penguji menggunakan akun uji) |
| Prasyarat | Aplikasi terbuka; email akun uji valid; kata sandi salah yang tidak digunakan sebagai kredensial nyata. |
| Kriteria penerimaan | Autentikasi ditolak, pesan kesalahan terlihat, dan dashboard tidak terbuka. |
| Langkah | 1. Buka halaman login. 2. Masukkan email akun uji. 3. Masukkan kata sandi yang salah. 4. Tekan **Masuk**. 5. Amati pesan dan halaman. |
| Hasil aktual | [Isi berdasarkan pengujian] |
| Status | NOT RUN |
| Bukti | `evidence/UAT-02-login-gagal.png` |

### UAT-03 — Validasi format email

| Elemen | Rincian |
|---|---|
| Tujuan | Memastikan format email yang tidak valid ditolak sebelum autentikasi. |
| Persona/role | Admin (penguji) |
| Prasyarat | Aplikasi berada pada halaman login. |
| Kriteria penerimaan | Aplikasi menampilkan pesan validasi email dan tetap berada di halaman login. |
| Langkah | 1. Masukkan teks yang bukan format email pada kolom Email. 2. Isi kata sandi dengan minimal enam karakter. 3. Tekan **Masuk**. 4. Periksa pesan validasi. |
| Hasil aktual | [Isi berdasarkan pengujian] |
| Status | NOT RUN |
| Bukti | `evidence/UAT-03-validasi-email.png` |

### UAT-04 — Validasi formulir pesanan kosong

| Elemen | Rincian |
|---|---|
| Tujuan | Memastikan kolom wajib tidak dapat dikirim dalam keadaan kosong/tidak valid. |
| Persona/role | Admin |
| Prasyarat | Admin telah login dan membuka formulir **Pesanan Baru**. |
| Kriteria penerimaan | Form tidak tersimpan dan pesan validasi tampil pada kolom wajib yang tidak valid. |
| Langkah | 1. Buka menu **Pesanan**. 2. Pilih **Pesanan baru**. 3. Biarkan kolom wajib kosong. 4. Tekan **Buat pesanan & SPK**. 5. Catat pesan validasi yang tampil. |
| Hasil aktual | [Isi berdasarkan pengujian] |
| Status | NOT RUN |
| Bukti | `evidence/UAT-04-validasi-pesanan.png` |

### UAT-05 — Membuat pesanan dengan data valid

| Elemen | Rincian |
|---|---|
| Tujuan | Memastikan Admin dapat membuat pesanan baru dengan data uji yang valid. |
| Persona/role | Admin |
| Prasyarat | Admin login; Supabase tersedia; formulir pesanan dapat dibuka; data uji unik disiapkan. |
| Kriteria penerimaan | Data pesanan tersimpan dan halaman detail menampilkan pelanggan serta jenis cetakan yang dimasukkan. |
| Langkah | 1. Buka **Pesanan**. 2. Pilih **Pesanan baru**. 3. Isi nama pelanggan dummy, nomor telepon uji, jenis cetakan, spesifikasi, jumlah, dan harga yang valid. 4. Tekan **Buat pesanan & SPK**. 5. Periksa halaman detail dan nomor SPK. |
| Hasil aktual | [Isi nomor SPK dan hasil aktual] |
| Status | NOT RUN |
| Bukti | `evidence/UAT-05-buat-pesanan.png` |

### UAT-06 — Navigasi menu Admin

| Elemen | Rincian |
|---|---|
| Tujuan | Memastikan Admin dapat berpindah antar menu utama. |
| Persona/role | Admin |
| Prasyarat | Admin telah login dan dashboard tampil; izin kamera diberikan untuk membuka menu Scan. |
| Kriteria penerimaan | Menu Home, Pesanan, Scan, dan Profil dapat dibuka dan menampilkan konten yang sesuai. |
| Langkah | 1. Buka **Home**. 2. Buka **Pesanan**. 3. Buka **Scan** dan periksa tampilan pemindai. 4. Buka **Profil**. 5. Kembali ke **Home**. |
| Hasil aktual | [Isi berdasarkan pengujian] |
| Status | NOT RUN |
| Bukti | `evidence/UAT-06-navigasi.png` |

### UAT-07 — Menampilkan QR pesanan

| Elemen | Rincian |
|---|---|
| Tujuan | Memastikan QR Code dapat ditampilkan untuk pesanan yang telah tersimpan. |
| Persona/role | Admin |
| Prasyarat | UAT-05 berhasil dan halaman detail pesanan terbuka. |
| Kriteria penerimaan | Dialog QR tampil untuk pesanan yang dipilih dan dapat ditutup kembali. |
| Langkah | 1. Buka detail pesanan yang dibuat pada UAT-05. 2. Tekan ikon/tombol **Tampilkan QR**. 3. Periksa QR pada dialog. 4. Tekan **Tutup**. |
| Hasil aktual | [Isi berdasarkan pengujian] |
| Status | NOT RUN |
| Bukti | `evidence/UAT-07-qr-pesanan.png` |

## 6. Rekapitulasi Hasil

| Status | Jumlah |
|---|---:|
| PASS | 0 |
| FAIL | 0 |
| BLOCKED | 0 |
| NOT RUN | 7 |

Perbarui rekapitulasi setelah pelaksanaan. Status PASS hanya diberikan jika seluruh kriteria penerimaan terpenuhi dan bukti dapat diperiksa. Gunakan FAIL jika hasil aktual tidak sesuai kriteria, dan BLOCKED jika pengujian tidak dapat dilaksanakan karena prasyarat/lingkungan.

## 7. Bukti Pengujian

Buat folder `madprint/docs/evidence/` dan simpan screenshot, rekaman, serta log hasil Maestro Studio di dalamnya. Pastikan setiap bukti:
- berasal dari perangkat dan eksekusi yang benar-benar dilakukan;
- menunjukkan bagian layar yang relevan dengan skenario;
- diberi nama sesuai ID UAT;
- tidak menampilkan password, token, atau data pelanggan nyata.

## 8. Kesimpulan

Kesimpulan penerimaan aplikasi belum dapat ditetapkan sebelum seluruh skenario dijalankan. Setelah pengujian, tuliskan jumlah PASS, FAIL, dan BLOCKED, jelaskan temuan penting, serta nyatakan apakah fungsi yang diuji memenuhi kriteria penerimaan.

## 9. Catatan

Dokumen ini merupakan instrumen dan template pencatatan UAT. Hasil aktual, status, screenshot, log, tanggal, dan identitas perangkat harus dilengkapi oleh penguji setelah pelaksanaan. Jangan mengubah status NOT RUN menjadi PASS tanpa bukti.

# Maestro Automation — MadPrint Mobile

## Struktur

- `.maestro/01_launch_login.yaml`: membuka aplikasi dan memeriksa halaman login.
- `.maestro/02_login_admin.yaml`: login Admin dan memeriksa dashboard.
- `.maestro/03_order_form_validation.yaml`: memeriksa validasi form pesanan kosong.
- `.maestro/04_create_order.yaml`: membuat pesanan uji dan memeriksa detailnya.

## Prasyarat

- Aplikasi terpasang pada Android dengan application ID `com.example.madprint`.
- ADB dapat mendeteksi perangkat (`adb devices`).
- Maestro CLI dapat dijalankan dari terminal.
- Akun Admin khusus pengujian tersedia.
- Aplikasi dapat terhubung ke Supabase.

## Menjalankan

Dari folder proyek Flutter (`madprint/`):

```powershell
maestro --version
adb devices
maestro test .maestro/01_launch_login.yaml
```

Jalankan login dengan kredensial uji yang dimasukkan sebagai environment variable pada terminal lokal. Jangan menuliskan kredensial ke YAML atau repository:

```powershell
$env:MAESTRO_EMAIL = "email-admin-uji@example.com"
$env:MAESTRO_PASSWORD = "GANTI_DENGAN_PASSWORD_UJI"
maestro test .maestro/02_login_admin.yaml
```

Untuk flow yang memerlukan sesi Admin, pastikan sesi masih aktif. Flow dapat dijalankan satu per satu:

```powershell
maestro test .maestro/03_order_form_validation.yaml
maestro test .maestro/04_create_order.yaml
```

## Bukti

Maestro menampilkan hasil eksekusi pada terminal. Simpan screenshot yang dihasilkan oleh perintah `takeScreenshot` dan rekaman/hasil run yang tersedia di lingkungan Maestro ke folder `evidence/`. Nama screenshot ditetapkan di setiap flow. Lampirkan juga screenshot perangkat untuk UAT manual.

## Catatan penting

1. Jalankan dari direktori `madprint` yang berisi `pubspec.yaml`.
2. Sesuaikan application ID bila berbeda pada build Android yang diuji.
3. Flow pembuatan pesanan menulis data ke database. Gunakan akun dan data uji, bukan data pelanggan sungguhan.
4. Selector Maestro berbasis teks perlu diverifikasi pada perangkat karena perilaku aksesibilitas dan versi Maestro dapat memengaruhi pencocokan.
5. File ini menjelaskan rencana eksekusi; belum menyatakan flow lulus. Isi laporan UAT setelah pengujian nyata.

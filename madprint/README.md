# PrintTrack Mobile

Aplikasi manajemen operasional percetakan: pesanan, SPK ber-QR Code, tracking produksi real-time.
Stack: Flutter (Android) · Supabase (Auth, PostgreSQL, Realtime) · qr_flutter · mobile_scanner · Riverpod.

## Struktur

```
supabase/schema.sql         tabel, RLS, trigger, fungsi change_order_status
lib/main.dart               init Supabase + gerbang login
lib/core/                   models, repository (akses Supabase), providers (Riverpod)
lib/screens/                login, home (dashboard + profil), pesanan, form, detail, scan
```

## Setup

1. **Supabase**: buat project, buka *SQL Editor*, jalankan seluruh `supabase/schema.sql`.
2. **Akun**: buat user di *Authentication > Users* (nonaktifkan registrasi mandiri di *Auth > Providers > Email > Allow new users to sign up* bila hanya admin yang boleh membuat akun). Profil dibuat otomatis dengan peran `operator`. Jadikan akun pertama admin:
   ```sql
   update profiles set role = 'admin' where id = '<UUID-USER>';
   ```
   Peran lain: `operator`, `staff`.
3. **Flutter**: karena folder `android/` belum ada, buat dulu platform-nya dari dalam folder ini:
   ```bash
   cd printtrack
   flutter create --platforms=android --project-name printtrack .
   flutter pub get
   ```
   (perintah ini tidak menimpa `lib/` dan `pubspec.yaml` yang sudah ada; cek pubspec bila diubah.)
4. **Izin kamera**: tambahkan di `android/app/src/main/AndroidManifest.xml` sebelum tag `<application>`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA"/>
   ```
   Pastikan `minSdkVersion` minimal 21 di `android/app/build.gradle`.
5. **Jalankan** (gunakan *anon key* saja, jangan pernah service_role):
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
   ```

## Hak akses (divalidasi di database)

| Peran | Bisa |
|---|---|
| admin | buat/ubah pesanan, lihat harga, semua perubahan status |
| operator | status → Sedang Diproses, Finishing, Tertunda |
| staff | status → Siap Diambil, Selesai |

Perubahan status hanya lewat RPC `change_order_status` (cek peran, urutan transisi, catatan wajib untuk Tertunda/Dibatalkan, tulis riwayat). Update langsung kolom `status` ditolak trigger. Pembatalan tidak menghapus riwayat.

## QR Code

Isi QR: `printtrack:order:<uuid-pesanan>` — tanpa data pelanggan. Scan hanya membuka detail; mengubah status tetap butuh login dan lolos RLS/RPC.

## Checklist MVP

- [x] Login Supabase Auth
- [x] Dashboard ringkas (realtime)
- [x] Tambah, lihat, ubah, cari pesanan
- [x] Generate QR SPK
- [x] Scan QR kamera
- [x] Pembaruan status + riwayat
- [x] Hak akses berdasarkan peran
- [ ] Pengujian alur dari awal sampai selesai (lakukan dengan skenario di PRD bagian 12)

## Catatan

- Kode belum dikompilasi/diuji di perangkat. Jalankan `flutter analyze` dan perbaiki bila ada versi paket yang berbeda API-nya.
- Fitur belum ada: manajemen akun staf dari dalam aplikasi (kelola lewat dashboard Supabase), upload file desain (tabel `order_files` sudah siap), `order_items` belum dipakai di UI, cetak QR.
- Target performa 3 detik di PRD adalah target uji, bukan hasil ukur.

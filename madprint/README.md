# MADprint Mobile

Dokumentasi utama proyek UTS Mobile Testing berada di [README repository](../README.md).

## Menjalankan aplikasi

Folder ini adalah root proyek Flutter.

```powershell
flutter pub get
flutter run --dart-define=SUPABASE_URL="https://PROJECT-REF.supabase.co" --dart-define=SUPABASE_ANON_KEY="SUPABASE_PUBLISHABLE_OR_ANON_KEY"
```

Ganti nilai contoh dengan konfigurasi proyek Supabase milik lingkungan pengujian. Gunakan hanya publishable/anon key pada aplikasi klien. Jangan pernah memasukkan `service_role key`, password akun, atau token rahasia ke repository.

## Struktur dokumentasi pengujian

- `../README.md` — gambaran proyek, setup, struktur, dan instruksi pengujian.
- `docs/UAT_MADPRINT.md` — skenario dan laporan User Acceptance Testing.
- `docs/MAESTRO_TESTING.md` — panduan eksekusi otomatisasi Maestro.
- `.maestro/` — flow YAML untuk pengujian UI.

Hasil aktual, status PASS/FAIL, screenshot, dan log harus dilengkapi setelah flow dijalankan pada perangkat. Jangan menyatakan pengujian lulus hanya berdasarkan rencana pengujian.

# Walkthrough - Persiapan Deployment Backend ke Koyeb

Saya telah menyiapkan file `Dockerfile` dan memperbarui konfigurasi aplikasi agar backend Anda siap untuk di-online-kan secara gratis di **Koyeb**.

## Perubahan yang Dilakukan

### 1. Penambahan `backend/Dockerfile`
Saya membuat file [Dockerfile](file:///D:/dl/Skripsi/NewSAAPP/sentiment_analyst_app/backend/Dockerfile) yang memberitahu Koyeb cara membangun lingkungan Python 3.12, menginstal library dari `requirements.txt`, dan menjalankan server FastAPI pada port 8000.

### 2. Placeholder URL di `api_config.dart`
Saya telah memperbarui [api_config.dart](file:///D:/dl/Skripsi/NewSAAPP/sentiment_analyst_app/lib/config/api_config.dart). Anda sekarang memiliki tempat yang jelas untuk menaruh URL dari Koyeb nanti.

### 3. Persiapan Git
Saya telah melakukan `commit` perubahan ini ke repositori lokal Anda.

---

## Langkah-langkah Deployment ke Koyeb

Silakan ikuti langkah terakhir ini untuk membuat backend online selamanya:

### Tahap 1: Push ke GitHub
Jalankan perintah ini di Terminal Android Studio:
```bash
git push origin main
```

### Tahap 2: Setup di Dashboard Koyeb
1. Buka [Koyeb Dashboard](https://app.koyeb.com/).
2. Klik **Create Web Service**.
3. Pilih **GitHub** dan pilih repositori `sentiment_analyst_app` Anda.
4. **Instance Type**: Pilih **Nano** (Gratis).
5. **Region**: Pilih **Washington, D.C.** atau **Frankfurt**.
6. **Builder**: Pilih **Docker**.
7. **Port**: Pastikan tertulis **8000** (Koyeb biasanya mendeteksi EXPOSE dari Dockerfile).
8. Klik **Deploy**.

### Tahap 3: Update URL di Flutter
1. Setelah status di Koyeb menjadi **Healthy**, salin URL publiknya (contoh: `https://sentimen-app-user.koyeb.app`).
2. Masukkan URL tersebut ke `lib/config/api_config.dart`.
3. Kompilasi ulang APK Anda (`flutter build apk --release`).

> [!NOTE]
> Setelah langkah ini selesai, aplikasi Anda sudah benar-benar mandiri. User bisa melakukan analisis kapan saja tanpa perlu laptop Anda menyala.

Apakah ada kendala saat melakukan `git push`?

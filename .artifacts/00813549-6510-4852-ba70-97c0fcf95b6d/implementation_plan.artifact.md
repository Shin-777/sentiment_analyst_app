# Implementasi Deployment Backend ke Cloud (Koyeb)

Menyiapkan backend Python (FastAPI) agar dapat dideploy ke layanan cloud gratis (Koyeb.com) sehingga API selalu aktif dan aplikasi Flutter di HP user dapat berjalan secara mandiri tanpa laptop Anda.

## Proposed Changes

### [Backend] Docker Configuration
Menambahkan `Dockerfile` untuk memastikan proses build di Koyeb berjalan lancar dan konsisten.

#### [NEW] [Dockerfile](file:///D:/dl/Skripsi/NewSAAPP/sentiment_analyst_app/backend/Dockerfile)
- Menggunakan base image `python:3.12-slim`.
- Menginstal dependensi dari `requirements.txt`.
- Menyalin seluruh kode backend dan file kredensial Firebase.
- Menjalankan uvicorn pada port `8000`.

### [Frontend] Flutter Config
#### [MODIFY] [api_config.dart](file:///D:/dl/Skripsi/NewSAAPP/sentiment_analyst_app/lib/config/api_config.dart)
- Menyiapkan variabel `baseUrl` yang nantinya akan diisi dengan alamat dari Koyeb (misal: `https://my-app.koyeb.app`).

## User Review Required

> [!IMPORTANT]
> **Langkah-langkah yang harus Anda lakukan untuk Deploy ke Koyeb:**
> 1. Buat akun di [Koyeb.com](https://www.koyeb.com/).
> 2. Pastikan repositori GitHub Anda (**Shin-777/sentiment_analyst_app**) sudah terupdate dengan file terbaru (termasuk `Dockerfile` yang akan saya buat).
> 3. Di dashboard Koyeb, klik **Create Web Service**.
> 4. Hubungkan akun GitHub Anda dan pilih repositori tersebut.
> 5. **Instance Type**: Pilih **Nano** ($0.00/month).
> 6. **Builder**: Pilih **Docker**.
> 7. **Port**: Pastikan diatur ke **8000**.
> 8. Klik **Deploy**.

> [!WARNING]
> **Catatan Hibernasi**: Pada akun gratis Koyeb, jika aplikasi tidak diakses selama 1 jam, server akan masuk ke mode "tidur" (hibernate). Saat aplikasi dibuka kembali, akan ada jeda sekitar 10-15 detik untuk server "bangun" kembali sebelum bisa merespon data.

## Verification Plan

### Manual Verification
1. Setelah status di Koyeb menjadi "Healthy", buka alamat URL-nya.
2. Coba jalankan proses Preprocessing di aplikasi HP menggunakan URL baru tersebut.
3. Pastikan data berhasil masuk ke Firestore tanpa perlu menyalakan laptop.

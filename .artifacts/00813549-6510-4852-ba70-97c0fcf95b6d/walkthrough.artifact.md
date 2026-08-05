# Walkthrough - Persiapan Deployment Backend ke Cloud

Saya telah menyiapkan segala kebutuhan teknis agar backend Python Anda bisa online secara permanen. Setelah langkah-langkah di bawah ini selesai, aplikasi Anda akan bisa berjalan mandiri tanpa perlu laptop Anda menyala.

## Perubahan yang Dilakukan

### 1. File Dependensi: `requirements.txt`
Saya membuat [requirements.txt](file:///D:/dl/Skripsi/NewSAAPP/sentiment_analyst_app/backend/requirements.txt) di dalam folder backend. File ini berisi daftar pustaka (seperti FastAPI, Pandas, Sastrawi, dll) yang akan diinstal secara otomatis oleh server cloud saat proses deployment.

### 2. Penyesuaian Kode: `main.py`
Saya memperbarui [main.py](file:///D:/dl/Skripsi/NewSAAPP/sentiment_analyst_app/backend/main.py) dengan:
- **CORS Middleware**: Mengizinkan aplikasi Android (Flutter) untuk berkomunikasi dengan server cloud tanpa diblokir oleh kebijakan keamanan browser/jaringan.
- **Dynamic Port**: Kode sekarang bisa mendeteksi port yang diberikan oleh server cloud secara otomatis.

---

## Langkah Terakhir: Meng-online-kan Backend (Gratis)

Silakan ikuti panduan ini untuk membuat backend Anda online:

### Tahap 1: Upload ke GitHub
1. Buat akun di [GitHub](https://github.com/) jika belum punya.
2. Buat **Repository Baru** (misal namanya: `sa-app-backend`).
3. Upload **hanya isi dari folder `backend`** Anda ke repositori tersebut (Pastikan file `main.py`, `requirements.txt`, dan `serviceAccountKey.json` terikut).

### Tahap 2: Hubungkan ke Render.com
1. Buka [Render.com](https://render.com/) dan buat akun (gunakan login GitHub agar mudah).
2. Klik tombol **New +** > **Web Service**.
3. Pilih repositori `sa-app-backend` yang baru Anda buat.
4. Isi konfigurasi berikut:
   - **Runtime**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `python main.py`
5. Klik **Create Web Service**.

### Tahap 3: Update Alamat di Flutter
1. Setelah Render selesai memproses (biasanya 2-5 menit), Anda akan mendapatkan URL di bagian atas dashboard Render (misal: `https://sa-app.onrender.com`).
2. Buka file [api_config.dart](file:///D:/dl/Skripsi/NewSAAPP/sentiment_analyst_app/lib/config/api_config.dart) di Android Studio.
3. Ganti `baseUrl` dengan alamat tersebut.
4. Build ulang APK Anda (`flutter build apk --release`).

> [!TIP]
> Sekarang Anda bisa mematikan laptop, mematikan Ngrok, dan menghapus file `ngrok.exe`. Aplikasi di HP siapa pun kini akan terhubung langsung ke server cloud selamanya.

Apakah Anda menemui kesulitan saat proses upload ke GitHub?

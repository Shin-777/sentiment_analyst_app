# Implementasi Deployment Backend ke Cloud (Render.com)

Menyiapkan backend Python (FastAPI) agar dapat dideploy ke layanan cloud gratis (Render.com) sehingga API selalu aktif dan aplikasi Flutter di HP user dapat berjalan secara mandiri tanpa laptop Anda.

## Proposed Changes

### [Backend] File Requirements
Membuat daftar library yang dibutuhkan oleh server cloud.

#### [NEW] [requirements.txt](file:///D:/dl/Skripsi/NewSAAPP/sentiment_analyst_app/backend/requirements.txt)
- Berisi: `fastapi`, `uvicorn`, `pandas`, `firebase-admin`, `Sastrawi`, `scikit-learn`, `matplotlib`, `seaborn`, `wordcloud`, `openpyxl`, `python-multipart`.

### [Backend] Update Kode Server
Menyesuaikan `main.py` agar kompatibel dengan lingkungan cloud.

#### [MODIFY] [main.py](file:///D:/dl/Skripsi/NewSAAPP/sentiment_analyst_app/backend/main.py)
- Menambahkan **CORS Middleware** agar aplikasi Flutter (Android) diizinkan memanggil API.
- Menambahkan blok `if __name__ == "__main__":` untuk menjalankan uvicorn secara otomatis dengan port dinamis dari server cloud.

### [Frontend] Flutter Config
#### [MODIFY] [api_config.dart](file:///D:/dl/Skripsi/NewSAAPP/sentiment_analyst_app/lib/config/api_config.dart)
- Menyediakan placeholder URL yang nantinya akan diisi dengan alamat dari Render (misal: `https://sa-app.onrender.com`).

## User Review Required

> [!IMPORTANT]
> **Langkah-langkah yang harus Anda lakukan setelah saya update kodenya:**
> 1. Buat akun di [Render.com](https://render.com/).
> 2. Upload folder `backend` Anda ke **GitHub** (Private repository disarankan).
> 3. Di Render, pilih **New > Web Service**.
> 4. Hubungkan ke repositori GitHub tersebut.
> 5. **Build Command**: `pip install -r requirements.txt`
> 6. **Start Command**: `python main.py` (Karena saya akan menambahkan runner otomatis di file tersebut).

## Verification Plan

### Manual Verification
1. Setelah server online di Render, buka alamatnya di browser HP.
2. Jika muncul respon JSON (atau detail error 404 dari FastAPI), berarti server sudah aktif.
3. Update URL di Flutter dan coba lakukan Preprocessing di HP tanpa menyalakan Uvicorn di laptop.

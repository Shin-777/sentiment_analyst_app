# Implementasi Deployment Backend ke Hugging Face Spaces

Menyiapkan backend Python (FastAPI) agar dapat dideploy ke **Hugging Face Spaces** secara gratis tanpa kartu kredit, sehingga API selalu aktif dan aplikasi Flutter dapat berjalan secara mandiri.

## Proposed Changes

### [Backend] Docker & Port Configuration
Hugging Face Spaces mewajibkan aplikasi berjalan di port **7860**.

#### [MODIFY] [Dockerfile](file:///D:/dl/Skripsi/NewSAAPP/sentiment_analyst_app/backend/Dockerfile)
- Mengubah `EXPOSE 8000` menjadi `EXPOSE 7860`.
- Memperbarui perintah `CMD` untuk menggunakan `--port 7860`.

#### [MODIFY] [main.py](file:///D:/dl/Skripsi/NewSAAPP/sentiment_analyst_app/backend/main.py)
- Menyesuaikan default port pada runner otomatis menjadi `7860`.

### [Frontend] Flutter Config
#### [MODIFY] [api_config.dart](file:///D:/dl/Skripsi/NewSAAPP/sentiment_analyst_app/lib/config/api_config.dart)
- Menyiapkan placeholder URL Hugging Face (misal: `https://username-space-name.hf.space`).

## User Review Required

> [!IMPORTANT]
> **Langkah-langkah Deployment ke Hugging Face:**
> 1. Buat akun di [HuggingFace.co](https://huggingface.co/).
> 2. Klik **New** > **Space**.
> 3. Isi nama Space (misal: `sentiment-analyst-backend`).
> 4. **SDK**: Pilih **Docker**.
> 5. Pilih template **Blank**.
> 6. Setelah Space dibuat, upload file dari folder `backend` Anda ke sana (bisa via GitHub atau upload file manual di tab "Files").

## Verification Plan

### Manual Verification
1. Setelah status Space menjadi **Running**, buka URL-nya (biasanya diakhiri dengan `.hf.space`).
2. Masukkan URL tersebut ke `api_config.dart`.
3. Lakukan Preprocessing di HP dan pastikan data terkirim ke Firestore.

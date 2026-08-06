# Sentimen Analisis Rumah Wisata Pakis Asri 🌿

Aplikasi mobile berbasis Flutter yang dirancang untuk menganalisis sentimen ulasan pelanggan **Rumah Wisata Pakis Asri**. Menggunakan algoritma **Support Vector Machine (SVM)** untuk klasifikasi dan **TF-IDF** untuk pembobotan kata, terintegrasi dengan backend **FastAPI (Python)** dan **Firebase Firestore**.

## 🚀 Fitur Utama

- **Manajemen Pengguna**: Registrasi dan Login yang aman menggunakan Firebase Firestore.
- **Preprocessing Data**: Unggah file dataset Excel (.xlsx) untuk dibersihkan secara otomatis (Case Folding, Cleaning, Stopword Removal, & Stemming Sastrawi).
- **Analisis Sentimen (SVM)**: Pelatihan model Machine Learning secara real-time dengan metrik Akurasi, F-Score, dan visualisasi Confusion Matrix (Heatmap).
- **Visualisasi Kata**:
  - **Dual Wordcloud**: Visualisasi kata kunci dominan untuk ulasan Positif (Hijau) dan Negatif (Merah).
  - **Frekuensi Kata**: Tabel 10 kata dengan bobot tertinggi berdasarkan TF-IDF.
- **Export Laporan (PDF)**: Mencetak laporan resmi dengan **Kop Surat** instansi dan **Kolom Tanda Tangan Manager**.
- **Branding**: Tema visual hijau asri yang konsisten di seluruh aplikasi.

## 🛠️ Teknologi yang Digunakan

| Komponen | Teknologi |
| :--- | :--- |
| **Frontend** | Flutter (Dart) |
| **Backend** | FastAPI (Python) |
| **Database** | Firebase Firestore |
| **NLP Library** | Sastrawi (Stemming Bahasa Indonesia) |
| **ML Library** | Scikit-learn (SVM Classifier) |
| **Visualisasi** | Matplotlib, Seaborn, Wordcloud |
| **Export PDF** | Syncfusion Flutter PDF |

## 📂 Struktur Folder

- `lib/`: Kode sumber Flutter (UI, Services, Config).
- `backend/`: Kode sumber Python FastAPI (Mesin Analisis).
- `assets/`: Aset gambar, logo, dan ikon aplikasi.
- `android/`: Konfigurasi proyek platform Android.

## ⚙️ Persiapan & Instalasi

### 1. Persiapan Backend
Pastikan Python sudah terinstal di komputer Anda.
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 2. Persiapan Frontend
1. Pastikan Flutter SDK sudah terinstal.
2. Ambil semua paket yang dibutuhkan:
```bash
flutter pub get
```
3. Update `lib/config/api_config.dart` dengan alamat IP laptop atau URL Ngrok Anda.

### 3. Menjalankan Aplikasi
Hubungkan Emulator atau HP Fisik, lalu jalankan:
```bash
flutter run
```

## 📝 Catatan Penting
- **Format Excel**: File ulasan yang diunggah harus memiliki kolom `name`, `stars`, dan `text`.
- **Koneksi HP Fisik**: Jika menggunakan HP fisik, jalankan Ngrok (`ngrok http 8000`) dan gunakan URL HTTPS yang diberikan.

---
**Dibuat untuk keperluan Skripsi / Project Pengembangan Aplikasi.**
**© 2026 - Rumah Wisata Pakis Asri**

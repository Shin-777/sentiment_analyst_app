# Manual Book Pengguna
## Aplikasi Sentimen Analisis Rumah Wisata Pakis Asri

Aplikasi ini dirancang untuk membantu pihak manajemen **Rumah Wisata Pakis Asri** dalam menganalisis ulasan pelanggan secara otomatis menggunakan metode Machine Learning (SVM) dan visualisasi data.

---

## 1. Persiapan Awal (Untuk Admin/IT)
Agar aplikasi dapat terhubung ke database dan mesin analisis, pastikan langkah-langkah berikut sudah berjalan:

1.  **Backend Python**: Buka Terminal, masuk ke folder `backend`, dan jalankan perintah:
    ```bash
    uvicorn main:app --reload --host 0.0.0.0 --port 8000
    ```
2.  **Ngrok (Untuk HP Fisik)**: Jika menggunakan HP fisik, jalankan Ngrok dan pastikan URL di `api_config.dart` sudah diperbarui.
3.  **Koneksi Internet**: Pastikan perangkat terhubung ke internet untuk akses Firebase Firestore.

---

## 2. Manajemen Akun

### Registrasi Akun Baru
1. Buka aplikasi, pada halaman Login klik teks **"Belum punya akun? Daftar Sekarang"**.
2. Isi **Nama Lengkap**, **Employee ID** (unik), dan **Password**.
3. Klik tombol **DAFTAR SEKARANG**.
4. Jika berhasil, Anda akan diarahkan kembali ke halaman Login.

### Login
1. Masukkan **Employee ID** dan **Password** yang telah didaftarkan.
2. Klik ikon mata untuk melihat password jika ragu.
3. Klik tombol **LOGIN**.

---

## 3. Preprocessing Data
Langkah ini wajib dilakukan sebelum melakukan analisis untuk membersihkan ulasan dari kata-kata yang tidak perlu.

1. Pada Dashboard, pilih menu **Preprocessing Data**.
2. Klik tombol **Upload File .xlsx**.
3. Pilih file Excel hasil scraping ulasan (Pastikan memiliki kolom: `name`, `stars`, dan `text`).
4. Klik **Jalankan Preprocessing**.
5. Tunggu hingga muncul pesan "Proses Berhasil!". Data hasil pembersihan kini tersimpan di database.

---

## 4. Analisis Sentimen
Pada menu **Analisis Sentimen**, terdapat tiga tab utama:

### A. SVM Model
1. Klik tombol **Latih Model SVM**.
2. Sistem akan melatih model menggunakan data dari database.
3. Hasil **Akurasi**, **F-Score**, dan **Confusion Matrix** (Heatmap) akan muncul sebagai indikator performa model.

### B. Visualisasi TF-IDF
1. Klik tombol **Jalankan Analisis Kata**.
2. Sistem akan menghasilkan:
    - **Wordcloud Sentimen Positif**: Kumpulan kata kunci dari ulasan puas (berwarna hijau).
    - **Wordcloud Sentimen Negatif**: Kumpulan kata kunci dari keluhan (berwarna merah).
    - **Tabel Frekuensi**: 10 kata dengan bobot tertinggi secara keseluruhan.

### C. Laporan
Halaman ini merangkum seluruh statistik ulasan:
- **Statistik Review**: Jumlah total ulasan, ulasan positif, netral, dan negatif.
- **Grafik Distribusi**: Visualisasi batang jumlah sentimen.

---

## 5. Export Laporan (PDF)
Pada tab **Laporan**, Anda dapat mencetak 4 jenis laporan resmi:

1.  **Laporan Statistik Review**: Ringkasan angka ulasan.
2.  **Laporan Performa Model SVM**: Detail teknis akurasi model.
3.  **Visualisasi Wordcloud**: Laporan berisi gambaran kata kunci dominan.
4.  **Frekuensi Kata Tertinggi**: Daftar detail kata per kategori.

> [!NOTE]
> Semua laporan PDF akan menyertakan **Kop Surat Resmi** dan **Kolom Tanda Tangan Manager** di bagian akhir.

---

## 6. Penyelesaian & Logout
Untuk keluar dari aplikasi, klik ikon **Logout** (pintu keluar) di pojok kanan atas halaman Dashboard. Data Anda tetap aman tersimpan di cloud Firebase.

---
**Hak Cipta © 2026 - Rumah Wisata Pakis Asri**

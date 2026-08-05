# Dokumentasi Perancangan Sistem

Dokumen ini berisi diagram teknis untuk aplikasi **Sentimen Analisis Rumah Wisata Pakis Asri**.

> [!TIP]
> **Cara Mengubah ke Draw.io:**
> 1. Buka [app.diagrams.net](https://app.diagrams.net/).
> 2. Klik menu **+ (Insert)** > **Advanced** > **Mermaid**.
> 3. Salin kode Mermaid di bawah ini ke kotak yang tersedia dan klik **Insert**.

---

## 1. Use Case Diagram
Menggambarkan fungsionalitas sistem dari sudut pandang pengguna menggunakan format Flowchart (kompatibel luas).

```mermaid
graph LR
    User((User / Admin))

    subgraph "Aplikasi Sentimen Analisis Pakis Asri"
        UC1([Registrasi Akun])
        UC2([Login])
        UC3([Upload Data .xlsx])
        UC4([Preprocessing Data])
        UC5([Analisis SVM Model])
        UC6([Visualisasi TF-IDF])
        UC7([Cetak Laporan PDF])
    end

    User --- UC1
    User --> UC2
    User --> UC3
    User --> UC4
    User --> UC5
    User --> UC6
    User --> UC7

    UC4 -.->|include| UC3
    UC5 -.->|include| UC4
    UC6 -.->|include| UC4
```

---

## 2. Activity Diagram
Menggambarkan alur kerja (workflow) aplikasi secara keseluruhan menggunakan format Flowchart TD.

```mermaid
flowchart TD
    Start([Start]) --> Login[Halaman Login]
    Login --> HasAcc{Punya Akun?}
    HasAcc -- Tidak --> Register[Registrasi Akun]
    Register --> SaveFS[Simpan ke Firestore]
    SaveFS --> Login
    HasAcc -- Ya --> Input[Input EmpID & Password]
    Input --> Validate[Validasi Firestore]
    Validate -- Tidak Valid --> Error[Muncul Pesan Error]
    Error --> Login
    Validate -- Valid --> Dash[Dashboard Utama]

    subgraph Preprocessing
        Dash --> Upload[Upload File Excel]
        Upload --> Clean[Cleaning & Labeling]
        Clean --> UpDB[Update Database]
    end

    subgraph Analisis_Sentimen
        UpDB --> Train[Latih Model SVM]
        Train --> Visual[Generasi Wordcloud & TF-IDF]
        Visual --> Stats[Lihat Statistik Review]
    end

    Stats --> Export[Cetak Laporan PDF]
    Export --> Stop([Stop])
```

---

## 3. Sequence Diagram
Menggambarkan interaksi antara Flutter (Frontend), FastAPI (Backend), dan Firestore (Database).

```mermaid
sequenceDiagram
    autonumber
    participant U as User
    participant F as Flutter App
    participant B as Python Backend
    participant DB as Firebase Firestore

    U->>F: Upload Excel & Klik Preprocessing
    F->>B: POST /api/preprocessing (Multipart File)
    B->>B: Cleaning, Stemming, Labeling
    B->>DB: Simpan Data Preprocessed
    B-->>F: Response Success

    U->>F: Klik Latih Model SVM
    F->>B: POST /api/run-svm
    B->>DB: Ambil Data Preprocessed
    B->>B: Train-Test Split & SVM Training
    B-->>F: Response (Accuracy, F-Score, CM Base64)

    U->>F: Klik Jalankan Analisis Kata
    F->>B: POST /api/run-tfidf
    B->>B: Hitung TF-IDF & Generasi Wordcloud
    B-->>F: Response (Top Words, WC Base64)

    U->>F: Klik Export PDF
    F->>F: PdfService: Generate Template
    F->>U: Download/Buka Laporan_Sentimen.pdf
```

---

## 4. Class Diagram
Menggambarkan struktur class dan hubungan antar modul pada Flutter.

```mermaid
classDiagram
    class LoginScreen {
        +TextEditingController empIdController
        +TextEditingController passwordController
        +_login()
    }

    class RegisterScreen {
        +TextEditingController nameController
        +TextEditingController empIdController
        +_register()
    }

    class DashboardScreen {
        +String employeeId
        +String name
        +_logout()
    }

    class PreprocessingScreen {
        +PlatformFile selectedFile
        +_pickExcelFile()
        +_runPreprocessing()
    }

    class SentimentScreen {
        +double svmAccuracy
        +String wordcloudPosBase64
        +List topWords
        +_runSvm()
        +_runTfidf()
        +_exportToPdf()
    }

    class PdfService {
        <<Service>>
        +generateFullReport()
        -_createHeaderTemplate()
        -_drawLetterhead()
    }

    LoginScreen ..> RegisterScreen : Navigates
    LoginScreen ..> DashboardScreen : Authenticates
    DashboardScreen --> PreprocessingScreen : Navigates
    DashboardScreen --> SentimentScreen : Navigates
    SentimentScreen ..> PdfService : Uses
```

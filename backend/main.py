from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
import firebase_admin
import os
from firebase_admin import credentials, firestore
from Sastrawi.Stemmer.StemmerFactory import StemmerFactory
from Sastrawi.StopWordRemover.StopWordRemoverFactory import StopWordRemoverFactory
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, f1_score, confusion_matrix
import matplotlib
matplotlib.use('Agg') # Wajib untuk server agar tidak membuka window GUI
import matplotlib.pyplot as plt
import seaborn as sns
from wordcloud import WordCloud
import io
import base64
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

# Tambahkan CORS agar diizinkan diakses dari aplikasi luar
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------
# INISIALISASI FIREBASE & NLP SASTRAWI
# ---------------------------------------------------------
try:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    logger.info("Firebase initialized successfully")
except Exception as e:
    logger.error(f"Failed to initialize Firebase: {e}")

stemmer = StemmerFactory().create_stemmer()
stopword = StopWordRemoverFactory().create_stop_word_remover()

# Fungsi untuk konversi plot Matplotlib ke string Base64
def plot_to_base64(plt_instance):
    buf = io.BytesIO()
    plt_instance.savefig(buf, format='png', bbox_inches='tight')
    buf.seek(0)
    img_str = base64.b64encode(buf.read()).decode('utf-8')
    plt_instance.close()
    return img_str

# ---------------------------------------------------------
# API 1: PREPROCESSING
# ---------------------------------------------------------
@app.post("/api/preprocessing")
async def run_preprocessing(file: UploadFile = File(...)):
    try:
        logger.info(f"Menerima file: {file.filename}")
        df = pd.read_excel(file.file)
        
        # Validasi Kolom
        required_cols = ['name', 'stars', 'text']
        df.columns = [c.lower().strip() for c in df.columns]
        missing = [c for c in required_cols if c not in df.columns]
        if missing:
            raise Exception(f"Kolom tidak ditemukan: {', '.join(missing)}")

        logger.info("Memulai proses labeling...")
        df['text'] = df['text'].fillna('netral')

        def assign_label(row):
            if str(row['text']).lower() == 'netral': return 'netral'
            try:
                stars = float(row['stars'])
                if stars > 3: return 'positif'
                elif stars < 3: return 'negatif'
                else: return 'netral'
            except:
                return 'netral'
        
        df['label'] = df.apply(assign_label, axis=1)

        logger.info(f"Memulai cleaning & stemming pada {len(df)} baris data...")
        def preprocess_text(text):
            text = str(text).lower()
            text = stopword.remove(text)
            # Sastrawi Stemming adalah bagian paling lambat
            text = stemmer.stem(text)
            return text

        # Gunakan list comprehension untuk memantau progres (opsional)
        texts_clean = []
        for i, text in enumerate(df['text']):
            if i % 10 == 0: logger.info(f"Preprocessing baris ke-{i}...")
            texts_clean.append(preprocess_text(text))
        
        df['text_clean'] = texts_clean

        logger.info("Menyimpan hasil ke Firestore...")
        # Simpan ke Firebase
        docs = db.collection('reviews_preprocessed').stream()
        for doc in docs: doc.reference.delete()

        # Filter hanya kolom yang dibutuhkan agar tidak terjadi error "Value out of range"
        # Jika ada kolom ID yang sangat besar di Excel asli
        df_to_save = df[['name', 'stars', 'text', 'label', 'text_clean']]
        
        records = df_to_save.to_dict(orient='records')
        for record in records:
            db.collection('reviews_preprocessed').add(record)

        logger.info("Preprocessing selesai dengan sukses.")
        return {"status": "success", "message": "Preprocessing selesai dan data berhasil disimpan ke Database!"}
    except Exception as e:
        logger.error(f"Error in preprocessing: {e}")
        return {"status": "error", "message": str(e)}

# ---------------------------------------------------------
# API 2: TF-IDF & WORDCLOUD
# ---------------------------------------------------------
@app.post("/api/run-tfidf")
async def run_tfidf():
    try:
        docs = db.collection('reviews_preprocessed').stream()
        data = [doc.to_dict() for doc in docs]
        df = pd.DataFrame(data)

        if df.empty:
            return {"status": "error", "message": "Data kosong di Database. Selesaikan Preprocessing dulu."}

        # Filter kata umum khusus visualisasi & statistik kategori
        def remove_specific_words(text):
            words = text.split()
            # Perluas daftar stopwords untuk menghindari dominasi kata netral/umum
            unwanted_words = [
                'netral', 'yg', 'dan', 'nya', 'saya', 'ke', 'di', 'ada',
                'ini', 'itu', 'with', 'and', 'the', 'untuk', 'dari', 'ya', 'aja', 'banget',
                'tempat', 'lumayan', 'sejuk', 'asri', 'wisata'
            ]
            filtered_words = [w for w in words if w.lower() not in unwanted_words]
            return " ".join(filtered_words)

        df['text_tfidf'] = df['text_clean'].apply(remove_specific_words)

        # TF-IDF Global untuk Top Words
        vectorizer = TfidfVectorizer()
        tfidf_matrix = vectorizer.fit_transform(df['text_tfidf'])
        feature_names = vectorizer.get_feature_names_out()

        def get_top_tfidf(matrix, names, n=10):
            if matrix.shape[0] == 0: return []
            scores = matrix.mean(axis=0).A1
            indices = scores.argsort()[-n:][::-1]
            return [{"kata": names[i], "score": round(float(scores[i]), 4)} for i in indices]

        top_words = get_top_tfidf(tfidf_matrix, feature_names, 10)

        # Fungsi helper untuk menghitung Frekuensi (Count) murni agar sinkron dengan Wordcloud
        def get_top_counts(texts, n=5):
            from collections import Counter
            all_words = " ".join(texts).split()
            counts = Counter(all_words).most_common(n)
            return [{"kata": word, "score": count} for word, count in counts]

        # 1. Wordcloud & Top Words POSITIF
        df_pos = df[df['label'] == 'positif']
        img_pos_base64 = None
        top_words_pos = []
        if not df_pos.empty:
            text_pos_list = df_pos['text_tfidf'].tolist()
            text_pos_str = " ".join(text_pos_list)
            wc_pos = WordCloud(width=800, height=400, background_color='white', colormap='Greens').generate(text_pos_str)
            plt.figure(figsize=(10, 5))
            plt.imshow(wc_pos, interpolation='bilinear')
            plt.axis('off')
            img_pos_base64 = plot_to_base64(plt)

            top_words_pos = get_top_counts(text_pos_list, 5)

        # 2. Wordcloud & Top Words NEGATIF
        df_neg = df[df['label'] == 'negatif']
        img_neg_base64 = None
        top_words_neg = []
        if not df_neg.empty:
            text_neg_list = df_neg['text_tfidf'].tolist()
            text_neg_str = " ".join(text_neg_list)
            wc_neg = WordCloud(width=800, height=400, background_color='white', colormap='Reds').generate(text_neg_str)
            plt.figure(figsize=(10, 5))
            plt.imshow(wc_neg, interpolation='bilinear')
            plt.axis('off')
            img_neg_base64 = plot_to_base64(plt)

            top_words_neg = get_top_counts(text_neg_list, 5)

        return {
            "status": "success",
            "top_words": top_words,
            "top_words_pos": top_words_pos,
            "top_words_neg": top_words_neg,
            "image_pos_base64": img_pos_base64,
            "image_neg_base64": img_neg_base64
        }
    except Exception as e:
        logger.error(f"Error in TF-IDF: {e}")
        return {"status": "error", "message": str(e)}

# ---------------------------------------------------------
# API 3: SVM & CONFUSION MATRIX
# ---------------------------------------------------------
@app.post("/api/run-svm")
async def run_svm():
    try:
        docs = db.collection('reviews_preprocessed').stream()
        data = [doc.to_dict() for doc in docs]
        df = pd.DataFrame(data)

        if df.empty:
            return {"status": "error", "message": "Data kosong di Database."}

        vectorizer = TfidfVectorizer()
        X = vectorizer.fit_transform(df['text_clean'])
        y = df['label']

        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
        model = SVC(kernel='linear')
        model.fit(X_train, y_train)

        y_pred = model.predict(X_test)
        acc = accuracy_score(y_test, y_pred)
        f1 = f1_score(y_test, y_pred, average='weighted')
        cm = confusion_matrix(y_test, y_pred, labels=['positif', 'netral', 'negatif'])

        plt.figure(figsize=(6, 5))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=['Positif', 'Netral', 'Negatif'], yticklabels=['Positif', 'Netral', 'Negatif'])
        plt.title('Confusion Matrix SVM')
        plt.ylabel('Aktual')
        plt.xlabel('Prediksi')

        cm_base64 = plot_to_base64(plt)

        label_counts = df['label'].value_counts().to_dict()
        grafik_data = {
            "positif": int(label_counts.get('positif', 0)),
            "netral": int(label_counts.get('netral', 0)),
            "negatif": int(label_counts.get('negatif', 0))
        }

        result_data = {
            "accuracy": round(float(acc * 100), 2),
            "f_score": round(float(f1), 2),
            "grafik_data": grafik_data,
            "cm_base64": cm_base64
        }
        db.collection('svm_results').add(result_data)

        return {"status": "success", "data": result_data}
    except Exception as e:
        logger.error(f"Error in SVM: {e}")
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    import uvicorn
    # Ambil port dari environment variable (untuk Render/Railway) atau default 8000
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)

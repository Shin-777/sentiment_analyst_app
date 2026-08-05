import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/pdf_service.dart';
import '../config/api_config.dart';

class SentimentScreen extends StatefulWidget {
  @override
  _SentimentScreenState createState() => _SentimentScreenState();
}

class _SentimentScreenState extends State<SentimentScreen> {
  final String apiUrl = '${ApiConfig.baseUrl}/api';

  // --- STATE TF-IDF ---
  bool _isTfidfLoading = false;
  bool _tfidfDone = false;
  String? _wordcloudPosBase64;
  String? _wordcloudNegBase64;
  List<dynamic> _topWords = [];
  List<dynamic> _topWordsPos = [];
  List<dynamic> _topWordsNeg = [];

  // --- STATE SVM ---
  bool _isSvmLoading = false;
  bool _svmDone = false;
  String? _cmBase64;
  double _svmAccuracy = 0.0;
  double _svmFScore = 0.0;
  Map<String, dynamic> _svmGrafikData = {
    'positif': 0,
    'netral': 0,
    'negatif': 0,
  };

  // ==========================================
  // FUNGSI HIT API TF-IDF
  // ==========================================
  Future<void> _runTfidf() async {
    setState(() => _isTfidfLoading = true);

    try {
      var response = await http.post(
        Uri.parse('$apiUrl/run-tfidf'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      var responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        setState(() {
          _wordcloudPosBase64 = responseData['image_pos_base64'];
          _wordcloudNegBase64 = responseData['image_neg_base64'];
          _topWords = responseData['top_words'];
          _topWordsPos = responseData['top_words_pos'] ?? [];
          _topWordsNeg = responseData['top_words_neg'] ?? [];
          _tfidfDone = true;
        });
      } else {
        _showError("Gagal memproses TF-IDF: ${responseData['message']}");
      }
    } catch (e) {
      _showError("Terjadi kesalahan jaringan: $e");
    } finally {
      setState(() => _isTfidfLoading = false);
    }
  }

  // ==========================================
  // FUNGSI HIT API SVM
  // ==========================================
  Future<void> _runSvm() async {
    setState(() => _isSvmLoading = true);

    try {
      var response = await http.post(
        Uri.parse('$apiUrl/run-svm'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      var responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        setState(() {
          var data = responseData['data'];
          _cmBase64 = data['cm_base64'];
          _svmAccuracy = data['accuracy'].toDouble();
          _svmFScore = data['f_score'].toDouble();
          _svmGrafikData = data['grafik_data'];
          _svmDone = true;
        });
      } else {
        _showError("Gagal memproses SVM: ${responseData['message']}");
      }
    } catch (e) {
      _showError("Terjadi kesalahan jaringan: $e");
    } finally {
      setState(() => _isSvmLoading = false);
    }
  }

  // ==========================================
  // FUNGSI EXPORT PDF & NOTIFIKASI
  // ==========================================
  Future<void> _exportToPdf(String type) async {
    try {
      String fileName = "";
      if (type == 'STATS') {
        await PdfService.generateStatsReport(grafikData: _svmGrafikData);
        fileName = "Statistik Review";
      } else if (type == 'SVM') {
        await PdfService.generateSvmReport(
          cmBase64: _cmBase64,
          accuracy: _svmAccuracy,
          fScore: _svmFScore,
        );
        fileName = "Performa Model SVM";
      } else if (type == 'VISUAL') {
        await PdfService.generateVisualReport(
          wordcloudPosBase64: _wordcloudPosBase64,
          wordcloudNegBase64: _wordcloudNegBase64,
        );
        fileName = "Visualisasi Wordcloud";
      } else if (type == 'FREQ') {
        await PdfService.generateFrequencyReport(
          topWords: _topWords,
          topWordsPos: _topWordsPos,
          topWordsNeg: _topWordsNeg,
        );
        fileName = "Frekuensi Kata";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil mengekspor Laporan $fileName ke PDF!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError("Gagal mengekspor PDF: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analisis Sentimen'),
          backgroundColor: Colors.green[800],
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.green[200],
            tabs: [
              const Tab(icon: Icon(Icons.analytics), text: 'SVM Model'),
              Tab(
                icon: const Icon(Icons.remove_red_eye),
                child: const Text(
                  'Visualisasi\nTF-IDF',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const Tab(icon: Icon(Icons.description), text: 'Laporan'),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Watermark
            Center(
              child: Opacity(
                opacity: 0.05,
                child: Image.asset('assets/images/logo.png', width: 300),
              ),
            ),
            TabBarView(
              children: [
                _buildSvmView(),
                _buildTfidfView(),
                _buildReportSummaryView(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VIEW TAB 1: VISUALISASI (Wordcloud & Frekuensi)
  // ==========================================
  Widget _buildTfidfView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            icon: _isTfidfLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.play_circle_fill),
            label: Text(
              _isTfidfLoading
                  ? 'Memproses Visualisasi TF-IDF...'
                  : 'Jalankan Analisis Kata',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
            onPressed: _isTfidfLoading ? null : _runTfidf,
          ),
          const SizedBox(height: 24),
          if (_tfidfDone) ...[
            Text(
              'Wordcloud Sentimen Positif',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800]),
            ),
            const SizedBox(height: 10),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.green[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _wordcloudPosBase64 != null
                  ? Image.memory(
                      base64Decode(_wordcloudPosBase64!),
                      fit: BoxFit.contain,
                    )
                  : const Center(child: Text('Data positif tidak ditemukan.')),
            ),
            const SizedBox(height: 24),
            Text(
              'Wordcloud Sentimen Negatif',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[800]),
            ),
            const SizedBox(height: 10),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.red[100]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _wordcloudNegBase64 != null
                  ? Image.memory(
                      base64Decode(_wordcloudNegBase64!),
                      fit: BoxFit.contain,
                    )
                  : const Center(child: Text('Data negatif tidak ditemukan.')),
            ),
            const SizedBox(height: 24),
            Text(
              'Frekuensi Kata (TF-IDF)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[900]),
            ),
            const SizedBox(height: 10),
            DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.green[50]),
              border: TableBorder.all(color: Colors.green[200]!),
              columns: const [
                DataColumn(label: Text('Kata', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Skor', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: _topWords.take(10).map((data) {
                return DataRow(
                  cells: [
                    DataCell(Text(data['kata'].toString())),
                    DataCell(Text(data['score'].toString())),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // VIEW TAB 2: SVM (Confusion Matrix & Performa)
  // ==========================================
  Widget _buildSvmView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            icon: _isSvmLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.settings),
            label: Text(
              _isSvmLoading ? 'Melatih Model...' : 'Latih Model SVM',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[900],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
            onPressed: _isSvmLoading ? null : _runSvm,
          ),
          const SizedBox(height: 24),
          if (_svmDone) ...[
            Text(
              'Confusion Matrix',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800]),
            ),
            const SizedBox(height: 10),
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.green[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _cmBase64 != null
                  ? Image.memory(base64Decode(_cmBase64!), fit: BoxFit.contain)
                  : const Center(child: Text('Gagal memuat matrix.')),
            ),
            const SizedBox(height: 24),
            Text(
              'Metrik Evaluasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800]),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.green[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Akurasi: $_svmAccuracy%',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[900])),
                    Text('F-Score: $_svmFScore',
                        style: TextStyle(fontSize: 16, color: Colors.green[800])),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // VIEW TAB 3: LAPORAN (Statistik Review & Export)
  // ==========================================
  Widget _buildReportSummaryView() {
    if (!_svmDone && !_tfidfDone) {
      return const Center(
          child: Text('Selesaikan analisis terlebih dahulu untuk melihat laporan.'));
    }

    int totalData = _svmGrafikData.values.fold(0, (sum, item) => sum + (item as int));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Statistik Review',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[900]),
          ),
          const SizedBox(height: 10),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatRow('Total Review', totalData.toString(), Colors.green[900]!),
                  const Divider(),
                  _buildStatRow('Positif', _svmGrafikData['positif'].toString(), Colors.green[700]!),
                  _buildStatRow('Netral', _svmGrafikData['netral'].toString(), Colors.grey[600]!),
                  _buildStatRow('Negatif', _svmGrafikData['negatif'].toString(), Colors.red[700]!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ringkasan Sentimen',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[900]),
          ),
          const SizedBox(height: 10),
          // Grafik Batang
          Container(
            height: 200,
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (totalData > 0) ? (totalData.toDouble()) : 10,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0: return const Text('Positif');
                          case 1: return const Text('Netral');
                          case 2: return const Text('Negatif');
                          default: return const Text('');
                        }
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: _svmGrafikData['positif'].toDouble(), color: Colors.green[700]!)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: _svmGrafikData['netral'].toDouble(), color: Colors.grey[500]!)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: _svmGrafikData['negatif'].toDouble(), color: Colors.red[400]!)]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Export Laporan Spesifik',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[900]),
          ),
          const SizedBox(height: 12),
          _buildExportButton(
            label: 'Laporan Statistik Review',
            onPressed: () => _exportToPdf('STATS'),
          ),
          _buildExportButton(
            label: 'Laporan Performa Model SVM',
            onPressed: () => _exportToPdf('SVM'),
          ),
          _buildExportButton(
            label: 'Visualisasi Wordcloud',
            onPressed: () => _exportToPdf('VISUAL'),
          ),
          _buildExportButton(
            label: 'Frekuensi Kata Tertinggi',
            onPressed: () => _exportToPdf('FREQ'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildExportButton({required String label, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.picture_as_pdf),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[800],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          alignment: Alignment.centerLeft,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

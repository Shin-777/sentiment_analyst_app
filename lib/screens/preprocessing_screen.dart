import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';

class PreprocessingScreen extends StatefulWidget {
  @override
  _PreprocessingScreenState createState() => _PreprocessingScreenState();
}

class _PreprocessingScreenState extends State<PreprocessingScreen> {
  PlatformFile? _selectedFile;
  bool _isProcessing = false;
  String _statusMessage = "Silakan upload file .xlsx hasil scraping.";

  // Fungsi untuk memilih file Excel
  Future<void> _pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          _statusMessage =
              "File terpilih: ${_selectedFile!.name}\nSiap untuk diproses.";
        });
      } else {
        // User membatalkan pemilihan file
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Pemilihan file dibatalkan.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  // Fungsi untuk menjalankan preprocessing (Hit ke Backend Python)
  Future<void> _runPreprocessing() async {
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
      _statusMessage =
          "Sedang melakukan Preprocessing Data ( Case Folding, Cleaning, Stopword Removal, Stemming, & Labeling Sentimen )...";
    });

    try {
      var uri = Uri.parse('${ApiConfig.baseUrl}/api/preprocessing');
      var request = http.MultipartRequest('POST', uri);

      // Tambahkan header untuk bypass warning Ngrok
      request.headers['ngrok-skip-browser-warning'] = 'true';

      request.files.add(
        await http.MultipartFile.fromPath('file', _selectedFile!.path!),
      );

      // Mengirim request dengan timeout 5 menit karena stemming Sastrawi lambat
      var streamedResponse = await request.send().timeout(const Duration(minutes: 5));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          _statusMessage = responseData['message'] ?? "Preprocessing selesai dan data berhasil disimpan!";
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proses Berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String errorMsg = "Gagal memproses data (Status: ${response.statusCode})";
        try {
          var errorData = jsonDecode(response.body);
          errorMsg = errorData['message'] ?? errorMsg;
        } catch (_) {}
        
        setState(() {
          _statusMessage = errorMsg;
        });
        
        _showError(errorMsg);
      }
    } on TimeoutException catch (_) {
      setState(() {
        _statusMessage = "Waktu habis (Timeout). Data terlalu besar atau server sibuk.";
      });
      _showError("Timeout: Proses memakan waktu terlalu lama.");
    } catch (e) {
      setState(() {
        _statusMessage = "Terjadi kesalahan saat memproses data.";
      });
      _showError("Error: $e");
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preprocessing Data'),
        backgroundColor: Colors.green[800],
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
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.data_usage, size: 100, color: Colors.green[300]),
                  const SizedBox(height: 24),

                  // Status Text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.green[900]),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Upload File
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload File .xlsx'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _isProcessing ? null : _pickExcelFile,
                  ),
                  const SizedBox(height: 16),

                  // Tombol Jalankan Preprocessing
                  ElevatedButton.icon(
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(
                      _isProcessing
                          ? 'Memproses Data...'
                          : 'Jalankan Preprocessing',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: (_selectedFile == null || _isProcessing)
                        ? null
                        : _runPreprocessing,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

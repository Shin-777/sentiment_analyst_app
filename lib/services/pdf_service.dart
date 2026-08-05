import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfService {
  static Future<void> _saveAndLaunchFile(List<int> bytes, String fileName) async {
    final path = (await getApplicationDocumentsDirectory()).path;
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    await OpenFile.open('$path/$fileName');
  }

  /// Helper to initialize document with header template
  static Future<PdfDocument> _setupDocumentWithHeader() async {
    final PdfDocument document = PdfDocument();
    
    Uint8List? logoBytes;
    try {
      final ByteData data = await rootBundle.load('assets/images/logo.png');
      logoBytes = data.buffer.asUint8List();
    } catch (e) {
      // Ignored if logo not found
    }

    final PdfPageTemplateElement header = PdfPageTemplateElement(
        Rect.fromLTWH(0, 0, document.pageSettings.size.width, 100));

    if (logoBytes != null) {
      header.graphics.drawImage(PdfBitmap(logoBytes), const Rect.fromLTWH(0, 0, 80, 80));
    }

    header.graphics.drawString(
      'RUMAH WISATA PAKIS ASRI',
      PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold),
      bounds: const Rect.fromLTWH(90, 10, 400, 30),
    );

    header.graphics.drawString(
      'Jl. Cibatok 1, Cibungbulang, Gn Picung Pamijahan,\nGunung Salak Endah, Km 58, 16810, Bogor\nTelp: 085777554697',
      PdfStandardFont(PdfFontFamily.helvetica, 9),
      bounds: const Rect.fromLTWH(90, 35, 400, 50),
    );

    header.graphics.drawLine(
      PdfPen(PdfColor(0, 0, 0), width: 2),
      const Offset(0, 85),
      Offset(document.pageSettings.size.width, 85),
    );
    header.graphics.drawLine(
      PdfPen(PdfColor(0, 0, 0), width: 0.5),
      const Offset(0, 88),
      Offset(document.pageSettings.size.width, 88),
    );

    document.template.top = header;
    return document;
  }

  /// 1. Laporan Statistik Review & Ringkasan
  static Future<void> generateStatsReport({required Map<String, dynamic> grafikData}) async {
    final PdfDocument document = await _setupDocumentWithHeader();
    final PdfPage page = document.pages.add();
    double yPos = 20;

    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);

    page.graphics.drawString('LAPORAN STATISTIK REVIEW & RINGKASAN', titleFont, bounds: Rect.fromLTWH(0, yPos, 0, 0));
    yPos += 40;

    int total = grafikData.values.fold(0, (sum, val) => sum + (val as int));
    page.graphics.drawString('Total Data Review: $total', boldFont, bounds: Rect.fromLTWH(0, yPos, 0, 0));
    yPos += 25;

    final PdfGrid statsGrid = PdfGrid();
    statsGrid.columns.add(count: 2);
    statsGrid.headers.add(1);
    
    PdfGridRow statsHeader = statsGrid.headers[0];
    statsHeader.cells[0].value = 'Kategori';
    statsHeader.cells[1].value = 'Jumlah';
    statsHeader.style.backgroundBrush = PdfBrushes.lightGray;
    statsHeader.style.font = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    
    statsGrid.style.cellPadding = PdfPaddings(left: 5, right: 5, top: 2, bottom: 2);
    for (var i = 0; i < statsGrid.columns.count; i++) {
      statsGrid.columns[i].format.alignment = PdfTextAlignment.center;
    }

    grafikData.forEach((key, value) {
      final row = statsGrid.rows.add();
      row.cells[0].value = key.toUpperCase();
      row.cells[1].value = value.toString();
    });
    
    final PdfLayoutResult statsResult = statsGrid.draw(page: page, bounds: Rect.fromLTWH(0, yPos, 200, 0))!;
    yPos = statsResult.bounds.bottom;

    _drawSignature(page, yPos, document);

    final List<int> bytes = await document.save();
    document.dispose();
    await _saveAndLaunchFile(bytes, 'Laporan_Statistik_Review.pdf');
  }

  /// Helper to get Indonesian Date String
  static String _getIndonesianDate() {
    final DateTime now = DateTime.now();
    final List<String> days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    // weekday: 1 = Monday, ..., 7 = Sunday
    String dayName = days[now.weekday % 7];
    String monthName = months[now.month - 1];
    
    return "$dayName, ${now.day} $monthName ${now.year}";
  }

  /// Helper to draw signature block at the bottom right
  static void _drawSignature(PdfPage page, double currentY, PdfDocument document) {
    const double signatureHeight = 110;
    final double pageHeight = page.getClientSize().height;
    
    PdfPage targetPage = page;
    double drawY = pageHeight - signatureHeight;

    // If current content is too close to bottom, move signature to next page
    if (currentY > drawY - 20) {
      targetPage = document.pages.add();
      drawY = targetPage.getClientSize().height - signatureHeight;
    }

    final PdfGraphics graphics = targetPage.graphics;
    final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    
    String dateText = "Jakarta, ${_getIndonesianDate()}";
    
    // Menghitung lebar teks agar pas di ujung kanan (sejajar garis kop)
    final double textWidth = bodyFont.measureString(dateText).width;
    double xPos = targetPage.getClientSize().width - textWidth; 
    
    graphics.drawString(dateText, bodyFont, bounds: Rect.fromLTWH(xPos, drawY, textWidth, 20));
    
    // Menyejajarkan tulisan "Manager" agar rata kiri dengan teks tanggal di atasnya
    graphics.drawString('Manager', boldFont, bounds: Rect.fromLTWH(xPos, drawY + 80, 200, 20));
  }

  /// 2. Laporan Performa Model SVM
  static Future<void> generateSvmReport({
    required String? cmBase64,
    required double accuracy,
    required double fScore,
  }) async {
    final PdfDocument document = await _setupDocumentWithHeader();
    final PdfPage page = document.pages.add();
    double yPos = 20;

    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 12);

    page.graphics.drawString('LAPORAN PERFORMA MODEL SVM', titleFont, bounds: Rect.fromLTWH(0, yPos, 0, 0));
    yPos += 40;

    page.graphics.drawString('Hasil Evaluasi:', bodyFont, bounds: Rect.fromLTWH(0, yPos, 0, 0));
    yPos += 20;
    page.graphics.drawString('- Akurasi: $accuracy%', bodyFont, bounds: Rect.fromLTWH(10, yPos, 0, 0));
    yPos += 15;
    page.graphics.drawString('- F-Score: $fScore', bodyFont, bounds: Rect.fromLTWH(10, yPos, 0, 0));
    yPos += 30;

    if (cmBase64 != null) {
      page.graphics.drawString('Confusion Matrix:', bodyFont, bounds: Rect.fromLTWH(0, yPos, 0, 0));
      yPos += 20;
      page.graphics.drawImage(
        PdfBitmap(base64Decode(cmBase64)), 
        Rect.fromLTWH(0, yPos, 300, 250)
      );
      yPos += 250;
    }

    _drawSignature(page, yPos, document);

    final List<int> bytes = await document.save();
    document.dispose();
    await _saveAndLaunchFile(bytes, 'Laporan_Performa_SVM.pdf');
  }

  /// 3. Visualisasi Wordcloud
  static Future<void> generateVisualReport({
    required String? wordcloudPosBase64,
    required String? wordcloudNegBase64,
  }) async {
    final PdfDocument document = await _setupDocumentWithHeader();
    final PdfPage page = document.pages.add();
    double yPos = 20;

    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);

    page.graphics.drawString('VISUALISASI WORDCLOUD SENTIMEN', titleFont, bounds: Rect.fromLTWH(0, yPos, 0, 0));
    yPos += 40;

    if (wordcloudPosBase64 != null) {
      page.graphics.drawString('Sentimen Positif:', boldFont, bounds: Rect.fromLTWH(0, yPos, 0, 0));
      yPos += 20;
      page.graphics.drawImage(
        PdfBitmap(base64Decode(wordcloudPosBase64)), 
        Rect.fromLTWH(0, yPos, 300, 160)
      );
      yPos += 180; // 160 height + 20 spacing
    }

    if (wordcloudNegBase64 != null) {
      page.graphics.drawString('Sentimen Negatif:', boldFont, bounds: Rect.fromLTWH(0, yPos, 0, 0));
      yPos += 20;
      page.graphics.drawImage(
        PdfBitmap(base64Decode(wordcloudNegBase64)), 
        Rect.fromLTWH(0, yPos, 300, 160)
      );
      yPos += 160;
    }

    _drawSignature(page, yPos, document);

    final List<int> bytes = await document.save();
    document.dispose();
    await _saveAndLaunchFile(bytes, 'Visualisasi_Wordcloud.pdf');
  }

  /// 4. Frekuensi Kata Tertinggi
  static Future<void> generateFrequencyReport({
    required List<dynamic> topWords,
    required List<dynamic> topWordsPos,
    required List<dynamic> topWordsNeg,
  }) async {
    final PdfDocument document = await _setupDocumentWithHeader();
    final PdfPage page = document.pages.add();
    double yPos = 20;

    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);

    page.graphics.drawString('LAPORAN FREKUENSI KATA TERTINGGI', titleFont, bounds: Rect.fromLTWH(0, yPos, 0, 0));
    yPos += 40;

    // A. Global
    page.graphics.drawString('A. Kategori Global', boldFont, bounds: Rect.fromLTWH(0, yPos, 0, 0));
    yPos += 20;
    final PdfGrid globalGrid = _createWordGrid(topWords, PdfBrushes.skyBlue);
    final PdfLayoutResult globalResult = globalGrid.draw(page: page, bounds: Rect.fromLTWH(0, yPos, 500, 0))!;
    yPos = globalResult.bounds.bottom + 15;

    // B. Positif
    page.graphics.drawString('B. Kategori Positif', boldFont, bounds: Rect.fromLTWH(0, yPos, 0, 0));
    yPos += 20;
    final PdfGrid posGrid = _createWordGrid(topWordsPos, PdfBrushes.lightGreen, isCount: true);
    final PdfLayoutResult posResult = posGrid.draw(page: page, bounds: Rect.fromLTWH(0, yPos, 500, 0))!;
    yPos = posResult.bounds.bottom + 15;

    // C. Negatif
    page.graphics.drawString('C. Kategori Negatif', boldFont, bounds: Rect.fromLTWH(0, yPos, 0, 0));
    yPos += 20;
    final PdfGrid negGrid = _createWordGrid(topWordsNeg, PdfBrushes.lightPink, isCount: true);
    final PdfLayoutResult negResult = negGrid.draw(page: page, bounds: Rect.fromLTWH(0, yPos, 500, 0))!;
    yPos = negResult.bounds.bottom;

    _drawSignature(page, yPos, document);

    final List<int> bytes = await document.save();
    document.dispose();
    await _saveAndLaunchFile(bytes, 'Laporan_Frekuensi_Kata.pdf');
  }

  /// Helper untuk membuat Grid Kata
  static PdfGrid _createWordGrid(List<dynamic> data, PdfBrush headerColor, {bool isCount = false}) {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 2);
    grid.headers.add(1);
    
    // Header Style
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Kata';
    header.cells[1].value = isCount ? 'Frekuensi' : 'Skor TF-IDF';
    header.style.backgroundBrush = headerColor;
    header.style.font = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    
    // Common Style (Padding & Alignment)
    grid.style.cellPadding = PdfPaddings(left: 5, right: 5, top: 1, bottom: 1);
    
    for (var i = 0; i < grid.columns.count; i++) {
      grid.columns[i].format.alignment = PdfTextAlignment.center;
    }

    for (var item in data) {
      final row = grid.rows.add();
      row.cells[0].value = item['kata'].toString();
      row.cells[1].value = item['score'].toString();
    }
    return grid;
  }
}

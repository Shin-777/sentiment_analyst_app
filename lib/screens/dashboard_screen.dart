import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'preprocessing_screen.dart';
import 'sentiment_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String employeeId;
  final String name;

  DashboardScreen({required this.employeeId, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Menggunakan pushAndRemoveUntil untuk membersihkan history navigasi
              // dan kembali ke halaman Login secara bersih.
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: TextStyle(fontSize: 18, color: Colors.green[700]),
                ),
                Text(
                  '$employeeId - $name',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildMenuCard(
                        context,
                        title: 'Preprocessing\nData',
                        icon: Icons.upload_file,
                        color: Colors.green[700]!,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PreprocessingScreen()));
                        },
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Analisis\nSentimen',
                        icon: Icons.pie_chart,
                        color: Colors.green[900]!,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SentimentScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

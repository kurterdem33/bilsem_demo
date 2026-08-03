import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class KusursuzCemberPage extends StatefulWidget {
  const KusursuzCemberPage({super.key});

  @override
  State<KusursuzCemberPage> createState() => _KusursuzCemberPageState();
}

class _KusursuzCemberPageState extends State<KusursuzCemberPage> {
  final Color _primaryNavy = const Color(0xFF0F172A);
  final Color _accentRed = const Color(0xFFEE2B2B);

  List<Offset> _points = [];
  bool _isDrawing = false;
  bool _hasFinished = false;
  
  double _score = 0.0;
  Offset _calculatedCenter = Offset.zero;
  double _calculatedRadius = 0.0;

  final TextEditingController _nameController = TextEditingController();

  // Çizim Paneline dokunulduğunda
  void _onPanStart(DragStartDetails details) {
    if (_hasFinished) return;
    setState(() {
      _isDrawing = true;
      _points = [details.localPosition];
    });
  }

  // Çizim devam ederken (Parmağı kaydırırken)
  void _onPanUpdate(DragUpdateDetails details) {
    if (_hasFinished || !_isDrawing) return;
    setState(() {
      _points.add(details.localPosition);
    });
  }

  // Çizim bittiğinde (Parmağı kaldırdığında)
  void _onPanEnd(DragEndDetails details) {
    if (_hasFinished || !_isDrawing) return;
    setState(() {
      _isDrawing = false;
      _calculatePerfectness();
    });
  }

  // Çizimi ve sonuçları temizle
  void _resetCanvas() {
    setState(() {
      _points.clear();
      _hasFinished = false;
      _score = 0.0;
      _nameController.clear();
    });
  }

  // Çizimin ne kadar "Kusursuz" olduğunu hesaplayan Algoritma
  void _calculatePerfectness() {
    if (_points.length < 20) {
      _showWarning("Çok küçük çizdin! Daha belirgin bir çember çizmelisin.");
      _resetCanvas();
      return;
    }

    double sumX = 0;
    double sumY = 0;
    for (var p in _points) {
      sumX += p.dx;
      sumY += p.dy;
    }
    double cx = sumX / _points.length;
    double cy = sumY / _points.length;
    _calculatedCenter = Offset(cx, cy);

    double sumDistance = 0;
    List<double> distances = [];
    for (var p in _points) {
      double d = sqrt(pow(p.dx - cx, 2) + pow(p.dy - cy, 2));
      distances.add(d);
      sumDistance += d;
    }
    _calculatedRadius = sumDistance / _points.length;

    double totalError = 0;
    for (var d in distances) {
      totalError += (d - _calculatedRadius).abs();
    }
    double averageError = totalError / _points.length;

    double startEndDist = sqrt(
      pow(_points.first.dx - _points.last.dx, 2) + pow(_points.first.dy - _points.last.dy, 2)
    );
    double closurePenalty = min(20.0, (startEndDist / _calculatedRadius) * 20);

    double errorPercentage = (averageError / _calculatedRadius) * 100;
    double rawScore = 100 - errorPercentage - closurePenalty;

    setState(() {
      _score = rawScore.clamp(0.0, 100.0);
      _hasFinished = true;
    });

    // İdeal çemberi 1 saniye gösterip tebrikler ekranını aç
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _showResultDialog();
    });
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: _accentRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getMedal() {
    if (_score >= 95) return '🥇 Altın';
    if (_score >= 90) return '🥈 Gümüş';
    if (_score >= 85) return '🥉 Bronz';
    return '';
  }

  // --- SONUÇ VE TEBRİKLER EKRANI (DİALOG) ---
  void _showResultDialog() {
    bool isSuccess = _score >= 85.0;
    bool isTopTier = _score >= 90.0;
    
    // Değerleri Dialog açıldığında sabitliyoruz
    String achievedMedal = _getMedal();
    double achievedScore = _score;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSuccess)
                SizedBox(
                  height: 220, 
                  child: Lottie.asset(
                    isTopTier ? 'assets/lottie/konfeti_kupa.json' : 'assets/lottie/konfeti.json',
                    fit: BoxFit.contain,
                  ),
                ),
              
              Text(
                isSuccess ? "TEBRİKLER! 🌟" : "DAHA İYİ OLABİLİR! 💪",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24, 
                  fontWeight: FontWeight.w900, 
                  color: isSuccess ? Colors.green.shade700 : _primaryNavy
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                "Kusursuzluk Oranı:\n%${achievedScore.toStringAsFixed(1)}",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryNavy),
              ),

              if (isSuccess) ...[
                const SizedBox(height: 12),
                Text(
                  "Kazandığın Madalya: $achievedMedal",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber.shade700),
                ),
                const SizedBox(height: 24),
                Text("Skorunu Tabloya Kaydet", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: "İsminizi Yazın...",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentRed,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                // BURADA DEĞİŞİKLİK YAPILDI: async/await ve sıralama düzenlendi
                onPressed: () async {
                  if (isSuccess && _nameController.text.trim().isNotEmpty) {
                    await _saveScore(_nameController.text.trim(), achievedScore, achievedMedal);
                  }
                  
                  if (mounted) {
                    Navigator.pop(context);
                  }
                  _resetCanvas(); // Kayıt bittikten sonra sıfırlıyoruz!
                },
                child: Text(
                  isSuccess ? "KAYDET VE TEKRAR OYNA" : "TEKRAR DENE", 
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SKOR KAYDETME GÜNCELLENDİ (Parametre Alıyor) ---
  Future<void> _saveScore(String name, double finalScore, String medal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> scores = prefs.getStringList('cember_liderlik') ?? [];
    
    // Format: "İsim|Skor|Madalya" (Sıfırlanmadan önceki final skoru alıyoruz)
    scores.add('$name|${finalScore.toStringAsFixed(1)}|$medal');
    
    // Skora göre büyükten küçüğe sırala
    scores.sort((a, b) {
      double scoreA = double.parse(a.split('|')[1]);
      double scoreB = double.parse(b.split('|')[1]);
      return scoreB.compareTo(scoreA);
    });

    await prefs.setStringList('cember_liderlik', scores);
  }

  // Liderlik Tablosunu Gösterme
  Future<void> _showLeaderboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> scores = prefs.getStringList('cember_liderlik') ?? [];

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("🏆 Liderlik Tablosu", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: _primaryNavy)),
        content: scores.isEmpty
            ? Text("Henüz hiç skor kaydedilmemiş. İlk sen ol!", textAlign: TextAlign.center, style: GoogleFonts.poppins())
            : SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: scores.length,
                  itemBuilder: (context, index) {
                    var data = scores[index].split('|');
                    return ListTile(
                      leading: Text("#${index + 1}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                      title: Text(data[0], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), // İsim
                      subtitle: Text("Skor: %${data[1]}", style: GoogleFonts.poppins(color: Colors.green.shade700, fontWeight: FontWeight.w600)), // Skor
                      trailing: Text(data[2], style: GoogleFonts.poppins(fontSize: 16)), // Madalya
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Kapat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _accentRed)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka Plan
          Positioned.fill(
            child: Image.asset('assets/images/sayi_hafizasi_background_2.jpg', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. ÜST BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: _primaryNavy, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          "KUSURSUZ ÇEMBER",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: _primaryNavy),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 32),
                        onPressed: _showLeaderboard, // Liderlik tablosu butonu
                      ),
                    ],
                  ),
                ),

                // Yönerge Metni
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    _hasFinished 
                        ? "İşte çizimin ve olması gereken ideal çember (Kırmızı)!"
                        : "Ekrana tek hamlede mükemmel bir\nçember çizmeye çalış!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: _hasFinished ? _primaryNavy : Colors.black87,
                    ),
                  ),
                ),

                // 2. ÇİZİM ALANI (TABLET UYUMLU, ESNEK)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: AspectRatio(
                        aspectRatio: 1.0, // Her zaman kare kalır
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600), // Dev ekranlarda sınır
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: _primaryNavy.withOpacity(0.3), width: 3),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: GestureDetector(
                                onPanStart: _onPanStart,
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: _onPanEnd,
                                child: CustomPaint(
                                  painter: CircleDrawingPainter(
                                    points: _points,
                                    strokeColor: _primaryNavy,
                                    hasFinished: _hasFinished,
                                    perfectCenter: _calculatedCenter,
                                    perfectRadius: _calculatedRadius,
                                    perfectStrokeColor: _accentRed,
                                  ),
                                  size: Size.infinite,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ==========================================================
/// ÇİZİM MOTORU (CustomPainter)
/// ==========================================================
class CircleDrawingPainter extends CustomPainter {
  final List<Offset> points;
  final Color strokeColor;
  final bool hasFinished;
  
  final Offset perfectCenter;
  final double perfectRadius;
  final Color perfectStrokeColor;

  CircleDrawingPainter({
    required this.points,
    required this.strokeColor,
    required this.hasFinished,
    required this.perfectCenter,
    required this.perfectRadius,
    required this.perfectStrokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Çocuğun çizdiği çizgiyi çiz
    final Paint drawingPaint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], drawingPaint);
    }

    // 2. Çizim bitmişse arkaya "İdeal/Kusursuz Çemberi" çiz
    if (hasFinished && perfectRadius > 0) {
      final Paint perfectPaint = Paint()
        ..color = perfectStrokeColor.withOpacity(0.5) 
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke;
      
      canvas.drawCircle(perfectCenter, perfectRadius, perfectPaint);
      
      // Merkez Noktası
      final Paint centerPointPaint = Paint()
        ..color = perfectStrokeColor.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(perfectCenter, 4.0, centerPointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CircleDrawingPainter oldDelegate) {
    return true; 
  }
}
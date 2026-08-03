import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

// OYUN DURUMLARI
enum GameState { ready, playing, gameOver }

// 3D KÜP VERİ MODELİ
class Cube {
  final int x;
  final int y; // Yükseklik
  final int z;

  Cube(this.x, this.y, this.z);
}

class KupSaymaPage extends StatefulWidget {
  const KupSaymaPage({super.key});

  @override
  State<KupSaymaPage> createState() => _KupSaymaPageState();
}

class _KupSaymaPageState extends State<KupSaymaPage> {
  final Color _primaryNavy = const Color(0xFF0F172A);
  final Color _accentRed = const Color(0xFFEE2B2B);

  GameState _gameState = GameState.ready;
  int _score = 0;
  int _lives = 3;

  List<Cube> _currentCubes = [];
  List<int> _options = [];
  int _targetCount = 0;

  final Random _random = Random();

  // SKOR TABLOSU İÇİN DEĞİŞKENLER
  final List<Map<String, dynamic>> _localScores = [];
  final TextEditingController _nameController = TextEditingController();
  bool _isScoreSaved = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameState = GameState.playing;
      _score = 0;
      _lives = 3;
      _isScoreSaved = false;
      _nameController.clear();
      _generateLevel();
    });
  }

  void _endGame() {
    setState(() {
      _gameState = GameState.gameOver;
    });
  }

  // YENİ BÖLÜM VE KÜP ÜRETİCİSİ
  void _generateLevel() {
    // Skor arttıkça küp sayısı artar. (Min 5, Max 16)
    int baseMin = 5 + (_score ~/ 20);
    int baseMax = 8 + (_score ~/ 15);
    
    int requestedCount = baseMin + _random.nextInt((baseMax - baseMin) + 1);
    if (requestedCount > 16) requestedCount = 16; // ASLA 16'YI GEÇMEZ

    // Azalan Merdiven mantığıyla küpleri üret
    _currentCubes = _generateStaircaseCubes(requestedCount);

    // GÜVENLİK KİLİDİ: Ekrana gerçekten kaç küp çizildiyse, doğru cevap odur!
    _targetCount = _currentCubes.length;

    // Yanıt Şıklarını Hazırla
    Set<int> optionsSet = {_targetCount};
    while (optionsSet.length < 4) {
      int offset = _random.nextInt(5) - 2; // -2, -1, 1, 2 farklarla şaşırt
      if (offset == 0) offset = 3;
      
      int fakeOption = _targetCount + offset;
      if (fakeOption > 0 && fakeOption != _targetCount) {
        optionsSet.add(fakeOption);
      }
    }
    _options = optionsSet.toList()..shuffle();
  }

  // KUSURSUZ GİZLENMEYİ ENGELLEYEN "AZALAN MERDİVEN" ALGORİTMASI
  List<Cube> _generateStaircaseCubes(int count) {
    List<Cube> cubes = [];
    
    // 3x3 lük tabandaki her bir sütunun yüksekliği (başlangıçta hepsi 0)
    List<List<int>> heights = List.generate(3, (_) => List.filled(3, 0));
    
    int added = 0;
    while (added < count) {
      List<Point<int>> validMoves = [];
      
      // Tüm 3x3 ızgarayı tara ve yeni bir küp koyulabilecek uygun yerleri bul
      for (int x = 0; x < 3; x++) {
        for (int z = 0; z < 3; z++) {
          int currentY = heights[x][z];
          int newY = currentY + 1;
          
          // Çok uzamasın diye max yükseklik sınırı (4 kat)
          if (newY > 4) continue; 
          
          bool isValid = true;
          // MUCİZE KURAL: Ön sütun, ASLA arka sütunu geçemez!
          // Bu kural, arkadaki küplerin daima görünür kalmasını sağlar.
          if (x > 0 && newY > heights[x-1][z]) isValid = false;
          if (z > 0 && newY > heights[x][z-1]) isValid = false;
          
          if (isValid) {
            validMoves.add(Point(x, z));
          }
        }
      }
      
      if (validMoves.isEmpty) break; // Eğer koyacak yer kalmazsa döngüyü kır
      
      // Geçerli hamlelerden rastgele birini seç ve küpü ekle
      Point<int> p = validMoves[_random.nextInt(validMoves.length)];
      cubes.add(Cube(p.x, heights[p.x][p.y], p.y));
      heights[p.x][p.y]++;
      added++;
    }
    return cubes;
  }

  void _onOptionSelected(int selectedValue) {
    if (selectedValue == _targetCount) {
      setState(() {
        _score += 15;
        _generateLevel(); // Doğru bildi, yenisine geç
      });
    } else {
      setState(() {
        _lives--;
        if (_lives <= 0) {
          _endGame();
        } else {
          _generateLevel(); // Yanlış bildi ama canı var, yeni soru ver
        }
      });
    }
  }

  // SKOR KAYDETME FONKSİYONU
  void _saveScore() {
    if (_nameController.text.trim().isNotEmpty) {
      setState(() {
        _localScores.add({
          "name": _nameController.text.trim(),
          "score": _score,
        });
        _localScores.sort((a, b) => b["score"].compareTo(a["score"]));
        _isScoreSaved = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Arka Plan
          Positioned.fill(
            child: Image.asset('assets/images/sayi_hafizasi_background_2.jpg', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),

                if (_gameState == GameState.ready)
                  _buildReadyScreen()
                else if (_gameState == GameState.gameOver)
                  _buildGameOverScreen()
                else
                  _buildGameArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // OYUN ALANI (3D KÜPLER VE ŞIKLAR)
  Widget _buildGameArea() {
    return Expanded(
      child: Column(
        children: [
          // KÜPLERİN ÇİZİLDİĞİ ALAN
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(double.infinity, 300),
                painter: CubePainter(_currentCubes),
              ),
            ),
          ),
          
          // SORU METNİ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              "Ekranda kaç adet küp var?",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: _primaryNavy),
            ),
          ),

          // ŞIKLAR (2x2 GRID)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.0,
              children: _options.map((opt) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: _primaryNavy, width: 3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 6,
                  ),
                  onPressed: () => _onOptionSelected(opt),
                  child: Text(
                    "$opt",
                    style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w900, color: _primaryNavy),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ÜST DURUM ÇUBUĞU
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: _primaryNavy, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _primaryNavy, width: 2),
            ),
            child: Text(
              "SKOR: $_score",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, color: _primaryNavy),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accentRed, width: 2),
            ),
            child: Row(
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: Icon(
                    index < _lives ? Icons.favorite : Icons.favorite_border,
                    color: _accentRed,
                    size: 20,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // BAŞLANGIÇ EKRANI
  Widget _buildReadyScreen() {
    return Expanded(
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _primaryNavy, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("KÜP SAYMA", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w900, color: _primaryNavy)),
              const SizedBox(height: 16),
              Text(
                "3 Boyutlu blokların toplam sayısını tahmin et. Arkada saklananlara dikkat et!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentRed,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _startGame,
                child: Text("OYUNA BAŞLA", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // OYUN SONU VE SKOR TABLOSU EKRANI
  Widget _buildGameOverScreen() {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _accentRed, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("OYUN BİTTİ!", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w900, color: _accentRed)),
                const SizedBox(height: 8),
                Text("Küp Sayma Skorun:", style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87)),
                Text("$_score", style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w900, color: _primaryNavy)),
                
                const Divider(height: 32, thickness: 2),

                if (!_isScoreSaved) ...[
                  Text("Tabloya Adını Yaz:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Örn: Baba, Zeynep",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                        onPressed: _saveScore,
                        child: Text("KAYDET", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                if (_localScores.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("🏆 En İyiler:", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: _primaryNavy)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 180),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _localScores.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _localScores[index];
                        bool isCurrent = _isScoreSaved && item["name"] == _nameController.text && item["score"] == _score;
                        return ListTile(
                          dense: true,
                          leading: Text("#${index + 1}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isCurrent ? _accentRed : _primaryNavy)),
                          title: Text(item["name"], style: GoogleFonts.poppins(fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600)),
                          trailing: Text("${item["score"]}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryNavy,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _startGame,
                  child: Text("YENİDEN BAŞLA", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =================================================================
/// ÖZEL 3D KÜP ÇİZİM MOTORU
/// =================================================================
class CubePainter extends CustomPainter {
  final List<Cube> cubes;
  final double size = 42.0; 

  CubePainter(this.cubes);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // İzometrik perspektif için derinlik algısına göre sıralama
    cubes.sort((a, b) {
      int depthA = a.x + a.z;
      int depthB = b.x + b.z;
      if (depthA != depthB) return depthA.compareTo(depthB);
      return a.y.compareTo(b.y);
    });

    double dw = size; // Genişlik yarıçapı
    double dh = size * 0.55; // Yükseklik yarıçapı

    // Merkez Noktası
    double originX = canvasSize.width / 2;
    double originY = canvasSize.height / 2 + (dh * 3);

    Paint topPaint = Paint()..color = const Color(0xFFFF6B6B)..style = PaintingStyle.fill;
    Paint leftPaint = Paint()..color = const Color(0xFFEE2B2B)..style = PaintingStyle.fill;
    Paint rightPaint = Paint()..color = const Color(0xFFB71C1C)..style = PaintingStyle.fill;
    
    Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    for (var cube in cubes) {
      double px = originX + (cube.x - cube.z) * dw;
      double py = originY + (cube.x + cube.z) * dh - (cube.y * dh * 2);

      Path topFace = Path()
        ..moveTo(px, py - dh * 2)
        ..lineTo(px + dw, py - dh)
        ..lineTo(px, py)
        ..lineTo(px - dw, py - dh)
        ..close();

      Path leftFace = Path()
        ..moveTo(px - dw, py - dh)
        ..lineTo(px, py)
        ..lineTo(px, py + dh * 2)
        ..lineTo(px - dw, py + dh)
        ..close();

      Path rightFace = Path()
        ..moveTo(px, py)
        ..lineTo(px + dw, py - dh)
        ..lineTo(px + dw, py + dh)
        ..lineTo(px, py + dh * 2)
        ..close();

      canvas.drawPath(topFace, topPaint);
      canvas.drawPath(leftFace, leftPaint);
      canvas.drawPath(rightFace, rightPaint);
      
      canvas.drawPath(topFace, borderPaint);
      canvas.drawPath(leftFace, borderPaint);
      canvas.drawPath(rightFace, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
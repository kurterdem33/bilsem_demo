import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

// OYUN DURUMLARI
enum GameState { ready, playing, gameOver }

// DAİRE MODELİ
class CircleTarget {
  final String id;
  final double x; // 0.0 ile 1.0 arası yatay pozisyon
  final double y; // 0.0 ile 1.0 arası dikey pozisyon
  final bool isRed; // Kırmızı (basılacak) veya Lacivert (basılmayacak)
  final int lifespan; // Ekranda kalma süresi (milisaniye)

  CircleTarget({
    required this.id,
    required this.x,
    required this.y,
    required this.isRed,
    required this.lifespan,
  });
}

class ReaksiyonOyunuPage extends StatefulWidget {
  const ReaksiyonOyunuPage({super.key});

  @override
  State<ReaksiyonOyunuPage> createState() => _ReaksiyonOyunuPageState();
}

class _ReaksiyonOyunuPageState extends State<ReaksiyonOyunuPage> {
  final Color _primaryNavy = const Color(0xFF0F172A);
  final Color _accentRed = const Color(0xFFEE2B2B);

  GameState _gameState = GameState.ready;
  int _score = 0;
  int _lives = 3;

  final Map<String, CircleTarget> _activeCircles = {};
  Timer? _spawnTimer;
  final Random _random = Random();

  // SKOR TABLOSU İÇİN DEĞİŞKENLER
  final List<Map<String, dynamic>> _localScores = [];
  final TextEditingController _nameController = TextEditingController();
  bool _isScoreSaved = false;

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameState = GameState.playing;
      _score = 0;
      _lives = 3;
      _activeCircles.clear();
      _isScoreSaved = false;
      _nameController.clear();
    });
    _scheduleNextSpawn();
  }

  void _endGame() {
    setState(() {
      _gameState = GameState.gameOver;
    });
    _spawnTimer?.cancel();
    _activeCircles.clear();
  }

  void _scheduleNextSpawn() {
    if (_gameState != GameState.playing) return;

    // Yavaşlatılmış çıkma hızı: Başlangıçta 1.8 saniye, en fazla 0.7 saniyeye düşer
    int spawnDelay = max(700, 1800 - (_score * 10));

    _spawnTimer = Timer(Duration(milliseconds: spawnDelay), () {
      _spawnCircle();
      _scheduleNextSpawn();
    });
  }

  void _spawnCircle() {
    if (_gameState != GameState.playing) return;

    String circleId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Kenarlara çok yapışmasın diye 0.1 ile 0.8 arası pozisyon
    double randomX = 0.1 + _random.nextDouble() * 0.7;
    double randomY = 0.1 + _random.nextDouble() * 0.7;
    
    bool isRedTarget = _random.nextDouble() < 0.7; // %70 kırmızı çıkar

    // Uzatılmış ekranda kalma süresi: Başlangıçta 2.5 saniye, en fazla 1 saniyeye düşer
    int currentLifespan = max(1000, 2500 - (_score * 15));

    CircleTarget newCircle = CircleTarget(
      id: circleId,
      x: randomX,
      y: randomY,
      isRed: isRedTarget,
      lifespan: currentLifespan,
    );

    setState(() {
      _activeCircles[circleId] = newCircle;
    });

    Timer(Duration(milliseconds: currentLifespan), () {
      _onCircleExpired(circleId);
    });
  }

  void _onCircleExpired(String id) {
    if (_gameState != GameState.playing) return;
    if (!_activeCircles.containsKey(id)) return;

    CircleTarget expiredCircle = _activeCircles[id]!;
    
    setState(() {
      _activeCircles.remove(id);
      // Kırmızı daire kaçarsa can gider
      if (expiredCircle.isRed) {
        _lives--;
        if (_lives <= 0) _endGame();
      }
    });
  }

  void _onCircleTapped(String id) {
    if (_gameState != GameState.playing) return;
    if (!_activeCircles.containsKey(id)) return;

    CircleTarget tappedCircle = _activeCircles[id]!;
    
    setState(() {
      _activeCircles.remove(id);
      
      if (tappedCircle.isRed) {
        // Doğru tıklama
        _score += 10;
      } else {
        // Yanlış (Lacivert) daireye tıklama
        _lives--;
        if (_lives <= 0) _endGame();
      }
    });
  }

  // SKOR KAYDETME FONKSİYONU
  void _saveScore() {
    if (_nameController.text.trim().isNotEmpty) {
      setState(() {
        _localScores.add({
          "name": _nameController.text.trim(),
          "score": _score,
        });
        // Puanları büyükten küçüğe sırala
        _localScores.sort((a, b) => b["score"].compareTo(a["score"]));
        _isScoreSaved = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Klavye açıldığında ekranın kaymasını sağlar
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

  // OYUN ALANI (DAİRELERİN ÇIKTIĞI YER)
  Widget _buildGameArea() {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: _activeCircles.values.map((circle) {
              return Positioned(
                left: circle.x * constraints.maxWidth,
                top: circle.y * constraints.maxHeight,
                child: _buildAnimatedCircle(circle),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // HAREKETLİ VE TEMİZ DAİRE WIDGET'I (İkonlar kaldırıldı)
  Widget _buildAnimatedCircle(CircleTarget circle) {
    // Çocuklar için büyütülmüş tıklama alanı
    final double circleSize = 95.0; 

    return GestureDetector(
      onTapDown: (_) => _onCircleTapped(circle.id),
      child: TweenAnimationBuilder<double>(
        // Çok fazla küçülmesini engelledik (end: 0.4)
        tween: Tween<double>(begin: 1.0, end: 0.4),
        duration: Duration(milliseconds: circle.lifespan),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circle.isRed ? _accentRed : _primaryNavy,
                boxShadow: [
                  BoxShadow(
                    color: (circle.isRed ? _accentRed : _primaryNavy).withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
                border: Border.all(color: Colors.white, width: 4),
              ),
              // İKONLAR TAMAMEN KALDIRILDI, İÇİ BOŞ.
            ),
          );
        },
      ),
    );
  }

  // ÜST BİLGİ ÇUBUĞU
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
              Text("REAKSİYON", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w900, color: _primaryNavy)),
              const SizedBox(height: 16),
              Text(
                "Sadece KIRMIZI dairelere dokun!\nLacivertlerden uzak dur.",
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
                Text("Skorun:", style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87)),
                Text("$_score", style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w900, color: _primaryNavy)),
                
                const Divider(height: 32, thickness: 2),

                // SKOR KAYIT ALANI
                if (!_isScoreSaved) ...[
                  Text("Tabloya Adını Yaz:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Örn: Anne, Efe",
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

                // SKOR TABLOSU LİSTESİ
                if (_localScores.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("🏆 En İyiler:", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: _primaryNavy)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 180), // Liste çok uzamasın diye
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
                        // Mevcut oyunda kaydedilen skoru vurgula
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

                // YENİDEN BAŞLA BUTONU
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
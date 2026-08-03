import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class SimetriOyunuPage extends StatefulWidget {
  const SimetriOyunuPage({super.key});

  @override
  State<SimetriOyunuPage> createState() => _SimetriOyunuPageState();
}

class _SimetriOyunuPageState extends State<SimetriOyunuPage> {
  // Oyun Durumu Değişkenleri
  bool _hasStarted = false;
  int _botSpeedMs = 1200; // Varsayılan hız

  int _currentLevel = 0;
  int _playerScore = 0;
  int _botScore = 0;
  
  double _playerProgress = 0.0;
  double _botProgress = 0.0;
  
  Timer? _botTimer;
  bool _isRoundActive = false;
  String _roundResultText = '';

  // Renk Paleti
  final Color _primaryNavy = const Color(0xFF0F172A); 
  final Color _accentRed = const Color(0xFFEE2B2B);   

  // 10 BÖLÜMLÜK YENİ MATRİS HAVUZU
  final List<List<List<int>>> _levels = [
    [ // 1. Bölüm (Kolay Başlangıç)
      [0, 0, 0, 1],
      [0, 0, 0, 1],
      [0, 0, 0, 1],
      [0, 0, 0, 0],
    ],
    [ // 2. Bölüm
      [0, 0, 1, 0],
      [0, 0, 1, 0],
      [0, 0, 1, 1],
      [0, 0, 0, 0],
    ],
    [ // 3. Bölüm
      [0, 0, 0, 1],
      [0, 0, 1, 0],
      [0, 1, 0, 0],
      [0, 0, 1, 0],
    ],
    [ // 4. Bölüm
      [0, 1, 0, 0],
      [0, 0, 1, 0],
      [0, 1, 0, 0],
      [1, 0, 0, 0],
    ],
    [ // 5. Bölüm (Artı İşareti)
      [0, 1, 0, 0],
      [1, 1, 1, 0],
      [0, 1, 0, 0],
      [0, 0, 0, 0],
    ],
    [ // 6. Bölüm (Köşeler)
      [0, 0, 0, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 1],
    ],
    [ // 7. Bölüm (Çapraz Damalar)
      [0, 1, 0, 1],
      [1, 0, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [ // 8. Bölüm (Merdiven)
      [0, 0, 0, 1],
      [0, 0, 1, 1],
      [0, 1, 1, 1],
      [0, 0, 0, 0],
    ],
    [ // 9. Bölüm (Çarpı)
      [1, 0, 0, 1],
      [0, 1, 1, 0],
      [0, 1, 1, 0],
      [1, 0, 0, 1],
    ],
    [ // 10. Bölüm (Karmaşık)
      [1, 1, 0, 0],
      [0, 0, 1, 1],
      [1, 1, 0, 0],
      [0, 0, 1, 1],
    ],
  ];

  late List<List<bool>> _userGrid;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _botTimer?.cancel();
    super.dispose();
  }

  void _startGame(int speedMs) {
    setState(() {
      _botSpeedMs = speedMs;
      _hasStarted = true;
    });
    _startRound();
  }

  void _startRound() {
    _botTimer?.cancel();
    _userGrid = List.generate(4, (_) => List.generate(4, (_) => false));
    _playerProgress = 0.0;
    _botProgress = 0.0;
    _isRoundActive = true;
    _roundResultText = '';

    _botTimer = Timer.periodic(Duration(milliseconds: _botSpeedMs), (timer) {
      if (!_isRoundActive) return;
      
      setState(() {
        _botProgress += 0.25; 
        if (_botProgress >= 1.0) {
          _botProgress = 1.0;
          _isRoundActive = false;
          _botScore++;
          _roundResultText = "Gölge Rakip Senden Hızlı Davrandı! 😈";
          _botTimer?.cancel();
        }
      });
    });
  }

  void _toggleCell(int row, int col) {
    if (!_isRoundActive) return;

    setState(() {
      _userGrid[row][col] = !_userGrid[row][col];
      _calculatePlayerProgress();
    });
  }

  void _calculatePlayerProgress() {
    List<List<int>> targetLevel = _levels[_currentLevel];
    int totalTargetBlocks = 0;
    int correctBlocks = 0;
    int wrongBlocks = 0;

    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        bool expected = targetLevel[r][c] == 1;
        bool actual = _userGrid[r][3 - c];

        if (expected) totalTargetBlocks++;
        if (expected && actual) correctBlocks++;
        if (!expected && actual) wrongBlocks++; 
      }
    }

    double currentProg = (correctBlocks - (wrongBlocks * 0.5)) / totalTargetBlocks;
    _playerProgress = currentProg.clamp(0.0, 1.0);

    if (correctBlocks == totalTargetBlocks && wrongBlocks == 0) {
      _isRoundActive = false;
      _botTimer?.cancel();
      _playerScore++;
      _roundResultText = "Harika! Rakibini Yendin! 🏆";
    }
  }

  void _nextLevel() {
    // KAZANMA VE BERABERLİK KONTROLÜ (İLK 6 YAPAN VEYA 10. BÖLÜM BİTTİYSE)
    if (_playerScore >= 6 || _botScore >= 6 || _currentLevel >= _levels.length - 1) {
      _showFinalMatchDialog();
    } else {
      setState(() {
        _currentLevel++;
        _startRound();
      });
    }
  }

  void _showFinalMatchDialog() {
    String title;
    Color titleColor;

    if (_playerScore >= 6) {
      title = "MAÇI KAZANDIN! 👑";
      titleColor = Colors.green;
    } else if (_botScore >= 6) {
      title = "GÖLGE RAKİP KAZANDI! 😈";
      titleColor = _accentRed;
    } else {
      // Skorlar eşitse (5-5 durumu)
      title = "DOSTLUK KAZANDI! 🤝\nBERABERE";
      titleColor = Colors.orange.shade700;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: titleColor, fontSize: 22),
        ),
        content: Text(
          "Maç Sonucu\nSen $_playerScore - $_botScore Rakip",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryNavy),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryNavy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size(double.infinity, 45),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); 
            },
            child: Text("SİSTEME DÖN", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand( 
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/sayi_hafizasi_background_2.jpg', fit: BoxFit.cover),
            ),

            SafeArea(
              child: !_hasStarted 
                  ? _buildDifficultyScreen() 
                  : _buildGameScreen(),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. ZORLUK SEÇİM EKRANI ---
  Widget _buildDifficultyScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: _primaryNavy, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ZORLUK SEÇİMİ",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w900, color: _primaryNavy, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "İlk 6 sayıyı alan maçı kazanır. Sana karşı oynayacak rakibin hızını belirle!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 40),
                  
                  ElevatedButton(
                    onPressed: () => _startGame(2500), 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ADE80),
                      minimumSize: const Size(double.infinity, 70),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 6,
                    ),
                    child: Text("KOLAY", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryNavy)),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  ElevatedButton(
                    onPressed: () => _startGame(1200), 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentRed,
                      minimumSize: const Size(double.infinity, 70),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 6,
                    ),
                    child: Text("ZOR", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. OYUN EKRANI ---
  Widget _buildGameScreen() {
    // Erken bitiş veya 10. Bölüm kontrolüne göre Buton Metni
    bool isMatchOver = _playerScore >= 6 || _botScore >= 6 || _currentLevel >= _levels.length - 1;
    String buttonText = isMatchOver ? "MAÇ SONUCUNU GÖR ➔" : "SONRAKİ BÖLÜM ➔";
    Color buttonColor = isMatchOver ? _primaryNavy : _accentRed;

    return Column(
      children: [
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
                  "KAPIŞMA: ${_currentLevel + 1}/10", // Mevcut turu gösterir
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22, 
                    fontWeight: FontWeight.w900, 
                    color: _primaryNavy, 
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 48), 
            ],
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("SEN: $_playerScore", style: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: _accentRed, fontSize: 18)),
              Text("VS", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16)),
              Text("RAKİP: $_botScore", style: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: _primaryNavy, fontSize: 18)),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 60, child: Text("Sen:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _primaryNavy))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _playerProgress,
                        minHeight: 14,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(_accentRed),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(width: 60, child: Text("Rakip:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _primaryNavy))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _botProgress,
                        minHeight: 14,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(_primaryNavy),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), 
            child: IntrinsicHeight( 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: _buildMatrixGrid(matrixData: _levels[_currentLevel]),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 6,
                    height: double.infinity, 
                    decoration: BoxDecoration(
                      color: _accentRed,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(color: _accentRed.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)
                      ],
                    ),
                  ),

                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: _buildInteractiveGrid(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const Spacer(),

        if (!_isRoundActive)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _roundResultText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: _primaryNavy),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                  ),
                  onPressed: _nextLevel,
                  child: Text(buttonText, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                )
              ],
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMatrixGrid({required List<List<int>> matrixData}) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 16,
      itemBuilder: (context, index) {
        int r = index ~/ 4;
        int c = index % 4;
        bool isFilled = matrixData[r][c] == 1;

        return Container(
          decoration: BoxDecoration(
            color: isFilled ? _primaryNavy : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _primaryNavy.withOpacity(0.3), width: 1.5),
          ),
        );
      },
    );
  }

  Widget _buildInteractiveGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 16,
      itemBuilder: (context, index) {
        int r = index ~/ 4;
        int c = index % 4;
        bool isFilled = _userGrid[r][c];

        return GestureDetector(
          onTap: () => _toggleCell(r, c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isFilled ? _accentRed : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isFilled ? _accentRed : _primaryNavy.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: isFilled ? [BoxShadow(color: _accentRed.withOpacity(0.4), blurRadius: 4)] : [],
            ),
            child: isFilled
                ? const Icon(Icons.star_rounded, color: Colors.white, size: 18)
                : null,
          ),
        );
      },
    );
  }
}
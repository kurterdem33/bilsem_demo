import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

enum GameMode { none, singlePlayer, multiPlayer }

class _TicTacToePageState extends State<TicTacToePage> {
  GameMode _gameMode = GameMode.none; // Başlangıçta mod seçilmemiş
  
  // Oyun tahtası (9 kare)
  List<String> _board = List.filled(9, '');
  
  // Skorlar
  int _xScore = 0; // X Oyuncusu (Kırmızı)
  int _oScore = 0; // O Oyuncusu veya Sistem (Koyu Lacivert)
  
  bool _isXTurn = true; // İlk hamle her zaman X'in
  bool _isMatchOver = false;
  String _matchWinner = '';
  
  // Renklerimiz
  final Color _colorX = const Color(0xFFEE2B2B); // Kırmızı
  final Color _colorO = const Color(0xFF0F172A); // Koyu Lacivert

  // Mod Seçim Fonksiyonu
  void _startGame(GameMode mode) {
    setState(() {
      _gameMode = mode;
      _resetMatch();
    });
  }

  // Oyuncu hamlesi
  void _handleTap(int index) {
    // Kare doluysa, maç bittiyse veya tek kişilik modda sıra botdaysa tıklamayı yoksay
    if (_board[index].isNotEmpty || _isMatchOver) return;
    if (_gameMode == GameMode.singlePlayer && !_isXTurn) return;

    String currentPlayer = _isXTurn ? 'X' : 'O';

    setState(() {
      _board[index] = currentPlayer;
      _isXTurn = !_isXTurn; // Sırayı diğer oyuncuya (veya bota) geçir
    });

    if (_checkWinner(currentPlayer)) {
      _endRound(currentPlayer);
    } else if (_checkDraw()) {
      _endRound('Berabere');
    } else {
      // Eğer tek kişilik oyunsa ve sıra 'O'ya (Bota) geçtiyse bot hamlesini tetikle
      if (_gameMode == GameMode.singlePlayer && !_isXTurn) {
        Future.delayed(const Duration(milliseconds: 500), _computerMove);
      }
    }
  }

  // Sistemin (Bot) hamlesi
  void _computerMove() {
    if (_isMatchOver) return;

    List<int> emptySpots = [];
    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        emptySpots.add(i);
      }
    }

    if (emptySpots.isNotEmpty) {
      final random = Random();
      int randomIndex = emptySpots[random.nextInt(emptySpots.length)];

      setState(() {
        _board[randomIndex] = 'O';
        _isXTurn = true; // Sırayı tekrar X'e ver
      });

      if (_checkWinner('O')) {
        _endRound('O');
      } else if (_checkDraw()) {
        _endRound('Berabere');
      }
    }
  }

  // Tur sonu işlemleri
  void _endRound(String winner) {
    if (winner == 'X') {
      _xScore++;
    } else if (winner == 'O') {
      _oScore++;
    }

    // 3 olan kazanır kontrolü
    if (_xScore == 3 || _oScore == 3) {
      setState(() {
        _isMatchOver = true;
        _matchWinner = winner;
      });
    } else {
      // Tur bittiyse tahtayı hafif bir gecikmeyle temizle
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && !_isMatchOver) {
          setState(() {
            _board = List.filled(9, '');
            _isXTurn = true; // Yeni tura her zaman X başlar
          });
        }
      });
    }
  }

  bool _checkWinner(String player) {
    const winLines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Yatay
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Dikey
      [0, 4, 8], [2, 4, 6]             // Çapraz
    ];

    for (var line in winLines) {
      if (_board[line[0]] == player &&
          _board[line[1]] == player &&
          _board[line[2]] == player) {
        return true;
      }
    }
    return false;
  }

  bool _checkDraw() {
    return !_board.contains('');
  }

  // Sadece skorları ve tahtayı sıfırlar (Modu korur)
  void _resetMatch() {
    setState(() {
      _board = List.filled(9, '');
      _xScore = 0;
      _oScore = 0;
      _isXTurn = true;
      _isMatchOver = false;
      _matchWinner = '';
    });
  }

  // Ana ekrana (Mod seçimine) döner
  void _backToMainMenu() {
    setState(() {
      _gameMode = GameMode.none;
    });
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
                // ORTAK ÜST BAR: Geri Tuşu ve Oyun Adı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
                        onPressed: () {
                          // Eğer mod seçiliyse mod seçimine dön, değilse uygulamadaki önceki sayfaya dön
                          if (_gameMode != GameMode.none) {
                            _backToMainMenu();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          "XOX OYUNU",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                        ),
                      ),
                      const SizedBox(width: 48), 
                    ],
                  ),
                ),

                // EKRAN YÖNETİMİ: Mod seçilmediyse Seçim Ekranı, seçildiyse Oyun Ekranı
                Expanded(
                  child: _gameMode == GameMode.none ? _buildModeSelection() : _buildGameBoard(),
                ),
              ],
            ),
          ),

          // MAÇ BİTİŞ EKRANI (OVERLAY)
          if (_isMatchOver)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          size: 72,
                          color: _matchWinner == 'X' ? _colorX : _colorO,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "$_matchWinner KAZANDI!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: _matchWinner == 'X' ? _colorX : _colorO,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _resetMatch, // Rovanş için
                          child: Text("TEKRAR OYNA", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _backToMainMenu, // Mod seçimine dönmek için
                          child: Text("FARKLI MOD SEÇ", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 1. MOD SEÇİM EKRANI WIDGET'I
  Widget _buildModeSelection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Nasıl Oynamak İstersin?",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 32),
            
            // Tek Kişilik Buton
            _buildModeButton(
              title: "1 OYUNCU",
              subtitle: "Yapay Zekaya Karşı",
              icon: Icons.person_rounded,
              color: const Color(0xFFEE2B2B),
              onTap: () => _startGame(GameMode.singlePlayer),
            ),
            
            const SizedBox(height: 20),
            
            // İki Kişilik Buton
            _buildModeButton(
              title: "2 OYUNCU",
              subtitle: "Arkadaşınla Birlikte",
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF0F172A),
              onTap: () => _startGame(GameMode.multiPlayer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // 2. OYUN TAHTASI EKRANI WIDGET'I
  Widget _buildGameBoard() {
    return Column(
      children: [
        // SKOR TABLOSU
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "X : $_xScore",
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: _colorX),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "-",
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
              ),
              Text(
                "O : $_oScore",
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: _colorO),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _gameMode == GameMode.singlePlayer ? "Sıra: ${_isXTurn ? 'Sende (X)' : 'Sistemde (O)'}" : "Sıra: ${_isXTurn ? 'Oyuncu 1 (X)' : 'Oyuncu 2 (O)'}",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A).withOpacity(0.8)),
        ),

        // 3x3 GRID
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                margin: const EdgeInsets.all(32),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _handleTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: Center(
                          child: AnimatedScale(
                            scale: _board[index].isEmpty ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.elasticOut,
                            child: Text(
                              _board[index],
                              style: GoogleFonts.poppins(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: _board[index] == 'X' ? _colorX : _colorO,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
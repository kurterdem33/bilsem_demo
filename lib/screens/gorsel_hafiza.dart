import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';

class GorselHafizaPage extends StatefulWidget {
  const GorselHafizaPage({super.key});

  @override
  State<GorselHafizaPage> createState() => _GorselHafizaPageState();
}

// YENİ: levelTransition eklendi, böylece intro ekranına geri dönmesi engellendi
enum GameState { intro, showingSequence, waitingForInput, levelTransition, gameOver, leaderboard }

class _GorselHafizaPageState extends State<GorselHafizaPage> {
  GameState _gameState = GameState.intro;
  
  int _level = 1;
  int _lives = 3;
  int _mistakesInLevel = 0;
  
  int _gridSize = 3; 
  List<int> _targetTiles = [];
  List<int> _tappedCorrect = [];
  List<int> _tappedWrong = [];
  
  bool _dontShowAgainChecked = false; // "Bir daha gösterme" tiki için durum
  
  final TextEditingController _nameController = TextEditingController();
  List<Map<String, dynamic>> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
    _checkIntroPref(); // Ekran açılırken hafızayı kontrol et
  }

  // Hafızada "Bir daha gösterme" seçili mi kontrolü
  Future<void> _checkIntroPref() async {
    final prefs = await SharedPreferences.getInstance();
    bool hideIntro = prefs.getBool('hide_visual_memory_intro') ?? false;
    
    if (hideIntro) {
      _startLevel(); // Tikli ise pop-up'ı atla ve direkt başla
    }
  }

  // Intro ekranından oyunu başlatma (ve gerekirse hafızaya kaydetme)
  void _onIntroStartClicked() async {
    if (_dontShowAgainChecked) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hide_visual_memory_intro', true);
    }
    _startLevel();
  }

  void _startLevel() {
    setState(() {
      _gridSize = 3 + ((_level - 1) ~/ 5);
      if (_gridSize > 6) _gridSize = 6;

      _mistakesInLevel = 0;
      _tappedCorrect.clear();
      _tappedWrong.clear();
      _gameState = GameState.showingSequence;
    });

    _generateTargetTiles();
    
    // YENİ: Karelerin ekranda kalma süresi 1500ms'den 800ms'ye (kısa süreye) düşürüldü
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _gameState = GameState.waitingForInput;
        });
      });
    });
  }

  void _generateTargetTiles() {
    _targetTiles.clear();
    int totalTiles = _gridSize * _gridSize;
    int targetCount = 3 + (_level ~/ 2);
    if (targetCount > totalTiles - 2) targetCount = totalTiles - 2;

    var random = Random();
    while (_targetTiles.length < targetCount) {
      int nextTile = random.nextInt(totalTiles);
      if (!_targetTiles.contains(nextTile)) {
        _targetTiles.add(nextTile);
      }
    }
  }

  void _onTileTapped(int index) {
    if (_gameState != GameState.waitingForInput) return;
    if (_tappedCorrect.contains(index) || _tappedWrong.contains(index)) return;

    setState(() {
      if (_targetTiles.contains(index)) {
        _tappedCorrect.add(index);
        
        // Bölüm Geçildiğinde
        if (_tappedCorrect.length == _targetTiles.length) {
          _gameState = GameState.levelTransition; // YENİ: Intro'ya değil geçiş moduna alıyoruz
          _level++;
          Future.delayed(const Duration(milliseconds: 800), _startLevel);
        }
      } else {
        _tappedWrong.add(index);
        _mistakesInLevel++;
        
        // Hata Limiti Dolduğunda
        if (_mistakesInLevel >= 3) {
          _lives--;
          if (_lives <= 0) {
            _gameState = GameState.gameOver;
          } else {
            _gameState = GameState.levelTransition; // Yeniden deneme öncesi kısa donma
            Future.delayed(const Duration(milliseconds: 1000), _startLevel);
          }
        }
      }
    });
  }

  Future<void> _loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? scores = prefs.getStringList('visual_memory_leaderboard');
    if (scores != null) {
      _leaderboard = scores.map((e) {
        var parts = e.split('|');
        return {'name': parts[0], 'level': int.parse(parts[1])};
      }).toList();
      _leaderboard.sort((a, b) => b['level'].compareTo(a['level']));
    }
  }

  Future<void> _saveScore() async {
    String name = _nameController.text.trim();
    if (name.isEmpty) name = "Oyuncu";

    _leaderboard.add({'name': name, 'level': _level});
    _leaderboard.sort((a, b) => b['level'].compareTo(a['level']));
    
    if (_leaderboard.length > 10) {
      _leaderboard = _leaderboard.sublist(0, 10);
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> scoresToSave = _leaderboard.map((e) => "${e['name']}|${e['level']}").toList();
    await prefs.setStringList('visual_memory_leaderboard', scoresToSave);

    setState(() {
      _gameState = GameState.leaderboard;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/sayi_hafizasi_background_2.jpg', fit: BoxFit.cover),
            ),
            
            SafeArea(
              // YENİ: Ekran yan döndüğünde taşmayı engellemek için kaydırılabilir alan eklendi
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // ÜST BAR TASARIMI (Alt alta iki satır)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Satır: Tam satırı kaplayan Koyu Lacivert Başlık ve Geri Tuşu
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Expanded(
                                child: Text(
                                  "Görsel Hafıza",
                                  textAlign: TextAlign.center, // Yazıyı merkeze alır
                                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                                ),
                              ),
                              const SizedBox(width: 48), // Geri butonunun kapladığı alan kadar sağda boşluk bırakarak tam ortalar
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // 2. Satır: Seviye ve Kırmızı Canlar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Seviye $_level", 
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                              Row(
                                children: List.generate(3, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Icon(
                                      index < _lives ? Icons.favorite : Icons.favorite_border,
                                      color: const Color(0xFFEE2B2B), // Parlak kırmızı
                                      size: 26,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // YENİ: Expanded kaldırıldı, yerine düz Center kondu çünkü artık ScrollView içindeyiz
                    Center(
                      child: _buildGameContent(),
                    ),
                    
                    const SizedBox(height: 24), // En alta nefes alma boşluğu eklendi
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameContent() {
    switch (_gameState) {
      case GameState.intro:
        return _buildIntroScreen();
      case GameState.showingSequence:
      case GameState.waitingForInput:
      case GameState.levelTransition: // Geçiş sırasında grid ekranda donuk durur
        return _buildGrid();
      case GameState.gameOver:
        return _buildGameOverScreen();
      case GameState.leaderboard:
        return _buildLeaderboardScreen();
    }
  }

  Widget _buildIntroScreen() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Nasıl Oynanır?", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 16),
          Text(
            "1. Ekrandaki beyaz karelerin yerlerini ezberle.\n\n"
            "2. Kareler gizlendiğinde hatırladığın doğru yerlere dokun!\n\n"
            "3. 3 canın var. Her 5 bölümde zorluk artar. Bol şans!",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 16),
          
          // YENİ: BİR DAHA GÖSTERME TİK KUTUSU
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _dontShowAgainChecked,
                activeColor: const Color(0xFFEE2B2B),
                side: const BorderSide(color: Colors.white),
                onChanged: (bool? value) {
                  setState(() {
                    _dontShowAgainChecked = value ?? false;
                  });
                },
              ),
              Text(
                "Bir daha gösterme",
                style: GoogleFonts.poppins(color: Colors.white),
              )
            ],
          ),
          
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE2B2B),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _onIntroStartClicked, // Checkbox kontrolü ile başlar
            child: Text("OYUNA BAŞLA", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.all(24),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _gridSize,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _gridSize * _gridSize,
          itemBuilder: (context, index) {
            
            // Karelerin durumlarına göre renk ve stateKey belirleme
            int stateKey = 1; // Default
            Color tileColor = Colors.white.withOpacity(0.3); // Hafif transparan matris 
            
            if (_gameState == GameState.showingSequence && _targetTiles.contains(index)) {
              stateKey = 2; // Target
              tileColor = Colors.white; 
            } else if (_gameState == GameState.waitingForInput || _gameState == GameState.levelTransition) {
              if (_tappedCorrect.contains(index)) {
                stateKey = 3; // Correct
                tileColor = Colors.white; 
              } else if (_tappedWrong.contains(index)) {
                stateKey = 4; // Wrong
                tileColor = const Color(0xFF1E293B).withOpacity(0.9); 
              }
            }

            return GestureDetector(
              onTap: () => _onTileTapped(index),
              // YENİ: FLIP (KART ÇEVİRME) ANİMASYONU
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    child: child,
                    builder: (context, ch) {
                      // scaleX kullanarak 3 boyutlu kart çevirme efekti veriyoruz
                      return Transform.scale(
                        scaleX: animation.value,
                        alignment: Alignment.center,
                        child: ch,
                      );
                    },
                  );
                },
                child: Container(
                  key: ValueKey<int>(stateKey), // stateKey değiştiğinde animasyon tetiklenir
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(12),
                    // YENİ: Siyah İnce Çerçeve
                    border: Border.all(color: Colors.black, width: 1.5), 
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      // YENİ: Ana sayfa scroll edilebilir olduğu için buradaki iç scroll kaldırıldı
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_score_rounded, size: 64, color: Color(0xFF0F172A)),
            const SizedBox(height: 16),
            Text("Oyun Bitti!", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            Text("Ulaştığın Seviye: $_level", style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey.shade700)),
            const SizedBox(height: 24),
            
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              cursorColor: const Color(0xFFEE2B2B),
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _saveScore(),
              decoration: InputDecoration(
                hintText: "Adını Yaz",
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0F172A), width: 2)),
              ),
            ),
            
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEE2B2B),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _saveScore,
              child: Text("SKORU KAYDET", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardScreen() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // YENİ: Sonsuz yükseklik almasını engeller
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("🏆 Liderlik Tablosu 🏆", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          ),
          // YENİ: Expanded kaldırıldı, yerine shrinkWrap ve NeverScrollableScrollPhysics eklendi
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _leaderboard.length,
            itemBuilder: (context, index) {
              var player = _leaderboard[index];
              Widget medal = Text("#${index + 1}", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold));
              
              if (index == 0) medal = const Text("🥇", style: TextStyle(fontSize: 24));
              if (index == 1) medal = const Text("🥈", style: TextStyle(fontSize: 24));
              if (index == 2) medal = const Text("🥉", style: TextStyle(fontSize: 24));

              return ListTile(
                leading: medal,
                title: Text(player['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                trailing: Text("Seviye ${player['level']}", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFFEE2B2B))),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text("SİSTEME GERİ DÖN", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class MuzikAletleriPage extends StatefulWidget {
  const MuzikAletleriPage({super.key});

  @override
  State<MuzikAletleriPage> createState() => _MuzikAletleriPageState();
}

class _MuzikAletleriPageState extends State<MuzikAletleriPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _playbackTimer;
  bool _isPlaying = false;
  
  // 22 MÜZİK ALETİ HAVUZU (Senin hazırladığın liste)
  final List<Map<String, String>> _allInstruments = [
    {"name": "AKORDİYON", "image": "assets/images/music/akordiyon.png", "audio": "audio/akordion.mp3"},
    {"name": "ARP", "image": "assets/images/music/arp.png", "audio": "audio/arp.mp3"},
    {"name": "BAĞLAMA", "image": "assets/images/music/baglama.png", "audio": "audio/baglama.mp3"},
    {"name": "BATERİ", "image": "assets/images/music/bateri.png", "audio": "audio/bateri.mp3"},
    {"name": "DARBUKA", "image": "assets/images/music/darbuka.png", "audio": "audio/darbuka.mp3"},
    {"name": "DAVUL", "image": "assets/images/music/davul.png", "audio": "audio/davul.mp3"},
    {"name": "ELEKTRO GİTAR", "image": "assets/images/music/elektro_gitar.png", "audio": "audio/elektro_gitar.mp3"},
    {"name": "FLÜT", "image": "assets/images/music/flut.png", "audio": "audio/flut.mp3"},
    {"name": "GİTAR", "image": "assets/images/music/gitar.png", "audio": "audio/gitar.mp3"},
    {"name": "KANUN", "image": "assets/images/music/kanun.png", "audio": "audio/kanun.mp3"},
    {"name": "KEMAN", "image": "assets/images/music/keman.png", "audio": "audio/keman.mp3"},
    {"name": "KEMENÇE", "image": "assets/images/music/kemence.png", "audio": "audio/kemence.mp3"},
    {"name": "KLARNET", "image": "assets/images/music/klarnet.png", "audio": "audio/klarnet.mp3"},
    {"name": "KSİLOFON", "image": "assets/images/music/ksilofon.png", "audio": "audio/ksilofon.mp3"},
    {"name": "MARAKAS", "image": "assets/images/music/marakas.png", "audio": "audio/marakas.mp3"},
    {"name": "MIZIKA", "image": "assets/images/music/mizika.png", "audio": "audio/mizika.mp3"},
    {"name": "PİYANO", "image": "assets/images/music/piyano.png", "audio": "audio/piyano.mp3"},
    {"name": "SAKSAFON", "image": "assets/images/music/saksafon.png", "audio": "audio/saksafon.mp3"},
    {"name": "TROMPET", "image": "assets/images/music/trompet.png", "audio": "audio/trompet.mp3"},
    {"name": "TULUM", "image": "assets/images/music/tulum.png", "audio": "audio/tulum.mp3"},
    {"name": "ZİLLİ TEF", "image": "assets/images/music/zilli_tef.png", "audio": "audio/zilli_tef.mp3"},
    {"name": "ZURNA", "image": "assets/images/music/zurna.png", "audio": "audio/zurna.mp3"},
  ];

  late List<Map<String, String>> _gameQuestions;
  int _currentIndex = 0;
  List<Map<String, String>> _currentOptions = [];
  bool _isAnswered = false;
  String? _selectedOptionName;

  @override
  void initState() {
    super.initState();
    _startNewGame();
    
    // Ses çalma durumu değiştiğinde ikonu günceller
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startNewGame() {
    _allInstruments.shuffle(); // Havuzu karıştır
    _gameQuestions = _allInstruments.take(10).toList(); // 10 Soru seç
    _currentIndex = 0;
    _loadQuestion();
  }

  void _loadQuestion() {
    _stopAudio(); 
    
    setState(() {
      _isAnswered = false;
      _selectedOptionName = null;
      
      var correctInstrument = _gameQuestions[_currentIndex];
      
      // Çeldirici Şıkkı Bul (Doğru cevap olmayan rastgele biri)
      var wrongInstruments = _allInstruments.where((inst) => inst["name"] != correctInstrument["name"]).toList();
      wrongInstruments.shuffle();
      var wrongInstrument = wrongInstruments.first;

      _currentOptions = [correctInstrument, wrongInstrument];
      _currentOptions.shuffle(); // Sağ-sol yerini karıştır
    });
  }

  void _toggleAudio() async {
    if (_isPlaying) {
      _stopAudio();
    } else {
      String audioPath = _gameQuestions[_currentIndex]["audio"]!;
      await _audioPlayer.play(AssetSource(audioPath));
      
      // 10 Saniye Kuralı
      _playbackTimer?.cancel();
      _playbackTimer = Timer(const Duration(seconds: 10), () {
        _stopAudio();
      });
    }
  }

  void _stopAudio() {
    _playbackTimer?.cancel();
    _audioPlayer.stop();
  }

  void _checkAnswer(String selectedName) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedOptionName = selectedName;
    });

    String correctName = _gameQuestions[_currentIndex]["name"]!;

    if (selectedName == correctName) {
      _stopAudio(); 
      Timer(const Duration(milliseconds: 1000), () {
        if (_currentIndex < 9) {
          setState(() {
            _currentIndex++;
            _loadQuestion();
          });
        } else {
          _showResultDialog();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sesi iyi dinle, tekrar dene! 🎶", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 1),
        ),
      );
      Timer(const Duration(seconds: 1), () {
        setState(() {
          _isAnswered = false;
          _selectedOptionName = null;
        });
      });
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Müzik Kulağı Harika! 🎵", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Bütün enstrüman seslerini doğru bildin!", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, height: 1.5)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); 
            },
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), child: Text("Menüye Dön", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_gameQuestions.isEmpty) return const SizedBox();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/sayi_hafizasi_background.jpg', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                // ÜST BİLGİ BARI
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 28),
                        onPressed: () {
                          _stopAudio();
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Text(
                          "Müzik Aletleri",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFEE2B2B), borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "${_currentIndex + 1} / 10",
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                // PLAY BUTONU
                Expanded(
                  flex: 2,
                  child: Center(
                    child: GestureDetector(
                      onTap: _toggleAudio,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isPlaying ? Colors.white : const Color(0xFFEE2B2B),
                          boxShadow: [
                            BoxShadow(
                              color: _isPlaying ? Colors.white.withOpacity(0.6) : const Color(0xFFEE2B2B).withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: 10,
                            )
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                          size: 70,
                          color: _isPlaying ? const Color(0xFFEE2B2B) : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                Text(
                  "Sesi dinle ve doğru aleti seç!",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 20),

                // ŞIKLAR (Sadece PNG resimleri içerir, fazladan Text yazısı yoktur)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      children: [
                        Expanded(child: _buildImageOption(_currentOptions[0])),
                        const SizedBox(width: 16),
                        Expanded(child: _buildImageOption(_currentOptions[1])),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageOption(Map<String, String> option) {
    String optionName = option["name"]!;
    String correctName = _gameQuestions[_currentIndex]["name"]!;
    
    Color borderColor = Colors.transparent;
    Color overlayColor = Colors.transparent;

    // Doğru ve yanlış cevaplar için renk ayarlamaları
    if (_isAnswered && _selectedOptionName == optionName) {
      if (optionName == correctName) {
        borderColor = Colors.green;
        overlayColor = Colors.green.withOpacity(0.2); // Resim bozulmasın diye daha saydam
      } else {
        borderColor = Colors.redAccent;
        overlayColor = Colors.redAccent.withOpacity(0.2);
      }
    } else if (_isAnswered && optionName == correctName) {
      borderColor = Colors.green;
      overlayColor = Colors.green.withOpacity(0.2);
    }

    return GestureDetector(
      onTap: () => _checkAnswer(optionName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white, // Şeffaf PNG'ler beyaz arkaplanda güzel durur
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 6),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
        ),
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.all(12.0), // Resim ile çerçeve arasına biraz boşluk
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sadece Cihazdaki PNG Resmini Göster
            Image.asset(
              option["image"]!,
              fit: BoxFit.contain, 
            ),
            // Doğru/Yanlış durumunda ortaya çıkan renk filtresi
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: overlayColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
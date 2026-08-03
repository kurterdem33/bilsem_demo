import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';

class NotalarOyunuPage extends StatefulWidget {
  const NotalarOyunuPage({super.key});

  @override
  State<NotalarOyunuPage> createState() => _NotalarOyunuPageState();
}

class _NotalarOyunuPageState extends State<NotalarOyunuPage> {
  final Color _primaryNavy = const Color(0xFF0F172A);
  final Color _accentRed = const Color(0xFFEE2B2B);

  // Ses oynatıcı nesnesi
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 6 Farklı Ses Dosyası (image_d9bc71.png klasör yapısına uygun)
  final List<String> _soundFiles = [
    'a.mp3',
    'b.mp3',
    'c.mp3',
    'd.mp3',
    'e.mp3',
    'f.mp3'
  ];

  // 6 Farklı Nota/Buton Rengi
  final List<Color> _padColors = [
    const Color(0xFFEE2B2B), // Kırmızı
    const Color(0xFF0F172A), // Koyu Lacivert
    const Color(0xFFF59E0B), // Sarı
    const Color(0xFF10B981), // Yeşil
    const Color(0xFF8B5CF6), // Mor
    const Color(0xFF06B6D4), // Turkuaz
  ];

  List<int> _botSequence = []; // Oyunun oluşturduğu sıra
  int _playerIndex = 0; // Oyuncunun o an kaçıncı notaya bastığını takip eder

  int _score = 0;
  int _lives = 3;
  int _activePadIndex = -1; // O an parlayan butonun indexi
  
  bool _isPlayerTurn = false;
  String _statusText = "OYUNA BAŞLA!";

  @override
  void dispose() {
    _audioPlayer.dispose(); // Sayfa kapanırken ses motorunu temizle
    super.dispose();
  }

  // Yeni tur başlat (Diziye 1 yeni nota ekle)
  void _startNextRound() {
    setState(() {
      _isPlayerTurn = false;
      _playerIndex = 0;
      _statusText = "DİNLE VE İZLE... 🎧";
      
      // Diziye rastgele 0 ile 5 arasında (6 butondan biri) ekle
      _botSequence.add(Random().nextInt(6));
    });

    // 1 saniye bekleyip diziyi oynatmaya başla
    Future.delayed(const Duration(seconds: 1), _playSequence);
  }

  // Oyunun kendi dizisini sırayla çaldığı ve parlattığı fonksiyon
  Future<void> _playSequence() async {
    for (int index in _botSequence) {
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Butonu Parlat ve Sesi Çal
      if (mounted) setState(() => _activePadIndex = index);
      _playSound(index);
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Butonu Söndür
      if (mounted) setState(() => _activePadIndex = -1);
    }

    // Sıra oyuncuya geçti
    if (mounted) {
      setState(() {
        _isPlayerTurn = true;
        _statusText = "SIRA SENDE! 🧠";
      });
    }
  }

  // Çocuğun butonlara bastığında tetiklenen fonksiyon
  void _onPadTapped(int index) {
    if (!_isPlayerTurn) return; // Çocuğun erkenden basmasını engeller

    // Basılan butonu anlık olarak parlat ve sesi çal
    setState(() => _activePadIndex = index);
    _playSound(index);
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _activePadIndex = -1);
    });

    // Doğru butona mı bastı?
    if (index == _botSequence[_playerIndex]) {
      _playerIndex++; // Sıradaki notaya geç

      // Tüm diziyi doğru tamamladıysa
      if (_playerIndex == _botSequence.length) {
        setState(() {
          _isPlayerTurn = false;
          _score += 10;
          _statusText = "HARİKA! SEVİYE ARTIYOR... 🚀";
        });
        Future.delayed(const Duration(milliseconds: 1500), _startNextRound);
      }
    } else {
      // YANLIŞ NOTAYA BASTI!
      setState(() {
        _isPlayerTurn = false;
        _lives--;
        _statusText = "YANLIŞ NOTA! ❌";
      });

      if (_lives > 0) {
        // Canı varsa aynı diziyi tekrar çaldırıp şans ver
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _playerIndex = 0;
              _statusText = "TEKRAR DİNLE... 🎧";
            });
            Future.delayed(const Duration(seconds: 1), _playSequence);
          }
        });
      }
    }
  }

  // --- GÜNCELLENEN SES ÇALMA FONKSİYONU ---
  Future<void> _playSound(int index) async {
    try {
      // Yeni notaya basıldığında önce çalan sesi ANINDA DURDUR (Gecikmeyi ve kuyruğu önler)
      await _audioPlayer.stop(); 
      // Ardından yeni sesi beklemeden başlat
      await _audioPlayer.play(AssetSource('sesler/${_soundFiles[index]}'));
    } catch (e) {
      debugPrint("Ses çalma hatası: $e");
    }
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
                _buildTopBar(),

                if (_lives <= 0)
                  _buildGameOverScreen()
                else ...[
                  // BİLGİ VE DURUM METNİ
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: Text(
                        _statusText,
                        style: GoogleFonts.poppins(
                          fontSize: 18, 
                          fontWeight: FontWeight.w900, 
                          color: _isPlayerTurn ? Colors.green.shade700 : _primaryNavy,
                        ),
                      ),
                    ),
                  ),

                  // 6 NOTA BUTONU (PADLER - 3 Satır x 2 Sütun)
                  Expanded(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: GridView.builder(
                          shrinkWrap: true, // İçeriğe göre boyutlanması için
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 Sütun
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2, // Hafif yatay dikdörtgen tablet uyumu için
                          ),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return _buildMusicPad(index);
                          },
                        ),
                      ),
                    ),
                  ),

                  // BAŞLAT BUTONU (Sadece ilk başlangıçta görünür)
                  if (_botSequence.isEmpty && _lives > 0)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentRed,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 8,
                        ),
                        onPressed: _startNextRound,
                        child: Text(
                          "İLK SEVİYEYİ BAŞLAT", 
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 24), // Boşluk
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3D HİSLİ MÜZİK BUTONLARI WIDGET'I
  Widget _buildMusicPad(int index) {
    bool isActive = _activePadIndex == index;
    Color baseColor = _padColors[index];

    return GestureDetector(
      onTapDown: (_) => _onPadTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          // Aktifse (basılmışsa) rengi açılır (beyazla karışır)
          color: isActive ? Color.lerp(baseColor, Colors.white, 0.4) : baseColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: isActive ? 4 : 2),
          boxShadow: isActive
              ? [
                  BoxShadow(color: baseColor.withOpacity(0.9), blurRadius: 30, spreadRadius: 6),
                ]
              : [
                  const BoxShadow(color: Colors.black45, offset: Offset(0, 6), blurRadius: 6),
                ],
        ),
        // Basıldığında hafifçe küçülerek fiziksel buton hissi verir
        transform: Matrix4.identity()..scale(isActive ? 0.90 : 1.0),
        transformAlignment: Alignment.center,
        child: Center(
          child: Icon(
            Icons.music_note_rounded,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
            size: isActive ? 48 : 40,
          ),
        ),
      ),
    );
  }

  // ÜST DURUM BARI
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

  // OYUN BİTTİ EKRANI
  Widget _buildGameOverScreen() {
    return Expanded(
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
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
              const SizedBox(height: 16),
              Text("Müzikal Hafıza Skorun:", style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87)),
              Text("$_score", style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w900, color: _primaryNavy)),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryNavy,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  setState(() {
                    _score = 0;
                    _lives = 3;
                    _botSequence.clear();
                  });
                },
                child: Text("YENİDEN BAŞLA", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
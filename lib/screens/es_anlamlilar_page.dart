import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EsAnlamlilarPage extends StatefulWidget {
  const EsAnlamlilarPage({super.key});

  @override
  State<EsAnlamlilarPage> createState() => _EsAnlamlilarPageState();
}

class _EsAnlamlilarPageState extends State<EsAnlamlilarPage> {
  final List<Map<String, String>> _allPairs = [
    {"word": "Sulh", "synonym": "Barış"},
    {"word": "Okul", "synonym": "Mektep"},
    {"word": "Rüya", "synonym": "Düş"},
    {"word": "Fakir", "synonym": "Yoksul"},
    {"word": "Veteriner", "synonym": "Baytar"},
    {"word": "Anı", "synonym": "Hatıra"},
    {"word": "Beyaz", "synonym": "Ak"},
    {"word": "Millet", "synonym": "Ulus"},
    {"word": "Kalp", "synonym": "Yürek"},
    {"word": "Öğretmen", "synonym": "Muallim"},
    {"word": "Yemek", "synonym": "Aş"},
    {"word": "Şehir", "synonym": "Kent"},
    {"word": "Fiyat", "synonym": "Ücret"},
    {"word": "Hata", "synonym": "Yanlış"},
    {"word": "Hızlı", "synonym": "Süratli"},
    {"word": "Zor", "synonym": "Güç"},
    {"word": "Cevap", "synonym": "Yanıt"},
    {"word": "Soru", "synonym": "Sual"},
    {"word": "Yardım", "synonym": "Destek"},
    {"word": "Son", "synonym": "Nihayet"},
    {"word": "Misafir", "synonym": "Konuk"},
    {"word": "Öğrenci", "synonym": "Talebe"},
    {"word": "Medeniyet", "synonym": "Uygarlık"},
    {"word": "Siyah", "synonym": "Kara"},
    {"word": "Armağan", "synonym": "Hediye"},
    {"word": "Meydan", "synonym": "Alan"},
    {"word": "Tabiat", "synonym": "Doğa"},
    {"word": "Yıl", "synonym": "Sene"},
    {"word": "Hikâye", "synonym": "Öykü"},
    {"word": "İsim", "synonym": "Ad"},
    {"word": "Sınav", "synonym": "İmtihan"},
    {"word": "Hekim", "synonym": "Doktor"},
    {"word": "Deprem", "synonym": "Zelzele"},
    {"word": "Hemen", "synonym": "Derhal"},
    {"word": "Berrak", "synonym": "Duru"},
    {"word": "Akıl", "synonym": "Zekâ"},
    {"word": "Neşe", "synonym": "Sevinç"},
    {"word": "Yurt", "synonym": "Vatan"},
    {"word": "Görev", "synonym": "Vazife"},
    {"word": "Misal", "synonym": "Örnek"},
  ];

  int _currentSetIndex = 0;
  List<Map<String, String>> _currentLeftWords = [];
  List<Map<String, String>> _currentRightWords = [];
  Set<String> _matchedWords = {}; 

  @override
  void initState() {
    super.initState();
    _allPairs.shuffle();
    _loadCurrentSet();
  }

  void _loadCurrentSet() {
    setState(() {
      _matchedWords.clear();
      int startIndex = _currentSetIndex * 4;
      List<Map<String, String>> currentFour = _allPairs.sublist(startIndex, startIndex + 4);

      _currentLeftWords = List.from(currentFour)..shuffle();
      _currentRightWords = List.from(currentFour)..shuffle();
    });
  }

  void _onMatch(String word) {
    setState(() {
      _matchedWords.add(word);
    });

    if (_matchedWords.length == 4) {
      Timer(const Duration(milliseconds: 1000), () {
        if (_currentSetIndex < 9) {
          setState(() {
            _currentSetIndex++;
            _loadCurrentSet();
          });
        } else {
          _showResultDialog();
        }
      });
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Tebrikler! 🏆", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Bütün eş anlamlıları tamamladın; kelime dağarcığını kanıtladın!", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), child: Text("Menüye Dön", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color targetRed = Color(0xFFEE2B2B);

    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/sayi_hafizasi_background.jpg', fit: BoxFit.cover),
            ),
            SafeArea(
              // === SİHİRLİ ÜÇLÜ BURADA BAŞLIYOR ===
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight, // İçeriği en az ekran boyu kadar uzmaya zorlar
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 28),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Eş Anlamlılar",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(color: targetRed, borderRadius: BorderRadius.circular(20)),
                                    child: Text(
                                      "${_currentSetIndex + 1} / 10",
                                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Sarı kutuları doğru eşleriyle birleştir!",
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 30),

                            // YENİDEN EXPANDED VE SPACE EVENLY EKLENDİ!
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Dikeyde mükemmel eşit dağılım
                                        children: _currentLeftWords.map((pair) {
                                          bool isMatched = _matchedWords.contains(pair["word"]);
                                          return Draggable<String>(
                                            data: pair["word"],
                                            feedback: Material(
                                              color: Colors.transparent,
                                              child: _buildBox(pair["word"]!, isDragging: true),
                                            ),
                                            childWhenDragging: Opacity(
                                              opacity: 0.3,
                                              child: _buildBox(pair["word"]!),
                                            ),
                                            child: isMatched 
                                                ? const Opacity(opacity: 0.0, child: SizedBox(height: 60, width: double.infinity)) 
                                                : _buildBox(pair["word"]!),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    const SizedBox(width: 24), 
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Dikeyde mükemmel eşit dağılım
                                        children: _currentRightWords.map((pair) {
                                          bool isMatched = _matchedWords.contains(pair["word"]);
                                          return DragTarget<String>(
                                            onAccept: (receivedWord) {
                                              if (receivedWord == pair["word"]) {
                                                _onMatch(receivedWord);
                                              }
                                            },
                                            builder: (context, candidateData, rejectedData) {
                                              return isMatched
                                                  ? _buildMatchedBox("${pair["word"]} = ${pair["synonym"]}")
                                                  : _buildTargetBox(pair["synonym"]!, isHovered: candidateData.isNotEmpty);
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // === SİHİRLİ ÜÇLÜ BİTİŞ ===
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(String text, {bool isDragging = false}) {
    return Container(
      width: isDragging ? 140 : double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFFCA28),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 4)),
        ],
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
      ),
    );
  }

  Widget _buildTargetBox(String text, {bool isHovered = false}) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: isHovered ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isHovered ? const Color(0xFFEE2B2B) : Colors.transparent, width: 2),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
      ),
    );
  }

  Widget _buildMatchedBox(String text) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF4ADE80), 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 4)),
        ],
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }
}
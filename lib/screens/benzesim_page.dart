import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class BenzesimPage extends StatefulWidget {
  const BenzesimPage({super.key});

  @override
  State<BenzesimPage> createState() => _BenzesimPageState();
}

class _BenzesimPageState extends State<BenzesimPage> {
  // 60 Soruluk Dev Benzeşim (Analoji) Havuzu ve Çeldirici Şıklar
  final List<Map<String, dynamic>> _allQuestions = [
    {"q1": "RÜZGAR - ESMEK", "q2": "YAĞMUR", "options": ["YAĞMAK", "GÜRLEMEK"], "answer": "YAĞMAK"},
    {"q1": "PARMAK - YÜZÜK", "q2": "KULAK", "options": ["KÜPE", "KOLYE"], "answer": "KÜPE"},
    {"q1": "HOROZ - ÖTMEK", "q2": "KÖPEK", "options": ["HAVLAMAK", "MİYAVLAMAK"], "answer": "HAVLAMAK"},
    {"q1": "KAMYON - ŞOFÖR", "q2": "UÇAK", "options": ["PİLOT", "GARDİYAN"], "answer": "PİLOT"},
    {"q1": "BALIK - YÜZGEÇ", "q2": "KUŞ", "options": ["KANAT", "GAGA"], "answer": "KANAT"},
    {"q1": "MAKAS - KESMEK", "q2": "TERAZİ", "options": ["TARTMAK", "SATMAK"], "answer": "TARTMAK"},
    {"q1": "ODA - AMPÜL", "q2": "DÜNYA", "options": ["GÜNEŞ", "GEZEGEN"], "answer": "GÜNEŞ"},
    {"q1": "AÇ - TOK", "q2": "ÖDÜL", "options": ["CEZA", "HEDİYE"], "answer": "CEZA"},
    {"q1": "DEVAMLI - SÜREKLİ", "q2": "DOST", "options": ["ARKADAŞ", "DÜŞMAN"], "answer": "ARKADAŞ"},
    {"q1": "ALFABE - HARF", "q2": "SAYI", "options": ["RAKAM", "TOPLAMA"], "answer": "RAKAM"},
    {"q1": "KALEM - YAZMAK", "q2": "SİLGİ", "options": ["SİLMEK", "ÇİZMEK"], "answer": "SİLMEK"},
    {"q1": "KUŞ - KANAT", "q2": "BALIK", "options": ["YÜZGEÇ", "PUL"], "answer": "YÜZGEÇ"},
    {"q1": "KALEM - YAZMAK", "q2": "FIRÇA", "options": ["BOYAMAK", "KESMEK"], "answer": "BOYAMAK"},
    {"q1": "KİTAP - OKUMAK", "q2": "TELEVİZYON", "options": ["İZLEMEK", "KAPATMAK"], "answer": "İZLEMEK"},
    {"q1": "ARI - BAL", "q2": "İNEK", "options": ["SÜT", "OT"], "answer": "SÜT"},
    {"q1": "DOKTOR - HASTANE", "q2": "ÖĞRETMEN", "options": ["OKUL", "MARKET"], "answer": "OKUL"},
    {"q1": "İTFAİYECİ - YANGIN", "q2": "POLİS", "options": ["GÜVENLİK", "HASTA"], "answer": "GÜVENLİK"},
    {"q1": "GÜNEŞ - GÜNDÜZ", "q2": "AY", "options": ["GECE", "YILDIZ"], "answer": "GECE"},
    {"q1": "YAZ - SICAK", "q2": "KIŞ", "options": ["SOĞUK", "ERİMEK"], "answer": "SOĞUK"},
    {"q1": "EL - ELDİVEN", "q2": "AYAK", "options": ["ÇORAP", "KÜPE"], "answer": "ÇORAP"},
    {"q1": "DİŞ FIRÇASI - DİŞ", "q2": "TARAK", "options": ["SAÇ", "TIRNAK"], "answer": "SAÇ"},
    {"q1": "KUŞ - YUVA", "q2": "ARI", "options": ["KOVAN", "BAL"], "answer": "KOVAN"},
    {"q1": "KEDİ - MİYAVLAMAK", "q2": "İNEK", "options": ["MÖLEMEK", "MELEMEK"], "answer": "MÖLEMEK"},
    {"q1": "KOYUN - YÜN", "q2": "TAVUK", "options": ["YUMURTA", "SÜT"], "answer": "YUMURTA"},
    {"q1": "BALIK - SU", "q2": "KUŞ", "options": ["GÖKYÜZÜ", "ÇAMUR"], "answer": "GÖKYÜZÜ"},
    {"q1": "ÇİÇEK - KIR", "q2": "AĞAÇ", "options": ["ORMAN", "DAL"], "answer": "ORMAN"},
    {"q1": "SAAT - ZAMAN", "q2": "TERMOMETRE", "options": ["SICAKLIK", "HASTALIK"], "answer": "SICAKLIK"},
    {"q1": "GÖZ - GÖRMEK", "q2": "KULAK", "options": ["DUYMAK", "KONUŞMAK"], "answer": "DUYMAK"},
    {"q1": "BURUN - KOKLAMAK", "q2": "DİL", "options": ["TATMAK", "ISIRMAK"], "answer": "TATMAK"},
    {"q1": "MAKAS - KESMEK", "q2": "SÜPÜRGE", "options": ["SÜPÜRMEK", "YIKAMAK"], "answer": "SÜPÜRMEK"},
    {"q1": "FIRÇA - BOYAMAK", "q2": "KALEM", "options": ["YAZMAK", "OKUMAK"], "answer": "YAZMAK"},
    {"q1": "KAPI - TIKLATMAK", "q2": "ZİL", "options": ["ÇALMAK", "KAPATMAK"], "answer": "ÇALMAK"},
    {"q1": "KIŞ - MONT", "q2": "YAZ", "options": ["TİŞÖRT", "KAZAK"], "answer": "TİŞÖRT"},
    {"q1": "BEBEK - EMEKLEMEK", "q2": "ÇOCUK", "options": ["YÜRÜMEK", "UÇMAK"], "answer": "YÜRÜMEK"},
    {"q1": "TOHUM - AĞAÇ", "q2": "YUMURTA", "options": ["CİVCİV", "OMLET"], "answer": "CİVCİV"},
    {"q1": "KUŞ - YUVA", "q2": "KÖPEK", "options": ["KULÜBE", "KEMİK"], "answer": "KULÜBE"},
    {"q1": "ŞEMSİYE - YAĞMUR", "q2": "ŞAPKA", "options": ["GÜNEŞ", "AY"], "answer": "GÜNEŞ"},
    {"q1": "BARDAK - SU", "q2": "TABAK", "options": ["YEMEK", "ÇATAL"], "answer": "YEMEK"},
    {"q1": "ANAHTAR - KAPI", "q2": "KUMANDA", "options": ["TELEVİZYON", "TABAK"], "answer": "TELEVİZYON"},
    {"q1": "ARI - KOVAN", "q2": "TAVUK", "options": ["KÜMES", "YUMURTA"], "answer": "KÜMES"},
    {"q1": "HAVUÇ - TAVŞAN", "q2": "PEYNİR", "options": ["FARE", "İNEK"], "answer": "FARE"},
    {"q1": "ÇOBAN - KOYUN", "q2": "ÇİÇEKÇİ", "options": ["ÇİÇEK", "BÖCEK"], "answer": "ÇİÇEK"},
    {"q1": "TERZİ - İĞNE", "q2": "MARANGOZ", "options": ["TESTERE", "ÜTÜ"], "answer": "TESTERE"},
    {"q1": "ÇİFTÇİ - TARLA", "q2": "BALIKÇI", "options": ["DENİZ", "ÇÖL"], "answer": "DENİZ"},
    {"q1": "FUTBOLCU - TOP", "q2": "RESSAM", "options": ["FIRÇA", "ÇEKİÇ"], "answer": "FIRÇA"},
    {"q1": "ÖĞRENCİ - DERS", "q2": "SPORCU", "options": ["ANTRENMAN", "KUPA"], "answer": "ANTRENMAN"},
    {"q1": "ANNE - KADIN", "q2": "BABA", "options": ["ERKEK", "ÇOCUK"], "answer": "ERKEK"},
    {"q1": "UZUN - KISA", "q2": "GENİŞ", "options": ["DAR", "BÜYÜK"], "answer": "DAR"},
    {"q1": "MUTLU - SEVİNÇLİ", "q2": "ÜZGÜN", "options": ["KEDERLİ", "ŞAŞKIN"], "answer": "KEDERLİ"},
    {"q1": "BAŞLAMAK - BİTİRMEK", "q2": "GİRMEK", "options": ["ÇIKMAK", "GÖRMEK"], "answer": "ÇIKMAK"},
    {"q1": "SICAK - SOĞUK", "q2": "AYDINLIK", "options": ["KARANLIK", "BEYAZLIK"], "answer": "KARANLIK"},
    {"q1": "TATLI - ŞEKER", "q2": "EKŞİ", "options": ["LİMON", "TUZ"], "answer": "LİMON"},
    {"q1": "SABAH - UYANMAK", "q2": "GECE", "options": ["UYUMAK", "KOŞMAK"], "answer": "UYUMAK"},
    {"q1": "KAR - BEYAZ", "q2": "KÖMÜR", "options": ["SİYAH", "MAVİ"], "answer": "SİYAH"},
    {"q1": "EL - YÜZÜK", "q2": "AYAK", "options": ["HALHAL", "GÖMLEK"], "answer": "HALHAL"},
    {"q1": "KAYDIRAK - KAYMAK", "q2": "SALINCAK", "options": ["SALLANMAK", "ZIPLAMAK"], "answer": "SALLANMAK"},
    {"q1": "DEFTER - YAZMAK", "q2": "KİTAP", "options": ["OKUMAK", "YIRTMAK"], "answer": "OKUMAK"},
    {"q1": "YARASA - KANAT", "q2": "HAMSİ", "options": ["YÜZGEÇ", "AYAK"], "answer": "YÜZGEÇ"},
    {"q1": "OTOBÜS - DURAK", "q2": "UÇAK", "options": ["HAVALİMANI", "GÖKYÜZÜ"], "answer": "HAVALİMANI"},
    {"q1": "CÜMLE - KELİME", "q2": "KELİME", "options": ["HARF", "SAYI"], "answer": "HARF"},
  ];

  late List<Map<String, dynamic>> _gameQuestions;
  int _currentIndex = 0;
  List<String> _currentOptions = [];
  bool _isAnswered = false;
  String? _selectedOption;

  // Skor takibi ve Cevap Listesi
  int _correctCount = 0;
  int _wrongCount = 0;
  List<String?> _userAnswers = [];

  // İnceleme Modu
  bool _isReviewMode = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    // 60 soruyu karıştır ve sadece ilk 10 tanesini al
    _allQuestions.shuffle();
    _gameQuestions = _allQuestions.take(10).toList();
    _userAnswers = List.filled(10, null);
    _currentIndex = 0;
    _correctCount = 0;
    _wrongCount = 0;
    _isReviewMode = false;
    _loadQuestion();
  }

  void _loadQuestion() {
    setState(() {
      _isAnswered = false;
      _selectedOption = null;
      // Şıkların sağda/solda çıkmasını rastgele yap
      _currentOptions = List<String>.from(_gameQuestions[_currentIndex]["options"]);
      _currentOptions.shuffle();
    });
  }

  void _checkAnswer(String selected) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedOption = selected;
      _userAnswers[_currentIndex] = selected; // Çocuğun cevabını kaydet
    });

    String correctAnswer = _gameQuestions[_currentIndex]["answer"];

    if (selected == correctAnswer) {
      _correctCount++;
    } else {
      _wrongCount++;
    }

    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_currentIndex < _gameQuestions.length - 1) {
        setState(() {
          _currentIndex++;
          _loadQuestion();
        });
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    bool isPerfect = _correctCount == 10;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          isPerfect ? "Şampiyon! 🌟" : "Test Bitti! 🎯", 
          textAlign: TextAlign.center, 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPerfect)
              SizedBox(
                height: 150,
                child: Lottie.asset('assets/lottie/tree_star.json', repeat: false),
              ),
            if (isPerfect) const SizedBox(height: 16),
            
            Text("İşte Sonucun:", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 40),
                    const SizedBox(height: 8),
                    Text("$_correctCount Doğru", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.cancel, color: Colors.redAccent, size: 40),
                    const SizedBox(height: 8),
                    Text("$_wrongCount Yanlış", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
              ],
            )
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0F172A), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context); 
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12), 
                    child: Text("Menüye Dön", style: GoogleFonts.poppins(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13))
                  ),
                ),
              ),
              if (_wrongCount > 0) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _isReviewMode = true; // İnceleme modunu aktif et
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12), 
                      child: Text("Hataları Gör", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))
                    ),
                  ),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }

  // Hata İnceleme Ekranı (Liste Görünümü)
  Widget _buildReviewScreen() {
    List<int> wrongIndices = [];
    for (int i = 0; i < _gameQuestions.length; i++) {
      if (_userAnswers[i] != _gameQuestions[i]['answer']) {
        wrongIndices.add(i);
      }
    }

    return Column(
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
                  "Hata İncelemesi",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                ),
              ),
              const SizedBox(width: 48), // Dengelemek için boşluk
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            physics: const BouncingScrollPhysics(),
            itemCount: wrongIndices.length,
            itemBuilder: (context, index) {
              int questionIndex = wrongIndices[index];
              var question = _gameQuestions[questionIndex];
              String userAnswer = _userAnswers[questionIndex] ?? "Boş";
              String correctAnswer = question['answer'];

              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Soru Metni
                    Text(
                      "${question['q1']} İSE",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${question['q2']} NEDİR?",
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(),
                    ),
                    // Senin Cevabın
                    Row(
                      children: [
                        const Icon(Icons.cancel, color: Colors.redAccent, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Senin Cevabın: $userAnswer",
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Doğru Cevap
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Doğru Cevap: $correctAnswer",
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Orijinal Oyun Ekranı
  Widget _buildGameScreen() {
    if (_gameQuestions.isEmpty) return const SizedBox();
    var question = _gameQuestions[_currentIndex];

    // YENİ: Ekranın tamamını SingleChildScrollView ile sarmaladık ve Spacer'ları kaldırdık
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
                    "Benzeşim",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
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
          
          const SizedBox(height: 40), // Nefes alma boşluğu
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                border: Border.all(color: const Color(0xFF0F172A).withOpacity(0.1), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "${question['q1']}  İSE?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black),
                        children: [
                          TextSpan(text: "${question['q2']}  "),
                          const TextSpan(text: "NEDİR?", style: TextStyle(color: Color(0xFFEE2B2B))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 60), // Spacer() yerine güvenli bir boşluk konuldu
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(child: _buildOptionButton(_currentOptions[0], question['answer'])),
                const SizedBox(width: 16),
                Expanded(child: _buildOptionButton(_currentOptions[1], question['answer'])),
              ],
            ),
          ),
          
          const SizedBox(height: 40), // 200 yüksekliğindeki esnemeyen kutu yerine scroll payı
        ],
      ),
    );
  }

  Widget _buildOptionButton(String optionText, String correctAnswer) {
    Color btnColor = Colors.white;
    Color textColor = const Color(0xFF0F172A);

    if (_isAnswered && _selectedOption == optionText) {
      if (optionText == correctAnswer) {
        btnColor = Colors.green; 
        textColor = Colors.white;
      } else {
        btnColor = Colors.redAccent; 
        textColor = Colors.white;
      }
    } else if (_isAnswered && optionText == correctAnswer) {
      btnColor = Colors.green;
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => _checkAnswer(optionText),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 70,
        decoration: BoxDecoration(
          color: btnColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            optionText,
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/sayi_hafizasi_background.jpg', fit: BoxFit.cover),
            ),
            SafeArea(
              child: _isReviewMode ? _buildReviewScreen() : _buildGameScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
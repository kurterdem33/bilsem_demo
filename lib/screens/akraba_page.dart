import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class AkrabaPage extends StatefulWidget {
  const AkrabaPage({super.key});

  @override
  State<AkrabaPage> createState() => _AkrabaPageState();
}

class _AkrabaPageState extends State<AkrabaPage> {
  // 18 Soruluk Dev Havuz
  final List<Map<String, dynamic>> _allQuestionsDatabase = [
    {"q1": "HALA - ENİŞTE", "q2": "DAYI", "options": ["YENGE", "TEYZE"], "answer": "YENGE"},
    {"q1": "BABA - BABAANNE", "q2": "ANNE", "options": ["ANNEANNE", "HALA"], "answer": "ANNEANNE"},
    {"q1": "BABAANNE - DEDE", "q2": "ANNEANNE", "options": ["DEDE", "DAYI"], "answer": "DEDE"},
    {"q1": "ABLA - ENİŞTE", "q2": "ABİ", "options": ["YENGE", "AMCA"], "answer": "YENGE"},
    {"q1": "AMCA - YENGE", "q2": "TEYZE", "options": ["ENİŞTE", "DAYI"], "answer": "ENİŞTE"},
    {"q1": "ANNE - BABA", "q2": "ANNEANNE", "options": ["DEDE", "ENİŞTE"], "answer": "DEDE"},
    {"q1": "DAYI - KUZEN", "q2": "HALA", "options": ["KUZEN", "KARDEŞ"], "answer": "KUZEN"},
    {"q1": "DEDE - BABAANNE", "q2": "DEDE", "options": ["ANNEANNE", "YENGE"], "answer": "ANNEANNE"},
    {"q1": "BABA - HALA", "q2": "ANNE", "options": ["TEYZE", "DAYI"], "answer": "TEYZE"},
    {"q1": "ANNE - DAYI", "q2": "BABA", "options": ["AMCA", "DEDE"], "answer": "AMCA"},
    {"q1": "ANNE - ANNEANNE", "q2": "BABA", "options": ["BABAANNE", "HALA"], "answer": "BABAANNE"},
    {"q1": "DAYI - TEYZE", "q2": "AMCA", "options": ["HALA", "KUZEN"], "answer": "HALA"},
    {"q1": "TEYZE - ANNE", "q2": "HALA", "options": ["BABA", "AMCA"], "answer": "BABA"},
    {"q1": "ANNE - TEYZE", "q2": "BABA", "options": ["HALA", "DAYI"], "answer": "HALA"},
    {"q1": "AMCA - BABA", "q2": "DAYI", "options": ["ANNE", "YENGE"], "answer": "ANNE"},
    {"q1": "BABA - DEDE", "q2": "ANNE", "options": ["DEDE", "TEYZE"], "answer": "DEDE"},
    {"q1": "KIZ KARDEŞ - ABLA", "q2": "ERKEK KARDEŞ", "options": ["ABİ", "AMCA"], "answer": "ABİ"},
    {"q1": "DAYI - YENGE", "q2": "AMCA", "options": ["TORUN", "YENGE"], "answer": "YENGE"},
  ];

  // Aktif olarak çözülecek 10 soru
  List<Map<String, dynamic>> _currentQuestions = [];
  
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
    // Havuzu kopyala, karıştır ve ilk 10 soruyu seç
    List<Map<String, dynamic>> shuffledDatabase = List.from(_allQuestionsDatabase);
    shuffledDatabase.shuffle();
    _currentQuestions = shuffledDatabase.take(10).toList();
    
    _userAnswers = List.filled(10, null);
    _isReviewMode = false;

    _loadQuestion();
  }

  void _loadQuestion() {
    setState(() {
      _isAnswered = false;
      _selectedOption = null;
      // Seçenekleri her soruda rastgele sağa/sola dağıt
      _currentOptions = List<String>.from(_currentQuestions[_currentIndex]["options"]);
      _currentOptions.shuffle();
    });
  }

  void _checkAnswer(String selected) {
    if (_isAnswered) return; // Çift tıklamayı önle

    setState(() {
      _isAnswered = true;
      _selectedOption = selected;
      _userAnswers[_currentIndex] = selected; // Çocuğun cevabını kaydet
    });

    String correctAnswer = _currentQuestions[_currentIndex]["answer"];

    // Doğru/Yanlış sayısını artır
    if (selected == correctAnswer) {
      _correctCount++;
    } else {
      _wrongCount++;
    }

    // Seçilen şıkkın rengini (doğru/yanlış) görmesi için kısa bir süre bekle ve geç
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_currentIndex < _currentQuestions.length - 1) {
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
                    Navigator.pop(context); // Menüye dön
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

  // Hata İnceleme Ekranı (Liste Görünümü - Zaten kaydırılabilir olduğu için korundu)
  Widget _buildReviewScreen() {
    List<int> wrongIndices = [];
    for (int i = 0; i < _currentQuestions.length; i++) {
      if (_userAnswers[i] != _currentQuestions[i]['answer']) {
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
              var question = _currentQuestions[questionIndex];
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

  // Orijinal Oyun Ekranı (Taşmayı önlemek için SingleChildScrollView ile sarmalandı)
  Widget _buildGameScreen() {
    if (_currentQuestions.isEmpty) return const SizedBox();
    var question = _currentQuestions[_currentIndex];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ÜST BAR
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
                    "Akraba İlişkileri",
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
          const SizedBox(height: 40), // Üst bar ile soru kartı arası nefes alma payı

          // SORU KARTI
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
          
          const SizedBox(height: 60), // Spacer yerine konulan güvenli boşluk

          // SEÇENEKLER (İki büyük buton)
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
          
          const SizedBox(height: 40), // En altta kaydırma payı (Eski 200 yüksekliğindeki SizedBox yerine)
        ],
      ),
    );
  }

  Widget _buildOptionButton(String optionText, String correctAnswer) {
    Color btnColor = Colors.white;
    Color textColor = const Color(0xFF0F172A);

    // İşaretlendikten sonraki renk mantığı
    if (_isAnswered && _selectedOption == optionText) {
      if (optionText == correctAnswer) {
        btnColor = Colors.green; // Doğruysa yeşil
        textColor = Colors.white;
      } else {
        btnColor = Colors.redAccent; // Yanlışsa kırmızı
        textColor = Colors.white;
      }
    } else if (_isAnswered && optionText == correctAnswer) {
      // Çocuk yanlış seçeneği işaretlediyse, doğru olanı yeşil olarak vurgula
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
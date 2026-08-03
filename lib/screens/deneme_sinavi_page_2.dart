import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DenemeSinaviPage2 extends StatefulWidget {
  const DenemeSinaviPage2({super.key});

  @override
  State<DenemeSinaviPage2> createState() => _DenemeSinaviPage2State();
}

class _DenemeSinaviPage2State extends State<DenemeSinaviPage2> {
  // 2. DENEME CEVAP ANAHTARI
  // Bu cevap anahtarını 2. denemenizin kendi cevap anahtarına göre güncellemeniz gerekmektedir.
  final List<String> _answerKey = [
    'A', 'D', 'A', 'D', 'C', 'A', 'C', 'B', 'A', 'C', // 1-10
    'B', 'A', 'A', 'B', 'D', 'B', 'A', 'C', 'B', 'D', // 11-20
    'D', 'B', 'A', 'B', 'D', 'D', 'A', 'A', 'C', 'A', // 21-30
    'B', 'A', 'A', 'B', 'C', 'C', 'C', 'B', 'A', 'A', // 31-40
    'B', 'C', 'A', 'B', 'A', 'C', 'B', 'A', 'D'        // 41-49
  ];

  late List<Map<String, dynamic>> _allQuestions;
  late List<Map<String, dynamic>> _shuffledQuestions;
  int _currentIndex = 0;
  int _correctCount = 0;
  int? _tappedIndex;

  final List<Map<String, dynamic>> _incorrectQuestions = [];

  Timer? _timer;
  int _remainingSeconds = 60;

  bool _isReviewMode = false;
  int _reviewIndex = 0;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
    _startExam();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateQuestions() {
    _allQuestions = [];

    List<Rect> universalOptions = [
      const Rect.fromLTWH(20, 1065, 245, 245),
      const Rect.fromLTWH(285, 1065, 245, 245),
      const Rect.fromLTWH(550, 1065, 245, 245),
      const Rect.fromLTWH(815, 1065, 245, 245),
    ];

    for (int i = 0; i < _answerKey.length; i++) {
      int correctIndex;
      switch (_answerKey[i]) {
        case 'A': correctIndex = 0; break;
        case 'B': correctIndex = 1; break;
        case 'C': correctIndex = 2; break;
        case 'D': correctIndex = 3; break;
        default: correctIndex = 0;
      }

      int questionNumber = i + 1;
      _allQuestions.add({
        // Dizin "2_deneme" olarak güncellendi
        "image": "assets/images/denemeler/2_deneme/$questionNumber.jpg", 
        "correctIndex": correctIndex,
        "options": universalOptions,
      });
    }
  }

  void _startExam() {
    _shuffledQuestions = List.from(_allQuestions)..shuffle();
    _currentIndex = 0;
    _correctCount = 0;
    _tappedIndex = null;
    _incorrectQuestions.clear();
    _isReviewMode = false;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            _incorrectQuestions.add({
              "question": _shuffledQuestions[_currentIndex],
              "userSelected": -1 
            });
            _goToNextQuestion();
          }
        });
      }
    });
  }

  void _handleOptionTap(int selectedIndex) {
    if (_isReviewMode || _tappedIndex != null) return; 

    _timer?.cancel();

    setState(() {
      _tappedIndex = selectedIndex; 
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      var currentQuestion = _shuffledQuestions[_currentIndex];
      if (selectedIndex == currentQuestion["correctIndex"]) {
        _correctCount++;
      } else {
        _incorrectQuestions.add({
          "question": currentQuestion,
          "userSelected": selectedIndex,
        });
      }
      _goToNextQuestion();
    });
  }

  void _goToNextQuestion() {
    if (_currentIndex < _shuffledQuestions.length - 1) {
      setState(() {
        _currentIndex++;
        _tappedIndex = null; 
        _startTimer();
      });
    } else {
      _finishExam();
    }
  }

  void _finishExam() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("2. Deneme Bitti! 🏁", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          "Doğru Sayısı: $_correctCount\nYanlış ve Boş Sayısı: ${_shuffledQuestions.length - _correctCount}",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 18),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); 
            },
            child: Text("Bitir", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          if (_incorrectQuestions.isNotEmpty)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEE2B2B)),
              onPressed: () {
                Navigator.pop(context);
                _startReviewMode();
              },
              child: Text("Hataları İncele", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  void _startReviewMode() {
    setState(() {
      _isReviewMode = true;
      _reviewIndex = 0;
    });
  }

  void _nextReviewQuestion() {
    setState(() {
      if (_reviewIndex < _incorrectQuestions.length - 1) {
        _reviewIndex++;
      } else {
        Navigator.pop(context); 
      }
    });
  }

  void _previousReviewQuestion() {
    setState(() {
      if (_reviewIndex > 0) {
        _reviewIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_shuffledQuestions.isEmpty) return const Scaffold();

    var activeQuestion = _isReviewMode ? _incorrectQuestions[_reviewIndex]["question"] : _shuffledQuestions[_currentIndex];
    int userSelected = _isReviewMode ? _incorrectQuestions[_reviewIndex]["userSelected"] : -1;

    double defaultImgWidth = 1080;
    double defaultImgHeight = 1350;

    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double scaleX = constraints.maxWidth / defaultImgWidth;
                  double scaleY = constraints.maxHeight / defaultImgHeight;
                  double scale = scaleX < scaleY ? scaleX : scaleY;

                  double actualWidth = defaultImgWidth * scale;
                  double actualHeight = defaultImgHeight * scale;

                  List<Rect> options = activeQuestion["options"];

                  return SizedBox(
                    width: actualWidth,
                    height: actualHeight,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(activeQuestion["image"], fit: BoxFit.contain),
                        ),
                        
                        ...List.generate(options.length, (index) {
                          Rect rect = options[index];
                          
                          BoxDecoration btnDecoration = const BoxDecoration(color: Colors.transparent); 

                          if (_isReviewMode) {
                            if (index == activeQuestion["correctIndex"]) {
                              btnDecoration = BoxDecoration(
                                border: Border.all(color: Colors.green, width: 6),
                                color: Colors.green.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                              );
                            } else if (index == userSelected) {
                              btnDecoration = BoxDecoration(
                                border: Border.all(color: Colors.red, width: 6),
                                color: Colors.red.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                              );
                            }
                          } else if (_tappedIndex == index) {
                            btnDecoration = BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            );
                          }

                          return Positioned(
                            left: rect.left * scale,
                            top: rect.top * scale,
                            width: rect.width * scale,
                            height: rect.height * scale,
                            child: GestureDetector(
                              onTap: () => _handleOptionTap(index),
                              child: Container(
                                decoration: btnDecoration,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),

            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF1E3A8A).withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  _isReviewMode 
                    ? "Hatalı Soru: ${_reviewIndex + 1} / ${_incorrectQuestions.length}" 
                    : "Soru: ${_currentIndex + 1} / ${_shuffledQuestions.length}",
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),

            if (!_isReviewMode && _remainingSeconds <= 10)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEE2B2B), 
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))]
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$_remainingSeconds",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            if (_isReviewMode)
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_reviewIndex > 0)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: _previousReviewQuestion,
                        child: Text(
                          "<- Önceki",
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      )
                    else
                      const SizedBox(), 

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _nextReviewQuestion,
                      child: Text(
                        _reviewIndex < _incorrectQuestions.length - 1 ? "Sonraki ->" : "İncelemeyi Bitir",
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
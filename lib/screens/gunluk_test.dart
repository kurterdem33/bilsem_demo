import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class GunlukTestPage extends StatefulWidget {
  final bool isReviewMode;

  const GunlukTestPage({
    super.key,
    this.isReviewMode = false,
  });

  @override
  State<GunlukTestPage> createState() => _GunlukTestPageState();
}

class _GunlukTestPageState extends State<GunlukTestPage> with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;

  late PageController _pageController;
  Timer? _autoAdvanceTimer;

  bool _isTimedMode = true; 
  List<String?> _userAnswers = []; 

  AnimationController? _progressController;
  int _secondsLeft = 45;
  Timer? _countdownTimer;

  List<Map<String, String>> _currentQuestions = [];

  bool _isReviewMode = false;
  List<Map<String, String>> _reviewQuestions = [];
  List<String?> _reviewUserAnswers = [];

  List<Map<String, String>> get _activeQuestions => _isReviewMode ? _reviewQuestions : _currentQuestions;

  // 6 Kategorinin Tüm Sorularını İçeren 180 Soruluk Karma Havuz
  final List<Map<String, String>> _allQuestionsDatabase = [
    // --- EKSİK BULMA (30 Soru) ---
    {"image": "assets/images/matris/eksik_bulma/1.jpg", "correct": "B"},
    {"image": "assets/images/matris/eksik_bulma/2.jpg", "correct": "D"},
    {"image": "assets/images/matris/eksik_bulma/3.jpg", "correct": "C"},
    {"image": "assets/images/matris/eksik_bulma/4.jpg", "correct": "D"},
    {"image": "assets/images/matris/eksik_bulma/5.jpg", "correct": "A"},
    {"image": "assets/images/matris/eksik_bulma/6.jpg", "correct": "B"},
    {"image": "assets/images/matris/eksik_bulma/7.jpg", "correct": "C"},
    {"image": "assets/images/matris/eksik_bulma/8.jpg", "correct": "A"},
    {"image": "assets/images/matris/eksik_bulma/9.jpg", "correct": "B"},
    {"image": "assets/images/matris/eksik_bulma/10.jpg", "correct": "C"},
    {"image": "assets/images/matris/eksik_bulma/11.jpg", "correct": "B"},
    {"image": "assets/images/matris/eksik_bulma/12.jpg", "correct": "A"},
    {"image": "assets/images/matris/eksik_bulma/13.jpg", "correct": "D"},
    {"image": "assets/images/matris/eksik_bulma/14.jpg", "correct": "A"},
    {"image": "assets/images/matris/eksik_bulma/15.jpg", "correct": "B"},
    {"image": "assets/images/matris/eksik_bulma/16.jpg", "correct": "A"},
    {"image": "assets/images/matris/eksik_bulma/17.jpg", "correct": "C"},
    {"image": "assets/images/matris/eksik_bulma/18.jpg", "correct": "B"},
    {"image": "assets/images/matris/eksik_bulma/19.jpg", "correct": "C"},
    {"image": "assets/images/matris/eksik_bulma/20.jpg", "correct": "C"},
    {"image": "assets/images/matris/eksik_bulma/21.jpg", "correct": "C"},
    {"image": "assets/images/matris/eksik_bulma/22.jpg", "correct": "B"},
    {"image": "assets/images/matris/eksik_bulma/23.jpg", "correct": "C"},
    {"image": "assets/images/matris/eksik_bulma/24.jpg", "correct": "B"},
    {"image": "assets/images/matris/eksik_bulma/25.jpg", "correct": "A"},
    {"image": "assets/images/matris/eksik_bulma/26.jpg", "correct": "A"},
    {"image": "assets/images/matris/eksik_bulma/27.jpg", "correct": "C"},
    {"image": "assets/images/matris/eksik_bulma/28.jpg", "correct": "B"},
    {"image": "assets/images/matris/eksik_bulma/29.jpg", "correct": "B"},
    {"image": "assets/images/matris/eksik_bulma/30.jpg", "correct": "B"},

    // --- DÖNDÜRME (30 Soru) ---
    {"image": "assets/images/matris/dondurme/1.jpg", "correct": "B"},
    {"image": "assets/images/matris/dondurme/2.jpg", "correct": "B"},
    {"image": "assets/images/matris/dondurme/3.jpg", "correct": "D"},
    {"image": "assets/images/matris/dondurme/4.jpg", "correct": "A"},
    {"image": "assets/images/matris/dondurme/5.jpg", "correct": "C"},
    {"image": "assets/images/matris/dondurme/6.jpg", "correct": "A"},
    {"image": "assets/images/matris/dondurme/7.jpg", "correct": "A"},
    {"image": "assets/images/matris/dondurme/8.jpg", "correct": "C"},
    {"image": "assets/images/matris/dondurme/9.jpg", "correct": "B"},
    {"image": "assets/images/matris/dondurme/10.jpg", "correct": "D"},
    {"image": "assets/images/matris/dondurme/11.jpg", "correct": "A"},
    {"image": "assets/images/matris/dondurme/12.jpg", "correct": "B"},
    {"image": "assets/images/matris/dondurme/13.jpg", "correct": "C"},
    {"image": "assets/images/matris/dondurme/14.jpg", "correct": "B"},
    {"image": "assets/images/matris/dondurme/15.jpg", "correct": "B"},
    {"image": "assets/images/matris/dondurme/16.jpg", "correct": "D"},
    {"image": "assets/images/matris/dondurme/17.jpg", "correct": "C"},
    {"image": "assets/images/matris/dondurme/18.jpg", "correct": "C"},
    {"image": "assets/images/matris/dondurme/19.jpg", "correct": "A"},
    {"image": "assets/images/matris/dondurme/20.jpg", "correct": "B"},
    {"image": "assets/images/matris/dondurme/21.jpg", "correct": "C"},
    {"image": "assets/images/matris/dondurme/22.jpg", "correct": "B"},
    {"image": "assets/images/matris/dondurme/23.jpg", "correct": "B"},
    {"image": "assets/images/matris/dondurme/24.jpg", "correct": "D"},
    {"image": "assets/images/matris/dondurme/25.jpg", "correct": "A"},
    {"image": "assets/images/matris/dondurme/26.jpg", "correct": "A"},
    {"image": "assets/images/matris/dondurme/27.jpg", "correct": "D"},
    {"image": "assets/images/matris/dondurme/28.jpg", "correct": "C"},
    {"image": "assets/images/matris/dondurme/29.jpg", "correct": "A"},
    {"image": "assets/images/matris/dondurme/30.jpg", "correct": "B"},

    // --- ORTAK NOKTA (30 Soru) ---
    {"image": "assets/images/matris/ortak_nokta/1.jpg", "correct": "B"},
    {"image": "assets/images/matris/ortak_nokta/2.jpg", "correct": "A"},
    {"image": "assets/images/matris/ortak_nokta/3.jpg", "correct": "B"},
    {"image": "assets/images/matris/ortak_nokta/4.jpg", "correct": "D"},
    {"image": "assets/images/matris/ortak_nokta/5.jpg", "correct": "C"},
    {"image": "assets/images/matris/ortak_nokta/6.jpg", "correct": "A"},
    {"image": "assets/images/matris/ortak_nokta/7.jpg", "correct": "D"},
    {"image": "assets/images/matris/ortak_nokta/8.jpg", "correct": "B"},
    {"image": "assets/images/matris/ortak_nokta/9.jpg", "correct": "D"},
    {"image": "assets/images/matris/ortak_nokta/10.jpg", "correct": "B"},
    {"image": "assets/images/matris/ortak_nokta/11.jpg", "correct": "C"},
    {"image": "assets/images/matris/ortak_nokta/12.jpg", "correct": "A"},
    {"image": "assets/images/matris/ortak_nokta/13.jpg", "correct": "A"},
    {"image": "assets/images/matris/ortak_nokta/14.jpg", "correct": "B"},
    {"image": "assets/images/matris/ortak_nokta/15.jpg", "correct": "A"},
    {"image": "assets/images/matris/ortak_nokta/16.jpg", "correct": "D"},
    {"image": "assets/images/matris/ortak_nokta/17.jpg", "correct": "B"},
    {"image": "assets/images/matris/ortak_nokta/18.jpg", "correct": "C"},
    {"image": "assets/images/matris/ortak_nokta/19.jpg", "correct": "C"},
    {"image": "assets/images/matris/ortak_nokta/20.jpg", "correct": "B"},
    {"image": "assets/images/matris/ortak_nokta/21.jpg", "correct": "A"},
    {"image": "assets/images/matris/ortak_nokta/22.jpg", "correct": "D"},
    {"image": "assets/images/matris/ortak_nokta/23.jpg", "correct": "A"},
    {"image": "assets/images/matris/ortak_nokta/24.jpg", "correct": "D"},
    {"image": "assets/images/matris/ortak_nokta/25.jpg", "correct": "A"},
    {"image": "assets/images/matris/ortak_nokta/26.jpg", "correct": "B"},
    {"image": "assets/images/matris/ortak_nokta/27.jpg", "correct": "C"},
    {"image": "assets/images/matris/ortak_nokta/28.jpg", "correct": "A"},
    {"image": "assets/images/matris/ortak_nokta/29.jpg", "correct": "B"},
    {"image": "assets/images/matris/ortak_nokta/30.jpg", "correct": "D"},

    // --- BİRLEŞME (30 Soru) ---
    {"image": "assets/images/matris/birlesme/1.jpg", "correct": "C"},
    {"image": "assets/images/matris/birlesme/2.jpg", "correct": "C"},
    {"image": "assets/images/matris/birlesme/3.jpg", "correct": "A"},
    {"image": "assets/images/matris/birlesme/4.jpg", "correct": "A"},
    {"image": "assets/images/matris/birlesme/5.jpg", "correct": "B"},
    {"image": "assets/images/matris/birlesme/6.jpg", "correct": "B"},
    {"image": "assets/images/matris/birlesme/7.jpg", "correct": "D"},
    {"image": "assets/images/matris/birlesme/8.jpg", "correct": "C"},
    {"image": "assets/images/matris/birlesme/9.jpg", "correct": "D"},
    {"image": "assets/images/matris/birlesme/10.jpg", "correct": "C"},
    {"image": "assets/images/matris/birlesme/11.jpg", "correct": "A"},
    {"image": "assets/images/matris/birlesme/12.jpg", "correct": "B"},
    {"image": "assets/images/matris/birlesme/13.jpg", "correct": "C"},
    {"image": "assets/images/matris/birlesme/14.jpg", "correct": "A"},
    {"image": "assets/images/matris/birlesme/15.jpg", "correct": "D"},
    {"image": "assets/images/matris/birlesme/16.jpg", "correct": "D"},
    {"image": "assets/images/matris/birlesme/17.jpg", "correct": "C"},
    {"image": "assets/images/matris/birlesme/18.jpg", "correct": "A"},
    {"image": "assets/images/matris/birlesme/19.jpg", "correct": "B"},
    {"image": "assets/images/matris/birlesme/20.jpg", "correct": "A"},
    {"image": "assets/images/matris/birlesme/21.jpg", "correct": "B"},
    {"image": "assets/images/matris/birlesme/22.jpg", "correct": "A"},
    {"image": "assets/images/matris/birlesme/23.jpg", "correct": "C"},
    {"image": "assets/images/matris/birlesme/24.jpg", "correct": "C"},
    {"image": "assets/images/matris/birlesme/25.jpg", "correct": "D"},
    {"image": "assets/images/matris/birlesme/26.jpg", "correct": "B"},
    {"image": "assets/images/matris/birlesme/27.jpg", "correct": "A"},
    {"image": "assets/images/matris/birlesme/28.jpg", "correct": "B"},
    {"image": "assets/images/matris/birlesme/29.jpg", "correct": "A"},
    {"image": "assets/images/matris/birlesme/30.jpg", "correct": "A"},

    // --- ARTMA-AZALMA (30 Soru) ---
    {"image": "assets/images/matris/artma_azalma/1.jpg", "correct": "D"},
    {"image": "assets/images/matris/artma_azalma/2.jpg", "correct": "A"},
    {"image": "assets/images/matris/artma_azalma/3.jpg", "correct": "B"},
    {"image": "assets/images/matris/artma_azalma/4.jpg", "correct": "C"},
    {"image": "assets/images/matris/artma_azalma/5.jpg", "correct": "C"},
    {"image": "assets/images/matris/artma_azalma/6.jpg", "correct": "B"},
    {"image": "assets/images/matris/artma_azalma/7.jpg", "correct": "A"},
    {"image": "assets/images/matris/artma_azalma/8.jpg", "correct": "D"},
    {"image": "assets/images/matris/artma_azalma/9.jpg", "correct": "B"},
    {"image": "assets/images/matris/artma_azalma/10.jpg", "correct": "B"},
    {"image": "assets/images/matris/artma_azalma/11.jpg", "correct": "A"},
    {"image": "assets/images/matris/artma_azalma/12.jpg", "correct": "A"},
    {"image": "assets/images/matris/artma_azalma/13.jpg", "correct": "C"},
    {"image": "assets/images/matris/artma_azalma/14.jpg", "correct": "C"},
    {"image": "assets/images/matris/artma_azalma/15.jpg", "correct": "B"},
    {"image": "assets/images/matris/artma_azalma/16.jpg", "correct": "A"},
    {"image": "assets/images/matris/artma_azalma/17.jpg", "correct": "A"},
    {"image": "assets/images/matris/artma_azalma/18.jpg", "correct": "D"},
    {"image": "assets/images/matris/artma_azalma/19.jpg", "correct": "B"},
    {"image": "assets/images/matris/artma_azalma/20.jpg", "correct": "D"},
    {"image": "assets/images/matris/artma_azalma/21.jpg", "correct": "B"},
    {"image": "assets/images/matris/artma_azalma/22.jpg", "correct": "C"},
    {"image": "assets/images/matris/artma_azalma/23.jpg", "correct": "B"},
    {"image": "assets/images/matris/artma_azalma/24.jpg", "correct": "B"},
    {"image": "assets/images/matris/artma_azalma/25.jpg", "correct": "B"},
    {"image": "assets/images/matris/artma_azalma/26.jpg", "correct": "C"},
    {"image": "assets/images/matris/artma_azalma/27.jpg", "correct": "C"},
    {"image": "assets/images/matris/artma_azalma/28.jpg", "correct": "A"},
    {"image": "assets/images/matris/artma_azalma/29.jpg", "correct": "A"},
    {"image": "assets/images/matris/artma_azalma/30.jpg", "correct": "D"},

    // --- KAYDIRMA (30 Soru) ---
    {"image": "assets/images/matris/kaydirma/1.jpg", "correct": "B"},
    {"image": "assets/images/matris/kaydirma/2.jpg", "correct": "D"},
    {"image": "assets/images/matris/kaydirma/3.jpg", "correct": "A"},
    {"image": "assets/images/matris/kaydirma/4.jpg", "correct": "B"},
    {"image": "assets/images/matris/kaydirma/5.jpg", "correct": "A"},
    {"image": "assets/images/matris/kaydirma/6.jpg", "correct": "C"},
    {"image": "assets/images/matris/kaydirma/7.jpg", "correct": "B"},
    {"image": "assets/images/matris/kaydirma/8.jpg", "correct": "B"},
    {"image": "assets/images/matris/kaydirma/9.jpg", "correct": "C"},
    {"image": "assets/images/matris/kaydirma/10.jpg", "correct": "B"},
    {"image": "assets/images/matris/kaydirma/11.jpg", "correct": "B"},
    {"image": "assets/images/matris/kaydirma/12.jpg", "correct": "C"},
    {"image": "assets/images/matris/kaydirma/13.jpg", "correct": "C"},
    {"image": "assets/images/matris/kaydirma/14.jpg", "correct": "D"},
    {"image": "assets/images/matris/kaydirma/15.jpg", "correct": "B"},
    {"image": "assets/images/matris/kaydirma/16.jpg", "correct": "A"},
    {"image": "assets/images/matris/kaydirma/17.jpg", "correct": "D"},
    {"image": "assets/images/matris/kaydirma/18.jpg", "correct": "D"},
    {"image": "assets/images/matris/kaydirma/19.jpg", "correct": "D"},
    {"image": "assets/images/matris/kaydirma/20.jpg", "correct": "A"},
    {"image": "assets/images/matris/kaydirma/21.jpg", "correct": "D"},
    {"image": "assets/images/matris/kaydirma/22.jpg", "correct": "C"},
    {"image": "assets/images/matris/kaydirma/23.jpg", "correct": "B"},
    {"image": "assets/images/matris/kaydirma/24.jpg", "correct": "A"},
    {"image": "assets/images/matris/kaydirma/25.jpg", "correct": "C"},
    {"image": "assets/images/matris/kaydirma/26.jpg", "correct": "A"},
    {"image": "assets/images/matris/kaydirma/27.jpg", "correct": "A"},
    {"image": "assets/images/matris/kaydirma/28.jpg", "correct": "B"},
    {"image": "assets/images/matris/kaydirma/29.jpg", "correct": "C"},
    {"image": "assets/images/matris/kaydirma/30.jpg", "correct": "D"},
  ];

  @override
  void initState() {
    super.initState();
    
    _isReviewMode = widget.isReviewMode;
    _pageController = PageController(initialPage: 0);

    // 180 soruluk dev listeyi al, karıştır, içinden sadece 10 tanesini çek
    List<Map<String, String>> shuffledQuestions = List.from(_allQuestionsDatabase);
    shuffledQuestions.shuffle();
    _currentQuestions = shuffledQuestions.take(10).toList();
    
    _userAnswers = List.filled(_currentQuestions.length, null);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..addListener(() {
        setState(() {});
      });

    if (!_isReviewMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInstructionDialog();
      });
    }
  }

  void _showInstructionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "Günlük Test 🚀", 
          textAlign: TextAlign.center, 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
        ),
        content: Text(
          "Karşına her kategoriden karışık sorular çıkacak. Kurallara dikkat ederek doğru cevabı bulmalısın! Hazır mısın?", 
          textAlign: TextAlign.center, 
          style: GoogleFonts.poppins(fontSize: 18)
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () { 
                    Navigator.pop(context);
                    setState(() { _isTimedMode = false; }); 
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12), 
                    child: Text("Süresiz\nBaşla", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () { 
                    Navigator.pop(context);
                    setState(() { _isTimedMode = true; }); 
                    _startTimer();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12), 
                    child: Text("Süreli\nBaşla", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _startTimer() {
    if (!_isTimedMode) return;

    _progressController?.reset();
    _progressController?.forward();
    _countdownTimer?.cancel();
    _secondsLeft = 45;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
        } else {
          _countdownTimer?.cancel();
          _checkAnswer("ZAMAN_DOLDU", _currentQuestionIndex);
        }
      });
    });
  }

  void _checkAnswer(String chosenOption, int pageIndex) {
    if (_isReviewMode) return;

    if (_isTimedMode) {
      if (_userAnswers[pageIndex] != null) return; 

      _countdownTimer?.cancel();
      _progressController?.stop();

      setState(() {
        _userAnswers[pageIndex] = chosenOption; 
      });

      Timer(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        if (pageIndex < _currentQuestions.length - 1) {
          _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut).then((_) {
            if (mounted) _startTimer();
          });
        } else {
          _showResultDialog();
        }
      });
    } else {
      // SÜRESİZ MOD: Değişikliğe ve özgür seçime izin veriyoruz
      setState(() {
        _userAnswers[pageIndex] = chosenOption;
      });
      
      _autoAdvanceTimer?.cancel(); 
      _autoAdvanceTimer = Timer(const Duration(milliseconds: 1000), () {
        if (mounted && pageIndex < _activeQuestions.length - 1) {
          _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
        }
      });
    }
  }

  void _startReviewMode() {
    _reviewQuestions.clear();
    _reviewUserAnswers.clear();
    for (int i = 0; i < _currentQuestions.length; i++) {
      if (_userAnswers[i] != _currentQuestions[i]["correct"]) {
        _reviewQuestions.add(_currentQuestions[i]);
        _reviewUserAnswers.add(_userAnswers[i]);
      }
    }
    setState(() {
      _isReviewMode = true;
      _isTimedMode = false; 
      _currentQuestionIndex = 0;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) _pageController.jumpToPage(0);
    });
  }

  void _showResultDialog() {
    int correct = 0;
    int wrong = 0;
    int empty = 0;

    for (int i = 0; i < _currentQuestions.length; i++) {
      if (_userAnswers[i] == null || _userAnswers[i] == "ZAMAN_DOLDU") {
        empty++;
      } else if (_userAnswers[i] == _currentQuestions[i]["correct"]) {
        correct++;
      } else {
        wrong++;
      }
    }

    bool isPerfect = correct == _currentQuestions.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          isPerfect ? "Harika! 🌟" : "Test Bitti! 🎯", 
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
            if (isPerfect) const SizedBox(height: 12),
            Text(
              "Doğru: $correct\nYanlış: $wrong\nBoş: $empty", 
              textAlign: TextAlign.center, 
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))
            ),
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
                    child: Text("Menüye Dön", style: GoogleFonts.poppins(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ),
              if (wrong + empty > 0) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); 
                      _startReviewMode(); 
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text("Hataları Gör", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
  
  void _goToPrevious() {
    _autoAdvanceTimer?.cancel();
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _goToNext() {
    _autoAdvanceTimer?.cancel();
    if (_currentQuestionIndex < _activeQuestions.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _progressController?.dispose();
    _countdownTimer?.cancel();
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
                  Expanded(
                    child: Text(
                      _isReviewMode ? "Hata İncelemesi" : "Günlük Test", 
                      textAlign: TextAlign.center, 
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)
                    )
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
                    decoration: BoxDecoration(color: const Color(0xFFEE2B2B), borderRadius: BorderRadius.circular(20)), 
                    child: Text(
                      "${_currentQuestionIndex + 1} / ${_activeQuestions.length}", 
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
                    )
                  ),
                ],
              ),
            ),
            
            if (_isTimedMode)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 24, 
                        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2.5), borderRadius: BorderRadius.circular(20)), 
                        padding: const EdgeInsets.all(2), 
                        child: FractionallySizedBox(widthFactor: 1.0 - (_progressController?.value ?? 0.0), child: Container(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20))))
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(width: 45, child: Text('$_secondsLeft"', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700))),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _currentQuestionIndex > 0 ? _goToPrevious : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        disabledBackgroundColor: Colors.grey.shade100,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back_ios_rounded, size: 16, color: _currentQuestionIndex > 0 ? const Color(0xFF0F172A) : Colors.grey.shade400),
                            const SizedBox(width: 6),
                            Text("Geri", style: GoogleFonts.poppins(color: _currentQuestionIndex > 0 ? const Color(0xFF0F172A) : Colors.grey.shade400, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    
                    if (_currentQuestionIndex == _activeQuestions.length - 1)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isReviewMode ? const Color(0xFF0F172A) : const Color(0xFFEE2B2B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _isReviewMode ? () => Navigator.pop(context) : _showResultDialog,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          child: Text(_isReviewMode ? "Menüye Dön" : "Bitir", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: _goToNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Text("İleri", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentQuestionIndex = index;
                  });
                },
                itemCount: _activeQuestions.length,
                itemBuilder: (context, pageIndex) {
                  
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double defaultImgWidth = 1080;
                          double defaultImgHeight = 1350;

                          double scaleX = constraints.maxWidth / defaultImgWidth;
                          double scaleY = constraints.maxHeight / defaultImgHeight;
                          double scale = scaleX < scaleY ? scaleX : scaleY;

                          double actualWidth = defaultImgWidth * scale;
                          double actualHeight = defaultImgHeight * scale;

                          // --- DAHA KÜÇÜK VE MERKEZLENMİŞ DAİRE KOORDİNATLARI ---
                          double butonY = 1100;
                          double butonBoyutu = 200; 

                          List<Rect> universalOptions = [
                            Rect.fromLTWH(42, butonY, butonBoyutu, butonBoyutu),
                            Rect.fromLTWH(307, butonY, butonBoyutu, butonBoyutu),
                            Rect.fromLTWH(572, butonY, butonBoyutu, butonBoyutu),
                            Rect.fromLTWH(837, butonY, butonBoyutu, butonBoyutu),
                          ];

                          String correctOption = _activeQuestions[pageIndex]["correct"]!;
                          
                          String? pageUserAnswer = _isReviewMode 
                              ? _reviewUserAnswers[pageIndex] 
                              : _userAnswers[pageIndex];

                          return SizedBox(
                            width: actualWidth,
                            height: actualHeight,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Image.asset(
                                      _activeQuestions[pageIndex]["image"]!,
                                      fit: BoxFit.contain, 
                                    ),
                                  ),
                                ),
                                
                                ...List.generate(universalOptions.length, (index) {
                                  Rect rect = universalOptions[index];
                                  String optionLetter = ["A", "B", "C", "D"][index];
                                  Color overlayColor = Colors.transparent;

                                  // YÜKSEK BELİRGİNLİK (0.6 OPACITY)
                                  if (_isReviewMode) {
                                    if (optionLetter == correctOption) {
                                      overlayColor = Colors.green.withOpacity(0.6); 
                                    } else if (optionLetter == pageUserAnswer) {
                                      overlayColor = Colors.red.withOpacity(0.6); 
                                    }
                                  } else if (_isTimedMode) {
                                    if (pageUserAnswer != null) {
                                      if (optionLetter == correctOption) {
                                        overlayColor = Colors.green.withOpacity(0.6); 
                                      } else if (optionLetter == pageUserAnswer && pageUserAnswer != "ZAMAN_DOLDU") {
                                        overlayColor = Colors.red.withOpacity(0.6); 
                                      }
                                    }
                                  } else {
                                    if (optionLetter == pageUserAnswer) {
                                      overlayColor = Colors.black.withOpacity(0.4);
                                    }
                                  }

                                  return Positioned(
                                    left: rect.left * scale,
                                    top: rect.top * scale,
                                    width: rect.width * scale,
                                    height: rect.height * scale,
                                    child: GestureDetector(
                                      onTap: _isReviewMode ? null : () => _checkAnswer(optionLetter, pageIndex),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        decoration: BoxDecoration(
                                          color: overlayColor,
                                          shape: BoxShape.circle, // KUSURSUZ KÜÇÜK DAİRE
                                        ),
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
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
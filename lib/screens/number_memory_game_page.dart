import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bilsem_button.dart';

class NumberMemoryGamePage extends StatefulWidget {
  final int digitCount; 

  const NumberMemoryGamePage({super.key, required this.digitCount});

  @override
  State<NumberMemoryGamePage> createState() => _NumberMemoryGamePageState();
}

class _NumberMemoryGamePageState extends State<NumberMemoryGamePage> with TickerProviderStateMixin {
  int _currentQuestion = 1;
  int _score = 0;
  String _generatedNumbers = "";
  
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  String _gamePhase = 'memorize'; 
  
  // Animasyon için eklenen yeni değişken
  int _revealedIndex = -1;

  AnimationController? _progressController;
  int _secondsLeft = 10;
  Timer? _secondsTimer;

  @override
  void initState() {
    super.initState();
    _initializeQuestionData();
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        setState(() {});
      });

    _startCountdown();
  }

  void _initializeQuestionData() {
    final random = Random();
    List<String> digits = [];
    for (int i = 0; i < widget.digitCount; i++) {
      digits.add(random.nextInt(10).toString());
    }
    _generatedNumbers = digits.join("-"); 
    _gamePhase = 'memorize';
    _secondsLeft = 10;
    _revealedIndex = -1; // Yeni soruya geçerken animasyonu sıfırla
    _inputController.clear();
  }

  void _startCountdown() {
    _progressController?.reset();
    _progressController?.forward();

    _secondsTimer?.cancel();
    _secondsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
        } else {
          _secondsTimer?.cancel();
          _switchToInputPhase();
        }
      });
    });
  }

  void _generateNewQuestion() {
    setState(() {
      _initializeQuestionData();
    });
    _startCountdown();
  }

  void _switchToInputPhase() {
    setState(() {
      _gamePhase = 'input';
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inputFocusNode.requestFocus();
      }
    });
  }

  void _checkAnswer(String value) {
    // 1. Klavyeyi ekrandan tamamen kaldır
    FocusScope.of(context).unfocus();

    String cleanGenerated = _generatedNumbers.replaceAll("-", "");
    
    if (value == cleanGenerated) {
      _score++;
    }

    // 2. Koca ikonlu feedback ekranı yerine animasyonu başlat
    _startRevealAnimation();
  }

  // Soldan sağa adım adım cevabı gösteren animasyon döngüsü
  void _startRevealAnimation() async {
    for (int i = 0; i < widget.digitCount; i++) {
      await Future.delayed(const Duration(milliseconds: 400)); 
      if (!mounted) return;
      setState(() {
        _revealedIndex = i;
      });
    }

    // Çocuğun hatalarını/doğrularını incelemesi için 2.5 saniye bekle
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    if (_currentQuestion < 10) {
      setState(() {
        _currentQuestion++;
      });
      _generateNewQuestion();
    } else {
      setState(() {
        _gamePhase = 'summary';
      });
    }
  }

  @override
  void dispose() {
    _progressController?.dispose();
    _secondsTimer?.cancel();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Arka plan resminin klavye açılınca ezilmesini engeller
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/sayi_hafizasi_background_2.jpg',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              // KLAVYE ÇÖZÜMÜ: Klavye açılınca içeriği yukarı iter
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 26),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildGameContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    const Color targetRed = Color(0xFFEE2B2B);
    const Color darkText = Color(0xFF0F172A);
    final screenHeight = MediaQuery.of(context).size.height;

    if (_gamePhase == 'memorize') {
      return Column(
        children: [
          Text(
            "10/$_currentQuestion",
            style: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.w800, color: darkText),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(color: darkText, width: 2.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(2),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 1.0 - (_progressController?.value ?? 0.0),
                      child: Container(
                        decoration: BoxDecoration(color: darkText, borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                SizedBox(
                  width: 40,
                  child: Text(
                    '$_secondsLeft"',
                    textAlign: TextAlign.left, 
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: darkText),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0), 
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _generatedNumbers,
                maxLines: 1, 
                style: GoogleFonts.poppins(fontSize: 68, fontWeight: FontWeight.w900, color: darkText, letterSpacing: 2),
              ),
            ),
          ),
          
          const Spacer(flex: 4),
        ],
      );
    } else if (_gamePhase == 'input') {
      return Stack(
        children: [
          // Arka planda çalışan gizli TextField
          Positioned(
            left: -200,
            top: -200,
            child: SizedBox(
              width: 10,
              height: 10,
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocusNode,
                keyboardType: TextInputType.number,
                maxLength: widget.digitCount,
                readOnly: _revealedIndex != -1, // Animasyon esnasında klavye açılmasını engeller
                onChanged: (val) {
                  if (_revealedIndex != -1) return; // Animasyon esnasında veri girişini yoksay
                  setState(() {});
                  if (val.length == widget.digitCount) {
                    _checkAnswer(val);
                  }
                },
              ),
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.05),
                Text(
                  "Aklında kalan sayıları gir.",
                  style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700, color: darkText),
                ),
                SizedBox(height: screenHeight * 0.1),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: GestureDetector(
                      onTap: () {
                        if (_revealedIndex != -1) return; // Animasyondayken tıklamaları yoksay
                        
                        // ZORLA AÇMA ÇÖZÜMÜ: Klavye inat ederse odağı düşürüp geri çağırır
                        if (_inputFocusNode.hasFocus) {
                          _inputFocusNode.unfocus();
                          Future.delayed(const Duration(milliseconds: 50), () {
                            if (mounted) _inputFocusNode.requestFocus();
                          });
                        } else {
                          _inputFocusNode.requestFocus();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(widget.digitCount, (index) {
                          String char = "";
                          if (_inputController.text.length > index) {
                            char = _inputController.text[index];
                          }
                          
                          // Doğrulama ve Animasyon Değişkenleri
                          bool isRevealed = _revealedIndex >= index;
                          String correctChar = _generatedNumbers.replaceAll("-", "")[index];
                          bool isMatch = char == correctChar;

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Üstte beliren animasyonlu geri bildirim (Yükseklik sabitlendi ki zıplama olmasın)
                                SizedBox(
                                  height: 90,
                                  child: isRevealed 
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            isMatch ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                            color: isMatch ? Colors.green : targetRed,
                                            size: 28,
                                          ),
                                          Text(
                                            correctChar,
                                            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: isMatch ? Colors.green : targetRed),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                ),
                                const SizedBox(height: 8),
                                // Çocuğun sayı girdiği kırmızı kutu
                                Container(
                                  width: 65,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    color: targetRed,
                                    border: Border.all(color: Colors.black, width: 2.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.center,
                                  // İMLEÇ EFEKTİ: Sıradaki boş kutuda hafifçe | işareti görünür
                                  child: char.isEmpty && _inputController.text.length == index && _revealedIndex == -1
                                      ? Text("|", style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w300, color: Colors.white54))
                                      : Text(
                                          char,
                                          style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
                                        ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.1),
              ],
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Test Tamamlandı!",
                style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w900, color: darkText),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: darkText, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      "🎯 Skorun",
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "10 / $_score",
                      style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w900, color: targetRed),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              BilsemButton(
                label: "Tekrar Oyna",
                backgroundColor: targetRed,
                onPressed: () {
                  setState(() {
                    _currentQuestion = 1;
                    _score = 0;
                  });
                  _generateNewQuestion();
                },
              ),
              BilsemButton(
                label: "Ana Sayfa",
                backgroundColor: darkText,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}
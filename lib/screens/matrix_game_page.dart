import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 

class MatrixGamePage extends StatefulWidget {
  final String categoryName;
  final bool isReviewMode; 

  const MatrixGamePage({
    super.key, 
    required this.categoryName,
    this.isReviewMode = false, 
  });

  @override
  State<MatrixGamePage> createState() => _MatrixGamePageState();
}

class _MatrixGamePageState extends State<MatrixGamePage> with TickerProviderStateMixin {
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

  VideoPlayerController? _videoController;
  bool _hideVideoTutorial = false;

  final Map<String, String> _categoryInstructions = {
    "Eksik Bulma": "Satır veya sütundaki şekillere iyi bak! Eksik olan parçayı bulup tamamlaman gerekiyor.",
    "Döndürme": "Şekiller saat yönünde veya tersine dönüyor. Bakalım bir sonraki adımda şekil nasıl görünecek?",
    "Ortak Nokta": "İlk iki kutudaki şekillerin ortak özelliklerini bul ve üçüncü kutuya uygun olanı seç!",
    "Birleşme": "Satırlardaki şekilleri birleştiriyoruz. Hangi parçanın önde, hangisinin arkada olduğuna dikkat etmelisin.",
    "Artma-Azalma": "Şekillerin sayısı kurala göre artıyor veya azalıyor. Sayıları takip et, kuralı hemen yakala!",
    "Kaydırma": "Şekiller belli bir yöne doğru hareket ederek yer değiştiriyor. Hareket kuralını bul ve doğru cevabı seç.",
  };

  // 30 SORULUK YENİ VERİTABANI EKLENDİ
  final Map<String, List<Map<String, String>>> _allQuestionsDatabase = {
    "Eksik Bulma": [
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
      {"image": "assets/images/matris/eksik_bulma/22.jpg", "correct": "D"},
      {"image": "assets/images/matris/eksik_bulma/23.jpg", "correct": "C"},
      {"image": "assets/images/matris/eksik_bulma/24.jpg", "correct": "B"},
      {"image": "assets/images/matris/eksik_bulma/25.jpg", "correct": "A"},
      {"image": "assets/images/matris/eksik_bulma/26.jpg", "correct": "A"},
      {"image": "assets/images/matris/eksik_bulma/27.jpg", "correct": "C"},
      {"image": "assets/images/matris/eksik_bulma/28.jpg", "correct": "B"},
      {"image": "assets/images/matris/eksik_bulma/29.jpg", "correct": "B"},
      {"image": "assets/images/matris/eksik_bulma/30.jpg", "correct": "B"},
    ],
    "Döndürme": [
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
    ],
    "Ortak Nokta": [
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
    ],
    "Birleşme": [
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
    ],
    "Artma-Azalma": [
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
    ],
    "Kaydırma": [
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
    ],
  };

  String _getVideoPath(String category) {
    switch (category) {
      case "Eksik Bulma": return "assets/konular/eksik_bulma.mp4";
      case "Döndürme": return "assets/konular/dondurme.mp4";
      case "Ortak Nokta": return "assets/konular/ortak_nokta.mp4";
      case "Birleşme": return "assets/konular/birlesme.mp4";
      case "Artma-Azalma": return "assets/konular/artma_azalma.mp4";
      case "Kaydırma": return "assets/konular/kaydirma.mp4";
      default: return "assets/konular/eksik_bulma.mp4";
    }
  }

  @override
  void initState() {
    super.initState();
    
    _pageController = PageController(initialPage: 0);
    
    // YENİ SEÇİM SİSTEMİ: 30 soruluk listeyi al, karıştır, içinden sadece 10 tanesini çek
    List<Map<String, String>> selectedCategory = 
        List.from(_allQuestionsDatabase[widget.categoryName] ?? _allQuestionsDatabase["Eksik Bulma"]!);
    
    selectedCategory.shuffle();
    _currentQuestions = selectedCategory.take(10).toList(); // DEĞİŞİKLİK BURADA YAPILDI
    
    _userAnswers = List.filled(_currentQuestions.length, null);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..addListener(() {
        setState(() {});
      });

    if (!widget.isReviewMode) {
      _checkTutorialPreferences();
    }
  }

  Future<void> _checkTutorialPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _hideVideoTutorial = prefs.getBool('hide_video_${widget.categoryName}') ?? false;
    
    if (!_hideVideoTutorial) {
      _videoController = VideoPlayerController.asset(_getVideoPath(widget.categoryName));
      await _videoController!.initialize(); 
      _videoController!.setLooping(false); 
      _videoController!.play(); 
    }

    if (mounted) {
      setState(() {}); 
      _showInstructionDialog(); 
    }
  }

  void _showInstructionDialog() {
    String instructionText = _categoryInstructions[widget.categoryName] ?? "Kurallara dikkat ederek doğru cevabı bulmalısın!";
    bool tempHide = _hideVideoTutorial; 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              "Nasıl Oynanır?", 
              textAlign: TextAlign.center, 
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_hideVideoTutorial) ...[
                    if (_videoController != null && _videoController!.value.isInitialized)
                      AspectRatio(
                        aspectRatio: 1.0, 
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(_videoController!),
                              ValueListenableBuilder(
                                valueListenable: _videoController!,
                                builder: (context, VideoPlayerValue value, child) {
                                  bool isEnded = value.position >= value.duration && value.duration != Duration.zero;
                                  
                                  if (isEnded || !value.isPlaying) {
                                    return GestureDetector(
                                      onTap: () {
                                        if (isEnded) {
                                          _videoController!.seekTo(Duration.zero); 
                                        }
                                        _videoController!.play(); 
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5), 
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: const Icon(
                                          Icons.play_arrow_rounded,
                                          size: 64,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink(); 
                                },
                              ),
                            ],
                          ),
                        )
                      )
                    else
                      const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          activeColor: const Color(0xFF0F172A),
                          value: tempHide,
                          onChanged: (bool? value) async {
                            setDialogState(() {
                              tempHide = value ?? false;
                            });
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('hide_video_${widget.categoryName}', tempHide);
                          },
                        ),
                        Expanded(
                          child: Text(
                            "Bir daha gösterme",
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        )
                      ],
                    )
                  ] 
                  else ...[
                    Text(
                      instructionText, 
                      textAlign: TextAlign.center, 
                      style: GoogleFonts.poppins(fontSize: 18)
                    ),
                  ]
                ],
              ),
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
                        _videoController?.pause(); 
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
                        _videoController?.pause(); 
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
          );
        }
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
    _videoController?.dispose(); 
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
                      _isReviewMode ? "Hata İncelemesi" : widget.categoryName, 
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

                          // BUTON KOORDİNATLARI EN SON YAPTIĞIMIZ AYARLA KALDI
                          List<Rect> universalOptions = [
                            const Rect.fromLTWH(20, 1085, 245, 240),
                            const Rect.fromLTWH(285, 1085, 245, 240),
                            const Rect.fromLTWH(550, 1085, 245, 240),
                            const Rect.fromLTWH(815, 1085, 245, 240),
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

                                  if (_isReviewMode) {
                                    if (optionLetter == correctOption) {
                                      overlayColor = Colors.green.withOpacity(0.4); 
                                    } else if (optionLetter == pageUserAnswer) {
                                      overlayColor = Colors.red.withOpacity(0.4); 
                                    }
                                  } else if (_isTimedMode) {
                                    if (pageUserAnswer != null) {
                                      if (optionLetter == correctOption) {
                                        overlayColor = Colors.green.withOpacity(0.4); 
                                      } else if (optionLetter == pageUserAnswer && pageUserAnswer != "ZAMAN_DOLDU") {
                                        overlayColor = Colors.red.withOpacity(0.4); 
                                      }
                                    }
                                  } else {
                                    if (optionLetter == pageUserAnswer) {
                                      overlayColor = Colors.black.withOpacity(0.2);
                                    }
                                  }

                                  return Positioned(
                                    left: rect.left * scale,
                                    top: rect.top * scale,
                                    width: rect.width * scale,
                                    height: rect.height * scale,
                                    child: GestureDetector(
                                      onTap: _isReviewMode ? null : () => _checkAnswer(optionLetter, pageIndex),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: overlayColor,
                                          borderRadius: BorderRadius.circular(16),
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
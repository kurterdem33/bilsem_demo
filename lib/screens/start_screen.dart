import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'home_page.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/videos/start_screen.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isInitialized = true;
        });
        _videoController.setVolume(0.0);
        _videoController.setLooping(true);
        _videoController.play();
      });

    // Otomatik geçiş için 5 saniyelik sayaç
    _navigationTimer = Timer(const Duration(seconds: 5), () {
      _navigateToHome();
    });
  }

  void _navigateToHome() {
    if (mounted) {
      // Eğer kullanıcı ekrana tıklayıp geçerse, sayacı iptal et ki tekrar çalışmasın
      _navigationTimer?.cancel(); 
      _videoController.pause();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Tüm ekranı kaplayan GestureDetector
      body: GestureDetector(
        onTap: _navigateToHome, // Ekrana tıklandığında geçiş fonksiyonunu tetikle
        behavior: HitTestBehavior.opaque, // Boş alanların da tıklamayı algılamasını sağlar
        child: _isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.red),
              ),
      ),
    );
  }
}
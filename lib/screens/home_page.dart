import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:provider/provider.dart'; 
import 'package:lottie/lottie.dart'; 

import '../widgets/bilsem_button.dart';
import '../iap_provider.dart'; 
import '../streak_provider.dart'; 

import 'pre_evaluation_page.dart';
import 'interview_stage_page.dart';
import 'bilsem_nedir_page.dart'; 
import 'tam_surum_page.dart'; 
import 'gunluk_test_sistemi.dart'; 

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color targetRed = Color(0xFFEE2B2B);

    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isTablet = shortestSide >= 600;

    // Kullanıcının premium durumunu anlık olarak çekiyoruz
    bool isPremium = context.watch<IAPProvider>().isPremium;
    
    // Anlık Seri
    int currentStreak = context.watch<StreakProvider>().currentStreak;

    // --- DİNAMİK TASARIM DEĞİŞKENLERİ ---
    // Premium değilse rozete yer açmak için aralıkları daralt, Premium ise genişlet
    final double gap = isPremium ? 20.0 : 12.0; 
    
    // Premium değilse logoyu biraz daha ufaltıp yukarı çekeriz
    final double logoHeight = isTablet 
        ? (isPremium ? 350.0 : 300.0) 
        : (isPremium ? 280.0 : 230.0);

    return Scaffold(
      body: Stack(
        children: [
          // 1. ARKA PLAN KATMANI
          Positioned.fill(
            child: Image.asset(
              isTablet 
                  ? 'assets/images/bilsem_demo_tablet.jpg' 
                  : 'assets/images/home_page_background.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter, 
            ),
          ),
          
          // 2. ANA İÇERİK KATMANI
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                // DİNAMİK PADDING: Premium değilse en alttan 90px boşluk bırak ki rozet butonları ezmesin
                padding: EdgeInsets.fromLTRB(36.0, 16.0, 36.0, isPremium ? 24.0 : 90.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- DİNAMİK LOGO ---
                    Image.asset(
                      'assets/images/logo.png',
                      height: logoHeight,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: gap), // Logo ile ilk buton arasındaki dinamik mesafe
                    
                    // 1. TABLET SINAVI
                    BilsemButton(
                      label: "TABLET SINAVI",
                      backgroundColor: const Color(0xFF0F172A),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PreEvaluationPage()),
                        );
                      },
                    ),
                    SizedBox(height: gap),
                    
                    // 2. MÜLAKAT
                    BilsemButton(
                      label: "MÜLAKAT",
                      backgroundColor: const Color(0xFF0F172A),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const InterviewStagePage()),
                        );
                      },
                    ),
                    SizedBox(height: gap),
                    
                    // 3. GÜNLÜK TEST
                    Stack(
                      clipBehavior: Clip.none, 
                      children: [
                        BilsemButton(
                          label: isPremium ? "GÜNLÜK TEST" : "GÜNLÜK TEST 🔒",
                          backgroundColor: targetRed,
                          onPressed: () {
                            if (isPremium) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const GunlukTestSistemiPage()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TamSurumPage()),
                              );
                            }
                          },
                        ),
                        
                        // SADECE PREMIUMSA (KİLİT AÇIKSA) ALEV VE GÜN SAYACINI GÖSTER
                        if (isPremium)
                          Positioned(
                            right: -15, 
                            top: -25,   
                            child: IgnorePointer( 
                              child: SizedBox(
                                width: 85,
                                height: 85,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Lottie.asset('assets/lottie/fire.json', fit: BoxFit.contain),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 18),
                                        Text(
                                          "$currentStreak", 
                                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black),
                                        ),
                                        Text(
                                          "GÜN", 
                                          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black, height: 0.8),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: gap),
                    
                    // 4. BİLSEM NEDİR?
                    BilsemButton(
                      label: "BİLSEM NEDİR?",
                      backgroundColor: const Color(0xFF0F172A), 
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BilsemNedirPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- SAĞ ALT 3D ALTIN BUTON (TAM SÜRÜM ROZETİ) ---
          if (!isPremium)
            Positioned(
              bottom: 40,
              right: 30,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TamSurumPage()),
                  );
                },
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFDF00), Color(0xFFD4AF37)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFCA28).withOpacity(0.6),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                      const BoxShadow(
                        color: Color(0xFFB8860B),
                        offset: Offset(0, 8),
                        blurRadius: 0, 
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "TAM\nSÜRÜM",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A), 
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
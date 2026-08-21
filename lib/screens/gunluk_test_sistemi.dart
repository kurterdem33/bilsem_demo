import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

// MERKEZİ HAFIZA
import '../streak_provider.dart';

// TEST VE OYUN SAYFALARI İÇİN İMPORTLAR
import 'gunluk_test.dart'; 
import 'gorsel_hafiza.dart'; 
import 'simetri_oyunu.dart'; 
import 'reaksiyon_oyunu.dart'; 
import 'kup_sayma.dart';       
import 'kusursuz_cember.dart'; 
import 'notalar.dart';         

class GunlukTestSistemiPage extends StatelessWidget {
  const GunlukTestSistemiPage({super.key});

  // SİSTEM NASIL ÇALIŞIYOR - BİLGİ EKRANI
  void _showSystemRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Text(
          "Sistem Nasıl Çalışıyor?", 
          textAlign: TextAlign.center, 
          style: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), fontSize: 20)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRuleItem("🔥", "Her gün bugünün testini çöz en az 10 doğru yap. Görevini tamamla ve serini artır."),
            _buildRuleItem("🔓", "Rekor serin arttıkça her 5 günde bir (5, 10, 15...) yeni bir Gizemli Oyunun kilidi açılır."),
            _buildRuleItem("❤️", "Toplam 5 canın var. Uygulamaya girmediğin her gün 1 canın azalır."),
            _buildRuleItem("⚠️", "Tüm canların biterse serin sıfırlanır! Açtığın oyunlar sende kalır ama yenilerini açmak için eski rekorunu geçmen gerekir."),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE2B2B),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text("ANLADIM", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildRuleItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text, 
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final streakProvider = context.watch<StreakProvider>();
    
    int currentStreak = streakProvider.currentStreak;
    int currentLives = streakProvider.currentLives;
    bool isTodayTestDone = streakProvider.isTodayTestDone;
    int highestStreak = streakProvider.highestStreak; 

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Sabit Arka Plan Görseli
          Positioned.fill(
            child: Image.asset('assets/images/arkaplan.jpg', fit: BoxFit.cover),
          ),
          
          // 2. Kaydırılabilir İçerik Alanı
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ÜST BAR: GERİ BUTONU VE CANLAR 
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        // Canlar Göstergesi
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFEE2B2B), width: 2),
                          ),
                          child: Row(
                            children: List.generate(5, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 2.0),
                                child: Icon(
                                  index < currentLives ? Icons.favorite : Icons.favorite_border,
                                  color: const Color(0xFFEE2B2B),
                                  size: 18,
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // BÜYÜK ATEŞ VE GÜN SAYACI (Geliştirici hilesi tamamen kaldırıldı)
                  SizedBox(
                    height: 140, 
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Lottie.asset('assets/lottie/fire.json', fit: BoxFit.contain),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 35), 
                            Text(
                              "$currentStreak", 
                              style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black, height: 1.0),
                            ),
                            Text(
                              "GÜN", 
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // İNTERAKTİF 3D "GÜNLÜK TESTİ ÇÖZ" BUTONU
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Pushable3DButton(
                      onPressed: isTodayTestDone ? null : () async {
                        // Test sayfasına git
                        bool? testCompleted = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GunlukTestPage()),
                        );
                        
                        // Test bitince gerçek seriyi artır
                        if (testCompleted == true && context.mounted) {
                          context.read<StreakProvider>().completeDailyTest();
                        }
                      },
                      color: isTodayTestDone ? Colors.grey.shade400 : const Color(0xFFEE2B2B),
                      shadowColor: isTodayTestDone ? Colors.grey.shade500 : const Color(0xFFA01A1A),
                      depth: 8.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        width: double.infinity,
                        child: Text(
                          isTodayTestDone ? "GÖREV TAMAMLANDI" : "BUGÜNÜN TESTİNİ ÇÖZ",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  // GİZEMLİ OYUNLAR BÖLÜMÜ BAŞLIĞI 
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Gizemli Oyunları Keşfet", 
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                      ),
                    ),
                  ),

                  // KARE 3D OYUN BUTONLARI VE YÖNLENDİRMELER
                  GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 24, 
                      childAspectRatio: 1.0, 
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      // Kilit açılma şartları (Her oyun 5 günde bir açılır: 5, 10, 15...)
                      int requiredDays = (index + 1) * 5; 
                      
                      // KİLİTLERİ REKORA GÖRE AÇIYORUZ
                      bool isUnlocked = highestStreak >= requiredDays;
                      
                      List<String> gameNames = [
                        "Görsel Hafıza", 
                        "Simetri Kapışması", 
                        "Reaksiyon", 
                        "Küp Sayma", 
                        "Kusursuz Çember", 
                        "Notalar"
                      ];

                      return Pushable3DButton(
                        onPressed: () {
                          if (isUnlocked) {
                            Widget targetPage;
                            switch (index) {
                              case 0:
                                targetPage = const GorselHafizaPage();
                                break;
                              case 1:
                                targetPage = const SimetriOyunuPage();
                                break;
                              case 2:
                                targetPage = const ReaksiyonOyunuPage();
                                break;
                              case 3:
                                targetPage = const KupSaymaPage();
                                break;
                              case 4:
                                targetPage = const KusursuzCemberPage();
                                break;
                              case 5:
                                targetPage = const NotalarOyunuPage();
                                break;
                              default:
                                targetPage = const GorselHafizaPage();
                            }
                            
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => targetPage),
                            );

                          } else {
                            // Kilitliyse uyarı mesajı ver
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Bu oyunu açmak için $requiredDays gün rekoruna ulaşmalısın!"),
                                backgroundColor: const Color(0xFFEE2B2B),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        color: isUnlocked ? const Color(0xFF0F172A) : const Color(0xFF334155),
                        shadowColor: isUnlocked ? Colors.black87 : const Color(0xFF0F172A),
                        depth: 6.0,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Logo Alanı
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0, bottom: 42.0),
                              child: Opacity(
                                opacity: isUnlocked ? 1.0 : 0.4, 
                                child: Image.asset(
                                  'assets/images/icons/${index + 1}.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            // Beyaz Transparan Şerit ve Oyun İsmi
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  gameNames[index],
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            // Kilitli uyarı arayüzü
                            if (!isUnlocked)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.lock_rounded, color: Colors.white, size: 40),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$requiredDays Gün", 
                                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  // YENİ: SİSTEM NASIL ÇALIŞIYOR BUTONU
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                    child: Pushable3DButton(
                      onPressed: () => _showSystemRulesDialog(context),
                      color: const Color(0xFFEE2B2B),
                      shadowColor: const Color(0xFFA01A1A),
                      depth: 6.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        width: double.infinity,
                        child: Text(
                          "SİSTEM NASIL ÇALIŞIYOR?",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================================================================
/// ÖZEL 3D BUTON WIDGET'I (Fiziksel basılma hissiyatı)
/// ===================================================================
class Pushable3DButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color color;
  final Color shadowColor;
  final double depth;
  final double borderRadius;

  const Pushable3DButton({
    super.key,
    this.onPressed,
    required this.child,
    required this.color,
    required this.shadowColor,
    this.depth = 6.0,
    this.borderRadius = 20.0,
  });

  @override
  State<Pushable3DButton> createState() => _Pushable3DButtonState();
}

class _Pushable3DButtonState extends State<Pushable3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double currentDepth = _isPressed ? 0.0 : widget.depth;
    
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onPressed != null ? (_) {
        setState(() => _isPressed = false);
        widget.onPressed!(); 
      } : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(top: widget.depth - currentDepth, bottom: currentDepth),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: currentDepth > 0
              ? [
                  BoxShadow(
                    color: widget.shadowColor,
                    offset: Offset(0, currentDepth),
                  )
                ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}
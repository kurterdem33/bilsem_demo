import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // EKLENDİ: Provider paketi

import '../widgets/bilsem_button.dart';
import '../iap_provider.dart'; // EKLENDİ: IAP hafıza dosyamız
import 'tam_surum_page.dart'; // EKLENDİ: Satın alma sayfası yönlendirmesi
import 'number_memory_game_page.dart';

class ModeSelectionPage extends StatelessWidget {
  const ModeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color targetRed = Color(0xFFEE2B2B);
    // Beyaz yazının net okunabilmesi için sarı tonu hafif koyulaştırıldı
    const Color buttonYellow = Color(0xFFF59E0B);

    // Kullanıcının premium durumunu anlık olarak Provider'dan çekiyoruz
    bool isPremium = context.watch<IAPProvider>().isPremium;

    void openGame(int count) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NumberMemoryGamePage(digitCount: count),
        ),
      );
    }

    void showHowToPlayDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            backgroundColor: Colors.white,
            elevation: 10,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: buttonYellow.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lightbulb_rounded, color: Colors.orangeAccent, size: 48),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Hafıza Şampiyonu Olma Taktikleri! 🏆",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87, height: 1.5),
                        children: const [
                          TextSpan(text: "Ekranda çıkan sayıları süre bitmeden ezberle ve kaybolduklarında doğru sırayla kutulara yaz.\n\n"),
                          TextSpan(text: "🧠 Usta İşi Strateji:\n", style: TextStyle(fontWeight: FontWeight.w800, color: targetRed)),
                          TextSpan(text: "Sayıları '3-7-2' diye tek tek okumak yerine, "),
                          TextSpan(text: "'Üç yüz yetmiş iki' ", style: TextStyle(fontWeight: FontWeight.w800)),
                          TextSpan(text: "diye bütün olarak okursan zihnin onu hemen fotoğraflar!\n\n"),
                          TextSpan(text: "🚀 Uzun Sayılar İçin Gizli Silah:\n", style: TextStyle(fontWeight: FontWeight.w800, color: targetRed)),
                          TextSpan(text: "5, 6 veya 7 rakamlı zor görevlerde sayıları ikili veya üçlü gruplara ayır. Örneğin "),
                          TextSpan(text: "2-8-7-1-9-0-2 ", style: TextStyle(fontWeight: FontWeight.w800)),
                          TextSpan(text: "gördüğünde içinden "),
                          TextSpan(text: "'28... 71... 902' ", style: TextStyle(fontWeight: FontWeight.w800)),
                          TextSpan(text: "şeklinde tekrar et. İnan çok daha kolay olacak!"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: targetRed,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 4,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Anladım, Hadi Başlayalım!",
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/sayi_hafizasi_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Sayı Hafızası", 
                        style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ),
                // KAYDIRILABİLİR OYUN BUTONLARI ALANI
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(left: 36.0, right: 36.0, top: 20.0, bottom: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // 3 Sayı (HER ZAMAN AÇIK)
                        BilsemButton(label: "3 Sayı", backgroundColor: targetRed, onPressed: () => openGame(3)),
                        const SizedBox(height: 16),
                        
                        // 4 Sayı (HER ZAMAN AÇIK)
                        BilsemButton(label: "4 Sayı", backgroundColor: targetRed, onPressed: () => openGame(4)),
                        const SizedBox(height: 16),
                        
                        // 5 Sayı (KİLİTLİ OLABİLİR)
                        BilsemButton(
                          label: isPremium ? "5 Sayı" : "5 Sayı 🔒", 
                          backgroundColor: targetRed, 
                          onPressed: () {
                            if (isPremium) {
                              openGame(5);
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TamSurumPage()));
                            }
                          }
                        ),
                        const SizedBox(height: 16),
                        
                        // 6 Sayı (KİLİTLİ OLABİLİR)
                        BilsemButton(
                          label: isPremium ? "6 Sayı" : "6 Sayı 🔒", 
                          backgroundColor: targetRed, 
                          onPressed: () {
                            if (isPremium) {
                              openGame(6);
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TamSurumPage()));
                            }
                          }
                        ),
                        const SizedBox(height: 16),
                        
                        // 7 Sayı (KİLİTLİ OLABİLİR)
                        BilsemButton(
                          label: isPremium ? "7 Sayı" : "7 Sayı 🔒", 
                          backgroundColor: targetRed, 
                          onPressed: () {
                            if (isPremium) {
                              openGame(7);
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TamSurumPage()));
                            }
                          }
                        ),
                      ],
                    ),
                  ),
                ),
                
                // EKRANIN EN ALTINA SABİTLENMİŞ YENİ "NASIL OYNANIR?" BUTONU
                Padding(
                  padding: const EdgeInsets.only(left: 36.0, right: 36.0, bottom: 24.0, top: 8.0),
                  child: BilsemButton(
                    label: "Nasıl Oynanır?",
                    backgroundColor: buttonYellow,
                    onPressed: showHowToPlayDialog,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
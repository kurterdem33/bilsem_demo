import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // EKLENDİ: Provider paketi

import '../widgets/bilsem_button.dart';
import '../iap_provider.dart'; // EKLENDİ: IAP hafıza dosyamız
import 'tam_surum_page.dart'; // EKLENDİ: Satın alma sayfası yönlendirmesi

import 'matrix_game_page.dart'; 

class MatrixModeSelectionPage extends StatelessWidget {
  const MatrixModeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color targetRed = Color(0xFFEE2B2B);

    // Kullanıcının premium durumunu anlık olarak Provider'dan çekiyoruz
    bool isPremium = context.watch<IAPProvider>().isPremium;

    void openMatrixGame(String category) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatrixGamePage(categoryName: category),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/matris_background.jpg', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        "Matris Konuları",
                        style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
                // KAYDIRILABİLİR OYUN BUTONLARI ALANI
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    // Alt kısımdan biraz boşluk bıraktık ki son buton ekrana yapışmasın
                    padding: const EdgeInsets.only(left: 36.0, right: 36.0, top: 20.0, bottom: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // 1. Eksik Bulma (HER ZAMAN AÇIK)
                        BilsemButton(
                          label: "Eksik Bulma", 
                          backgroundColor: targetRed, 
                          onPressed: () => openMatrixGame("Eksik Bulma")
                        ),
                        const SizedBox(height: 16),
                        
                        // 2. Döndürme (HER ZAMAN AÇIK)
                        BilsemButton(
                          label: "Döndürme", 
                          backgroundColor: targetRed, 
                          onPressed: () => openMatrixGame("Döndürme")
                        ),
                        const SizedBox(height: 16),
                        
                        // 3. Ortak Nokta (KİLİTLİ OLABİLİR)
                        BilsemButton(
                          label: isPremium ? "Ortak Nokta" : "Ortak Nokta 🔒", 
                          backgroundColor: targetRed, 
                          onPressed: () {
                            if (isPremium) {
                              openMatrixGame("Ortak Nokta");
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TamSurumPage()));
                            }
                          }
                        ),
                        const SizedBox(height: 16),
                        
                        // 4. Birleşme (KİLİTLİ OLABİLİR)
                        BilsemButton(
                          label: isPremium ? "Birleşme" : "Birleşme 🔒", 
                          backgroundColor: targetRed, 
                          onPressed: () {
                            if (isPremium) {
                              openMatrixGame("Birleşme");
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TamSurumPage()));
                            }
                          }
                        ),
                        const SizedBox(height: 16),
                        
                        // 5. Artma-Azalma (KİLİTLİ OLABİLİR)
                        BilsemButton(
                          label: isPremium ? "Artma-Azalma" : "Artma-Azalma 🔒", 
                          backgroundColor: targetRed, 
                          onPressed: () {
                            if (isPremium) {
                              openMatrixGame("Artma-Azalma");
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TamSurumPage()));
                            }
                          }
                        ),
                        const SizedBox(height: 16),
                        
                        // 6. Kaydırma (KİLİTLİ OLABİLİR)
                        BilsemButton(
                          label: isPremium ? "Kaydırma" : "Kaydırma 🔒", 
                          backgroundColor: targetRed, 
                          onPressed: () {
                            if (isPremium) {
                              openMatrixGame("Kaydırma");
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TamSurumPage()));
                            }
                          }
                        ),
                      ],
                    ),
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
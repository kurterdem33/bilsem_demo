import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // EKLENDİ: Provider paketi

import '../widgets/bilsem_button.dart';
import '../iap_provider.dart'; // EKLENDİ: IAP hafıza dosyamız
import 'tam_surum_page.dart'; // EKLENDİ: Satın alma sayfası yönlendirmesi

import 'matrix_mode_selection_page.dart';
import 'eksik_parca_page.dart';
import 'denemeler_menu_page.dart'; // Denemeler sayfasının import'u

class PreEvaluationPage extends StatelessWidget {
  const PreEvaluationPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color targetRed = Color(0xFFEE2B2B);

    // Kullanıcının premium durumunu anlık olarak Provider'dan çekiyoruz
    bool isPremium = context.watch<IAPProvider>().isPremium;

    return Scaffold(
      body: Stack(
        children: [
          // ARKA PLAN
          Positioned.fill(
            child: Image.asset('assets/images/sayi_hafizasi_background.jpg', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                // ÜST BİLGİ BARI
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        "Tablet Sınavı",
                        style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
                
                // ORTA BUTONLAR KISMI
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Matris Butonu (HER ZAMAN AÇIK)
                          BilsemButton(
                            label: "Matris",
                            backgroundColor: targetRed,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MatrixModeSelectionPage()),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Eksik Parça Butonu (KİLİTLİ OLABİLİR)
                          BilsemButton(
                            label: isPremium ? "Eksik Parça" : "Eksik Parça 🔒",
                            backgroundColor: targetRed,
                            onPressed: () {
                              if (isPremium) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const EksikParcaPage()),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TamSurumPage()),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Denemeler Butonu (Lacivert) (HER ZAMAN AÇIK)
                          // Not: Denemelerin kendi içindeki kilitleri biz zaten DenemelerMenuPage içinde yapmıştık.
                          BilsemButton(
                            label: "Denemeler",
                            backgroundColor: const Color(0xFF0F172A), // Lacivert
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const DenemelerMenuPage()),
                              );
                            },
                          ),
                        ],
                      ),
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
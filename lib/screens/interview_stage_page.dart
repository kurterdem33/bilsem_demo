import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // EKLENDİ: Provider paketi

import '../widgets/bilsem_button.dart';
import '../iap_provider.dart'; // EKLENDİ: IAP hafıza dosyamız
import 'tam_surum_page.dart'; // EKLENDİ: Satın alma sayfası yönlendirmesi

import 'mode_selection_page.dart'; 
import 'es_anlamlilar_page.dart'; 
import 'labirent_seviye_page.dart'; 
import 'akraba_page.dart';
import 'benzesim_page.dart';
import 'muzik_aletleri_page.dart';

class InterviewStagePage extends StatelessWidget {
  const InterviewStagePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color targetRed = Color(0xFFEE2B2B);

    // Kullanıcının premium durumunu anlık olarak Provider'dan çekiyoruz
    bool isPremium = context.watch<IAPProvider>().isPremium;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/sayi_hafizasi_background.jpg', fit: BoxFit.cover),
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
                      const Spacer(),
                      Text(
                        "Mülakat Aşaması",
                        style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
                // KAYDIRILABİLİR OYUN BUTONLARI ALANI
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(left: 36.0, right: 36.0, top: 20.0, bottom: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // 1. Sayı Hafızası (HER ZAMAN AÇIK)
                        BilsemButton(
                          label: "Sayı Hafızası",
                          backgroundColor: targetRed,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ModeSelectionPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // 2. Eş Anlamlılar (KİLİTLİ OLABİLİR)
                        BilsemButton(
                          label: isPremium ? "Eş Anlamlılar" : "Eş Anlamlılar 🔒",
                          backgroundColor: targetRed,
                          onPressed: () {
                            if (isPremium) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EsAnlamlilarPage()),
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
                        
                        // 3. Labirent (HER ZAMAN AÇIK)
                        BilsemButton(
                          label: "Labirent",
                          backgroundColor: targetRed,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LabirentSeviyePage()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // 4. Akraba (KİLİTLİ OLABİLİR)
                        BilsemButton(
                          label: isPremium ? "Akraba" : "Akraba 🔒",
                          backgroundColor: targetRed,
                          onPressed: () {
                            if (isPremium) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AkrabaPage()),
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
                        
                        // 5. Benzeşim (KİLİTLİ OLABİLİR)
                        BilsemButton(
                          label: isPremium ? "Benzeşim" : "Benzeşim 🔒",
                          backgroundColor: targetRed,
                          onPressed: () {
                            if (isPremium) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BenzesimPage()),
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
                        
                        // 6. Müzik Aletleri (KİLİTLİ OLABİLİR)
                        BilsemButton(
                          label: isPremium ? "Müzik Aletleri" : "Müzik Aletleri 🔒",
                          backgroundColor: targetRed,
                          onPressed: () {
                            if (isPremium) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MuzikAletleriPage()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TamSurumPage()),
                              );
                            }
                          },
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
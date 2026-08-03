import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Provider import edildi

import '../widgets/bilsem_button.dart';
import '../iap_provider.dart'; // Premium durumunu kontrol edeceğimiz provider

import 'labirent_oyun_page.dart';
import 'tam_surum_page.dart'; // Kilitliyken yönlendirilecek sayfa

class LabirentSeviyePage extends StatelessWidget {
  const LabirentSeviyePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color targetRed = Color(0xFFEE2B2B);

    // Kullanıcının premium durumunu anlık olarak Provider'dan çekiyoruz
    bool isPremium = context.watch<IAPProvider>().isPremium;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/sayi_hafizasi_background_2.jpg', fit: BoxFit.cover),
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
                        "Labirent",
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 32),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              "Önce gözünle takip ederek çıkışa ulaş, sonra duvarlara çarpmadan, yanlış koridorlara girmeden çıkışı bul!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                            ),
                          ),
                          
                          // KOLAY SEVİYE (Herkese Açık)
                          BilsemButton(
                            label: "Kolay",
                            backgroundColor: targetRed,
                            onPressed: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => const LabirentOyunPage(gridWidth: 11))
                              );
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // ZOR SEVİYE (Premium Kontrollü)
                          BilsemButton(
                            label: isPremium ? "Zor" : "Zor 🔒", // Duruma göre kilit ikonu
                            backgroundColor: isPremium ? targetRed : Colors.grey.shade600, // Duruma göre gri renk
                            onPressed: () {
                              if (isPremium) {
                                // Satın almışsa oyunu aç
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => const LabirentOyunPage(gridWidth: 17))
                                );
                              } else {
                                // Satın almamışsa Tam Sürüm (Satın Alma) sayfasına yönlendir
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => const TamSurumPage())
                                );
                              }
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
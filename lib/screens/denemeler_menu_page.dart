import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Provider paketini ekledik

import '../widgets/bilsem_button.dart';
import '../iap_provider.dart'; // IAP hafıza dosyamızı ekledik
import 'tam_surum_page.dart'; // Yönlendirme yapacağımız Satın Alma sayfası

// Sayfa importları
import 'deneme_sinavi_page_1.dart'; 
import 'deneme_sinavi_page_2.dart';
import 'deneme_sinavi_page_3.dart';
import 'deneme_sinavi_page_4.dart';

class DenemelerMenuPage extends StatelessWidget {
  const DenemelerMenuPage({super.key});

  void _showInfoPopup(BuildContext context, Widget targetPage, String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow(Icons.format_list_numbered_rounded, "Soru Sayısı:", "49 Soru"),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.timer_rounded, "Soru Başına Süre:", "60 Saniye"),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.warning_amber_rounded, "Önemli Kural:", "Sorular arası geri dönüş yapılamaz."),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("İptal", style: GoogleFonts.poppins(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => targetPage),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text("Sınava Başla", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFEE2B2B), size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
              children: [
                TextSpan(text: "$title ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color navyBlue = Color(0xFF1E3A8A);

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
                      Text("Denemeler", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 1. Deneme HER ZAMAN AÇIK
                          BilsemButton(
                            label: "1. Deneme", 
                            backgroundColor: navyBlue, 
                            onPressed: () => _showInfoPopup(context, const DenemeSinaviPage1(), "1. Deneme Sınavı")
                          ),
                          const SizedBox(height: 16),
                          
                          // 2. Deneme (KİLİTLİ OLABİLİR)
                          BilsemButton(
                            label: isPremium ? "2. Deneme" : "2. Deneme 🔒", 
                            backgroundColor: navyBlue, 
                            onPressed: () {
                              if (isPremium) {
                                _showInfoPopup(context, const DenemeSinaviPage2(), "2. Deneme Sınavı");
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const TamSurumPage()));
                              }
                            }
                          ),
                          const SizedBox(height: 16),
                          
                          // 3. Deneme (KİLİTLİ OLABİLİR)
                          BilsemButton(
                            label: isPremium ? "3. Deneme" : "3. Deneme 🔒", 
                            backgroundColor: navyBlue, 
                            onPressed: () {
                              if (isPremium) {
                                _showInfoPopup(context, const DenemeSinaviPage3(), "3. Deneme Sınavı");
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const TamSurumPage()));
                              }
                            }
                          ),
                          const SizedBox(height: 16),
                          
                          // 4. Deneme (KİLİTLİ OLABİLİR)
                          BilsemButton(
                            label: isPremium ? "4. Deneme" : "4. Deneme 🔒", 
                            backgroundColor: navyBlue, 
                            onPressed: () {
                              if (isPremium) {
                                _showInfoPopup(context, const DenemeSinaviPage4(), "4. Deneme Sınavı");
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const TamSurumPage()));
                              }
                            }
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
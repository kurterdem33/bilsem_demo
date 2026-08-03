import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; 
import '../iap_provider.dart'; 

class TamSurumPage extends StatelessWidget {
  const TamSurumPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandDarkBlue = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFC3EEFA), 
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.8),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: brandDarkBlue, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/tam_surum.jpg',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  const SizedBox(height: 150), // Butonlar için biraz daha yer açtık
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Sadece içindekiler kadar yer kapla
              children: [
                // YENİ EKLENEN: İnce Kırmızı Geri Yükle Butonu
                TextButton(
                  onPressed: () {
                    context.read<IAPProvider>().restorePremium();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Satın Alımları Geri Yükle",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.red.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 12), // İki buton arası boşluk
                
                // MEVCUT SATIN AL BUTONU
                GestureDetector(
                  onTap: () {
                    context.read<IAPProvider>().buyPremium();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 75,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFDF00), Color(0xFFD4AF37)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFCA28).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                        const BoxShadow(
                          color: Color(0xFFB8860B),
                          offset: Offset(0, 6),
                          blurRadius: 0, 
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "ŞİMDİ SATIN AL - 249 TL",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: brandDarkBlue,
                          letterSpacing: 1.2,
                        ),
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
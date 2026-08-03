import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // EKLENDİ: Provider paketi

import '../iap_provider.dart'; // EKLENDİ: IAP hafıza dosyamız
import 'tam_surum_page.dart'; // EKLENDİ: Satın alma sayfası yönlendirmesi

class BilsemNedirPage extends StatelessWidget {
  const BilsemNedirPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandDarkBlue = Color(0xFF0F172A);

    // Kullanıcının premium durumunu anlık olarak Provider'dan çekiyoruz
    bool isPremium = context.watch<IAPProvider>().isPremium;

    return Scaffold(
      backgroundColor: brandDarkBlue, // Kararlaştırdığımız koyu lacivert zemin
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Bilsem DEMO",
          style: GoogleFonts.poppins(
            fontSize: 22, 
            fontWeight: FontWeight.bold, 
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. BÖLÜM: KAYDIRILABİLİR GÖRSELLER (1, 2, 3, 4)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(), // Tablette yumuşak kaydırma
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    _buildImageCard('assets/images/bilsem_nedir/1.jpg'),
                    const SizedBox(height: 16), // Görseller arası boşluk
                    
                    _buildImageCard('assets/images/bilsem_nedir/2.jpg'),
                    const SizedBox(height: 16),
                    
                    _buildImageCard('assets/images/bilsem_nedir/3.jpg'),
                    const SizedBox(height: 16),
                    
                    _buildImageCard('assets/images/bilsem_nedir/4.jpg'),
                    const SizedBox(height: 24), // En alta gelindiğinde butonla aradaki ferahlık
                  ],
                ),
              ),
            ),

            // 2. BÖLÜM: EKRANIN ALTINA SABİTLENMİŞ ALTIN BUTON
            // SADECE KULLANICI PREMIUM DEĞİLSE GÖRÜNÜR
            if (!isPremium)
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
                child: GestureDetector(
                  onTap: () {
                    // Tam Sürüm sayfasına yönlendirme eklendi
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TamSurumPage()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 75,
                    decoration: BoxDecoration(
                      // Altın sarısı parlak gradyan efekti
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFDF00), Color(0xFFD4AF37)], 
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        // Etrafa yayılan altın parlaması (Glow)
                        BoxShadow(
                          color: const Color(0xFFFFCA28).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                        // 3D derinlik veren katı alt gölge
                        const BoxShadow(
                          color: Color(0xFFB8860B), 
                          offset: Offset(0, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "TAM SÜRÜM SATIN AL",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: brandDarkBlue, // Altın zemin üstünde lacivert çok net okunur
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Görselleri köşeleri yuvarlatılmış kartlar halinde sarmalayan yardımcı widget
  Widget _buildImageCard(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20), // Lacivert zeminde harika bir çerçeve yaratır
      child: Image.asset(
        imagePath,
        width: double.infinity,
        fit: BoxFit.fitWidth, // Ekrana tam genişlikte oturmasını sağlar
      ),
    );
  }
}
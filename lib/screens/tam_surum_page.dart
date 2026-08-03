import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // EKLENDİ: Provider paketi
import '../iap_provider.dart'; // EKLENDİ: IAP Provider dosyamızın yolu (klasör yapına göre düzeltmen gerekebilir)

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
                  const SizedBox(height: 120), 
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: GestureDetector(
              onTap: () {
                // EKLENDİ: Butona tıklandığında Satın Alma tetiklenecek
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
          ),
        ],
      ),
    );
  }
}
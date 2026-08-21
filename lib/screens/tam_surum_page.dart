import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; 
import '../iap_provider.dart'; 

class TamSurumPage extends StatelessWidget {
  const TamSurumPage({super.key});

  // Tasarım bütünlüğü için ana lacivert rengimizi buraya sabitliyoruz
  static const Color brandDarkBlue = Color(0xFF0F172A);

  // Şık Tasarımlı Ebeveyn Kapısı (Parental Gate) Fonksiyonu
  void _ebeveynKapisiGoster(BuildContext context, VoidCallback onBasarili) {
    TextEditingController cevapController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Boşluğa tıklayıp kapanmasını engeller
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            "Yetişkin Doğrulaması",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800, 
              color: brandDarkBlue, 
              fontSize: 20
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Lütfen velinizden yardım isteyin.\nDevam etmek için işlemi çözün:",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black87, 
                  fontSize: 14, 
                  fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "12 + 15 = ?",
                style: GoogleFonts.poppins(
                  fontSize: 28, 
                  fontWeight: FontWeight.w900, 
                  color: Colors.red.shade700
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: cevapController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: "Cevap",
                  hintStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.normal),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: brandDarkBlue, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // İptal butonu
              child: Text(
                "İptal", 
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600, 
                  fontWeight: FontWeight.w600
                )
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandDarkBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                if (cevapController.text.trim() == "27") {
                  Navigator.pop(context); // Diyalogu kapat
                  onBasarili(); // Başarılıysa satın alma işlemini tetikle
                } else {
                  Navigator.pop(context); // Diyalogu kapat
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red.shade800,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      content: Text(
                        "Yanlış cevap! Lütfen velinizden yardım isteyin.",
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }
              },
              child: Text("Onayla", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 150), // Butonlar için boşluk
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
                // İnce Kırmızı Geri Yükle Butonu
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
                
                // SATIN AL BUTONU VE EBEVEYN KAPISI ENTEGRASYONU
                GestureDetector(
                  onTap: () {
                    // Önce ebeveyn kapısını çağırıyoruz, başarılıysa satın alım başlıyor
                    _ebeveynKapisiGoster(context, () {
                      context.read<IAPProvider>().buyPremium();
                    });
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
                        "TAM SÜRÜM KİLİDİNİ AÇ",
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
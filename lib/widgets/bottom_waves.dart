import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class BottomWaves extends StatelessWidget {
  const BottomWaves({super.key});

  @override
  Widget build(BuildContext context) {
    // HATANIN ÇÖZÜMÜ: Telefonun ekran boyutunu ölçen satırı ekledik
    final size = MediaQuery.of(context).size;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            // 1. Dalga: Turuncu Arka Plan Dalgası
            Positioned.fill(
              child: ClipPath(
                clipper: OrangeWaveClipper(),
                child: Container(color: AppColors.accent.withOpacity(0.85)),
              ),
            ),
            // 2. Dalga: En Öndeki Yeşil/Mavi Geçişli Ana Dalga
            Positioned.fill(
              child: ClipPath(
                clipper: GreenWaveClipper(),
                child: Container(color: AppColors.success),
              ),
            ),
            
            // --- MATEMATİK ELEMANLARI (size değişkeni artık aktif) ---
            _buildFloatingSymbol("7", 20, 40, 32, Colors.white.withOpacity(0.4)),
            _buildFloatingSymbol("+", 70, 20, 28, Colors.white.withOpacity(0.3)),
            _buildFloatingSymbol("×", 140, 50, 30, Colors.white.withOpacity(0.35)),
            _buildFloatingSymbol("2", size.width * 0.5, 30, 36, Colors.white.withOpacity(0.4)),
            _buildFloatingSymbol("÷", size.width * 0.7, 45, 26, Colors.white.withOpacity(0.3)),
            _buildFloatingSymbol("1", size.width * 0.85, 15, 30, Colors.white.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingSymbol(String text, double left, double bottom, double fontSize, Color color) {
    return Positioned(
      left: left,
      bottom: bottom,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class OrangeWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.1, size.width * 0.5, size.height * 0.45);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height * 0.35);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class GreenWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.65);
    path.quadraticBezierTo(size.width * 0.35, size.height, size.width * 0.7, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.88, size.height * 0.3, size.width, size.height * 0.45);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
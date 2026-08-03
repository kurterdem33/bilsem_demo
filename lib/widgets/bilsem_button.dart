import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BilsemButton extends StatefulWidget {
  final String label;
  final Color backgroundColor;
  final VoidCallback onPressed;
  final String? iconPath;

  const BilsemButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
    this.iconPath,
  });

  @override
  State<BilsemButton> createState() => _BilsemButtonState();
}

class _BilsemButtonState extends State<BilsemButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 3D efekti için alt gölge (Daha belirgin derinlik)
    final Color shadowColor = Color.alphaBlend(
      Colors.black.withOpacity(0.5),
      widget.backgroundColor,
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        width: double.infinity,
        height: 85, 
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // 1. KATMAN: Alt Gölge
            Container(
              height: 75,
              decoration: BoxDecoration(
                color: shadowColor,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            // 2. KATMAN: Hareketli Ana Buton
            AnimatedPositioned(
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeOutQuad,
              bottom: _isPressed ? 0 : 10.0, // 10 piksellik çökme mesafesi
              left: 0,
              right: 0,
              child: Container(
                height: 75,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.iconPath != null) ...[
                        Image.asset(
                          widget.iconPath!,
                          width: 38,
                          height: 38,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 15),
                      ],
                      // --- 3D YAZI EFEKTİ EKLENEN KISIM ---
                      Text(
                        widget.label,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              // Buton basılıyken gölge derinliği azalır, bırakılınca artar
                              offset: _isPressed ? const Offset(0, 1) : const Offset(0, 3.5),
                              blurRadius: 0, // 3D katı hissiyatı için blur 0
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
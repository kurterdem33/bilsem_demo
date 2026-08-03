import 'package:flutter/material.dart';

class AppText {
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  // Home Page'in aradığı başlık stili
  static const TextStyle pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF333333),
  );

  // DOĞRUSU: FontWeight.black yerine FontWeight.w900 yapıldı
  static const TextStyle countdown = TextStyle(
    fontSize: 54,
    fontWeight: FontWeight.w900, 
    color: Color(0xFF333333),
  );

  static const TextStyle memoryNumber = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
    color: Color(0xFF2D9CDB),
  );

  // Bilsem Butonunun aradığı aktif buton yazı stili
  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Bilsem Butonunun aradığı pasif (Yakında) buton yazı stili
  static const TextStyle disabledButton = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF828282),
  );
}
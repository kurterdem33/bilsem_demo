import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakProvider extends ChangeNotifier {
  // --- TEMEL DURUM DEĞİŞKENLERİ ---
  int _currentStreak = 0;
  int _highestStreak = 0;
  int _currentLives = 5;
  bool _isTodayTestDone = false;
  DateTime? _lastTestDate;

  // --- GETTER METOTLARI (Arayüzün okuyacağı değerler) ---
  int get currentStreak => _currentStreak;
  int get highestStreak => _highestStreak;
  int get currentLives => _currentLives;
  bool get isTodayTestDone => _isTodayTestDone;

  // Constructor: Sınıf çağrıldığında hafızadaki verileri yükler ve gün kontrolü yapar
  StreakProvider() {
    _loadData();
  }

  // --- 1. GÜNLÜK TEST TAMAMLANDIĞINDA ÇALIŞACAK FONKSİYON ---
  void completeDailyTest() {
    if (_isTodayTestDone) return; // Zaten yapıldıysa işlem yapma

    _isTodayTestDone = true;
    _currentStreak++;
    _lastTestDate = DateTime.now(); // Testin yapıldığı anı kaydet

    // Yeni seri eski rekoru geçtiyse rekoru güncelle
    if (_currentStreak > _highestStreak) {
      _highestStreak = _currentStreak;
    }

    _saveData(); // Değişiklikleri cihaz hafızasına yaz
    notifyListeners(); // Tüm ekranlara "veriler değişti, kendini güncelle" sinyali gönder
  }

  // --- 2. GELİŞTİRİCİ HİLESİ (Test etmek için) ---
  void developerCheatAddStreak() {
    _currentStreak++;
    if (_currentStreak > _highestStreak) {
      _highestStreak = _currentStreak;
    }
    _saveData();
    notifyListeners();
  }

  // --- 3. ZAMAN KONTROLÜ (Girilmediği günleri hesaplayıp can düşme) ---
  void _calculateMissedDays() {
    if (_lastTestDate == null) return; // Henüz hiç test çözülmemişse kontrol etme

    final now = DateTime.now();
    // Saat/Dakika farklarını yoksaymak için sadece Yıl, Ay, Gün alıyoruz
    final today = DateTime(now.year, now.month, now.day);
    final lastTest = DateTime(_lastTestDate!.year, _lastTestDate!.month, _lastTestDate!.day);

    // Son testin üzerinden kaç GÜN geçmiş?
    final int daysDifference = today.difference(lastTest).inDays;

    if (daysDifference == 0) {
      // Hala aynı gün içindeyiz, görev tamamlanmış olarak kalır.
      _isTodayTestDone = true;
    } else if (daysDifference == 1) {
      // 1 gün geçmiş. Dün testi çözmüş ama bugünün görevini henüz yapmamış. Can gitmez.
      _isTodayTestDone = false;
    } else if (daysDifference > 1) {
      // 2 veya daha fazla gün geçmiş! Yani dün (veya daha önceki günler) girilmemiş. Can düşecek.
      _isTodayTestDone = false;
      
      // Kaç gün tamamen boş geçildiyse o kadar can düş (Fark - 1 çünkü 1 gün zaten "bugün")
      int missedDays = daysDifference - 1; 
      _currentLives -= missedDays;

      // Eğer canlar sıfırlandıysa veya eksiye düştüyse cezayı kes!
      if (_currentLives <= 0) {
        _currentLives = 5; // Canları yenile
        _currentStreak = 0; // Anlık seriyi sıfırla (Rekor korunur!)
      }
    }
  }

  // --- 4. VERİ TABANI İŞLEMLERİ (Cihaz Hafızası) ---
  
  // Verileri Cihazdan Çekme (Uygulama açıldığında çalışır)
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _currentStreak = prefs.getInt('currentStreak') ?? 0;
    _highestStreak = prefs.getInt('highestStreak') ?? 0;
    _currentLives = prefs.getInt('currentLives') ?? 5;
    
    String? lastDateString = prefs.getString('lastTestDate');
    if (lastDateString != null) {
      _lastTestDate = DateTime.parse(lastDateString);
    }

    // Veriler yüklendikten sonra zaman cezasını hesapla
    _calculateMissedDays();
    
    // Değişen durumlar olabilir (ceza yemiş olabiliriz), bu yüzden arayüzü tetikle ve kaydet
    _saveData();
    notifyListeners();
  }

  // Verileri Cihaza Yazma
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('currentStreak', _currentStreak);
    await prefs.setInt('highestStreak', _highestStreak);
    await prefs.setInt('currentLives', _currentLives);
    
    if (_lastTestDate != null) {
      await prefs.setString('lastTestDate', _lastTestDate!.toIso8601String());
    }
  }
}
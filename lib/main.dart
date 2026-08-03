import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // YENİ: Ekran kilitleme paketi eklendi
import 'package:provider/provider.dart';
import 'iap_provider.dart'; // IAP hafıza dosyası
import 'streak_provider.dart'; // Seri ve Can takip hafıza dosyası
import 'screens/start_screen.dart';

void main() {
  // Native eklentilerin ve SharedPreferences'ın runApp'ten önce düzgün çalışması için gerekli
  WidgetsFlutterBinding.ensureInitialized();

  // YENİ: TÜM UYGULAMAYI DİKEY KULLANIMA KİLİTLE
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // Bazı cihazlarda ters çevirmeyi desteklemek için (isteğe bağlı)
  ]).then((_) {
    runApp(
      // MultiProvider ile hem IAP hem de Streak (Seri/Can) yönetimi en tepeye yerleştirildi
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => IAPProvider()..initStoreInfo(),
          ),
          ChangeNotifierProvider(
            create: (context) => StreakProvider(),
          ),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bilsem Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: StartScreen(),
    );
  }
}
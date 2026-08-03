import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Yerel hafıza eklendi

class IAPProvider extends ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  
  // Google Play'de oluşturduğumuz ürün ID'si
  final String _productId = 'bilsem_demo_tam_surum'; 

  bool isPremium = false;
  bool isAvailable = false;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  Future<void> initStoreInfo() async {
    // 1. Önce HIZLICA yerel hafızadan kontrol et (İnternetsiz de çalışır, anında kilidi açar)
    final prefs = await SharedPreferences.getInstance();
    isPremium = prefs.getBool('is_premium_user') ?? false;
    notifyListeners();

    // 2. Google Play'den gelecek mesajları dinlemeye başla
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint("Satın alma dinleyicisi hatası: $error");
    });

    // 3. Mağazaya bağlanabiliyor muyuz kontrol et
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      debugPrint("HATA: Mağazaya ulaşılamıyor.");
      return;
    }

    // 4. Kullanıcı silip yüklemişse diye Google'dan son durumu çek
    await _iap.restorePurchases();
  }

  Future<void> buyPremium() async {
    final ProductDetailsResponse response = await _iap.queryProductDetails({_productId});
    
    if (response.productDetails.isEmpty) {
      debugPrint("HATA: Google Play'de $_productId ID'li ürün bulunamadı!");
      return;
    }
    
    final ProductDetails productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint("Satın alma işlemi beklemede...");
      } 
      else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint("Satın alma hatası/iptali: ${purchaseDetails.error?.message}");
        } 
        else if (purchaseDetails.status == PurchaseStatus.purchased || 
                 purchaseDetails.status == PurchaseStatus.restored) {
          
          if (purchaseDetails.productID == _productId) {
            isPremium = true;
            
            // BAŞARIYLA ALINDI! Bunu hemen telefonun hafızasına kazıyalım.
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('is_premium_user', true);
            
            notifyListeners(); 
            debugPrint("TEBRİKLER: Tam sürüm aktif edildi ve cihaza kaydedildi!");
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
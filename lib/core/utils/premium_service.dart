import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../consts/revenueCat_consts.dart';

class PremiumService {
  static configure() async {
    await Purchases.configure(PurchasesConfiguration(revenueCatApiKey));
  }

  static Future<void> initializeRevenueCat() async {
    // Platform-specific API keys
    String apiKey = '';
    if (Platform.isIOS) {
      apiKey = revenueCatApiKey;
    } else if (Platform.isAndroid) {
      apiKey = revenueCatApiKey;
    } else {
      throw UnsupportedError('Platform not supported');
    }

    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  static Future<bool> isUserPremium() async {
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.entitlements.active.containsKey(revenueCatPremiumEntitlementId);
  }

  static Future<bool> checkLimit({required bool limitReached}) async {
    if (!limitReached) {
      return true;
    }
    if (await isUserPremium()) {
      return true;
    }
    await RevenueCatUI.presentPaywallIfNeeded(revenueCatPremiumEntitlementId);

    return await isUserPremium();
  }

  static openPaywall() async {
    await RevenueCatUI.presentPaywall();
  }
}

import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../consts/revenueCat_consts.dart';

class PremiumService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static bool _premiumOverride = false;

  static Future<void> configure() async {
    await Purchases.configure(PurchasesConfiguration(revenueCatApiKey));
  }

  static Future<void> initializeRevenueCat() async {
    String apiKey = '';

    if (Platform.isIOS) {
      apiKey = revenueCatApiKey;
    } else if (Platform.isAndroid) {
      apiKey = revenueCatApiKey;
    } else {
      throw UnsupportedError('Platform not supported');
    }

    await Purchases.configure(PurchasesConfiguration(apiKey));

    await _loadPremiumOverride();
  }

  static Future<void> _loadPremiumOverride() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      _premiumOverride = false;
      return;
    }

    try {
      final response = await _supabase.from('users').select('premium_override').eq('id', user.id).single();
      _premiumOverride = response['premium_override'] == true;
    } catch (e) {
      _premiumOverride = false;
    }
  }

  // Gibt zurück, ob der aktuelle Benutzer Premium besitzt.
  // Premium ist aktiv, wenn:
  // - RevenueCat ein aktives Premium-Entitlement meldet ODER
  // - premium_override in Supabase auf true gesetzt ist.
  static Future<bool> isUserPremium() async {
    if (_premiumOverride) {
      return true;
    }

    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.entitlements.active.containsKey(revenueCatPremiumEntitlementId);
  }

  static Future<bool> checkLimit({required bool limitReached}) async {
    if (limitReached == false) {
      return true;
    }

    if (await isUserPremium()) {
      return true;
    }

    await RevenueCatUI.presentPaywallIfNeeded(revenueCatPremiumEntitlementId);
    return await isUserPremium();
  }

  static Future<void> openPaywall() async {
    await RevenueCatUI.presentPaywall();
  }
}

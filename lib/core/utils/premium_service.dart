import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../consts/revenueCat_consts.dart';

class PremiumService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static bool _premiumOverride = false;

  // Richtet RevenueCat einmalig beim App-Start ein.
  // Muss in main() mit await vor runApp() aufgerufen werden, damit das SDK
  // fertig konfiguriert ist, bevor irgendwo der Premium-Status abgefragt wird.
  static Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw UnsupportedError('Platform not supported');
    }

    if (await Purchases.isConfigured) {
      return;
    }

    if (kDebugMode) {
      await Purchases.setLogLevel(LogLevel.debug);
    }

    await Purchases.configure(PurchasesConfiguration(revenueCatApiKey));
  }

  // Verknüpft RevenueCat mit dem eingeloggten Supabase-Benutzer, damit Käufe
  // am Haushaltsbuch-Konto hängen und nicht am Gerät.
  // Käufe, die vorher unter der anonymen RevenueCat-ID gemacht wurden, werden
  // dabei von RevenueCat auf den Benutzer übertragen.
  static Future<void> onUserSignedIn(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('RevenueCat logIn fehlgeschlagen: $e');
    }

    await _loadPremiumOverride();
  }

  // Trennt RevenueCat vom abgemeldeten Benutzer, damit ein anderer Benutzer
  // auf demselben Gerät dessen Premium nicht übernimmt.
  static Future<void> onUserSignedOut() async {
    _premiumOverride = false;

    try {
      if (!await Purchases.isAnonymous) {
        await Purchases.logOut();
      }
    } catch (e) {
      debugPrint('RevenueCat logOut fehlgeschlagen: $e');
    }
  }

  static Future<void> _loadPremiumOverride() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      _premiumOverride = false;
      return;
    }

    try {
      final response = await _supabase.from('users').select('premium_override').eq('id', user.id).single();
      _premiumOverride = response['premium_override'];
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

  static Future<bool> checkLimit({required bool limitReached, required Locale locale}) async {
    if (limitReached == false) {
      return true;
    }

    if (await isUserPremium()) {
      return true;
    }

    await Purchases.overridePreferredUILocale(
      locale.toLanguageTag(),
    );

    await RevenueCatUI.presentPaywallIfNeeded(revenueCatPremiumEntitlementId);
    return await isUserPremium();
  }

  static Future<void> openPaywall(Locale locale) async {
    await Purchases.overridePreferredUILocale(
      locale.toLanguageTag(),
    );
    await RevenueCatUI.presentPaywall();
  }
}

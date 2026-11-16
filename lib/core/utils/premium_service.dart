import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/enums/guest_paywall_hint_choice.dart';
import '../consts/revenueCat_consts.dart';
import '../consts/route_consts.dart';
import 'dialogs/show_guest_paywall_hint_dialog.dart';

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

  static Future<bool> checkLimit(BuildContext context, {required bool limitReached}) async {
    if (limitReached == false) {
      return true;
    }

    final Locale locale = Localizations.localeOf(context);

    if (await isUserPremium()) {
      return true;
    }

    if (!context.mounted) {
      return false;
    }

    final bool shouldOpenPaywall = await _confirmPaywallForGuest(context);
    if (!shouldOpenPaywall) {
      return false;
    }

    await Purchases.overridePreferredUILocale(
      locale.toLanguageTag(),
    );

    await RevenueCatUI.presentPaywallIfNeeded(revenueCatPremiumEntitlementId);
    return await isUserPremium();
  }

  static Future<void> openPaywall(BuildContext context) async {
    final Locale locale = Localizations.localeOf(context);

    final bool shouldOpenPaywall = await _confirmPaywallForGuest(context);
    if (!shouldOpenPaywall) {
      return;
    }

    await Purchases.overridePreferredUILocale(
      locale.toLanguageTag(),
    );
    await RevenueCatUI.presentPaywall();
  }

  // Gibt zurück, ob der aktuelle Benutzer ein Gastkonto (anonymer Supabase-Benutzer) hat.
  static bool _isGuestUser() {
    return _supabase.auth.currentUser?.isAnonymous ?? false;
  }

  // Zeigt Gästen vor der Paywall einen Hinweis, dass ihre Daten keinem Konto
  // zugeordnet sind. Gibt true zurück, wenn die Paywall geöffnet werden soll.
  // Wählt der Gast "Konto upgraden", wird die Upgrade-Seite geöffnet und die
  // Paywall bleibt geschlossen.
  static Future<bool> _confirmPaywallForGuest(BuildContext context) async {
    if (!_isGuestUser()) {
      return true;
    }

    final GuestPaywallHintChoice choice = await showGuestPaywallHintDialog(context);

    switch (choice) {
      case GuestPaywallHintChoice.continueAsGuest:
        return true;
      case GuestPaywallHintChoice.upgradeAccount:
        if (context.mounted) {
          Navigator.pushNamed(context, upgradeAccountRoute);
        }
        return false;
      case GuestPaywallHintChoice.cancel:
        return false;
    }
  }
}

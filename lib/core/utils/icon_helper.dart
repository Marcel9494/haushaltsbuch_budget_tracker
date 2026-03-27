import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

IconData getDashboardElementIcon(String name) {
  switch (name) {
    case "piggy-bank":
      return FontAwesomeIcons.piggyBank;
    case "coins":
      return FontAwesomeIcons.coins;
    case "sack_dollar":
      return FontAwesomeIcons.sackDollar;
    case "vault":
      return FontAwesomeIcons.vault;
    case "credit-card":
      return FontAwesomeIcons.creditCard;
    default:
      return FontAwesomeIcons.piggyBank;
  }
}

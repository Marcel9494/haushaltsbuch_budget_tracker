import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

IconData getDashboardElementIcon(String name) {
  switch (name) {
    case 'piggy-bank':
      return FontAwesomeIcons.piggyBank;
    case 'coins':
      return FontAwesomeIcons.coins;
    case 'sack_dollar':
      return FontAwesomeIcons.sackDollar;
    case 'vault':
      return FontAwesomeIcons.vault;
    case 'credit-card':
      return FontAwesomeIcons.creditCard;
    case 'trending_up_rounded':
      return Icons.trending_up_rounded;
    case 'trending_down_rounded':
      return Icons.trending_down_rounded;
    case 'bar_chart_rounded':
      return Icons.bar_chart_rounded;
    case 'savings':
      return Icons.savings_rounded;
    default:
      return FontAwesomeIcons.piggyBank;
  }
}

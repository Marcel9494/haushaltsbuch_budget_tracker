import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

IconData getDashboardElementIcon(String name) {
  switch (name) {
    case "piggyBank":
      return FontAwesomeIcons.piggyBank;
    case "coins":
      return FontAwesomeIcons.coins;
    default:
      return FontAwesomeIcons.piggyBank;
  }
}

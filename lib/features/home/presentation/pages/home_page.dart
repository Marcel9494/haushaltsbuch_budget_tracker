import 'package:flutter/material.dart';

import '../../../../core/consts/route_consts.dart';
import '../../../../l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPageIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 22.0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: t.translate('home')),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: t.translate('bookings')),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_rounded), label: t.translate('accounts')),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: t.translate('budgets')),
          BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: t.translate('goals')),
        ],
        currentIndex: _selectedPageIndex,
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, createBookingRoute),
        backgroundColor: Colors.cyanAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(48.0),
        ),
        child: Icon(
          Icons.add_rounded,
          color: Colors.black87,
          size: 26.0,
        ),
      ),
    );
  }
}

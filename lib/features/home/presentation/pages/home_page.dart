import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/utils/slow_hero_animation.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/presentation/pages/create_booking_page.dart';

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 120.0,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.cyan),
                child: Text(t.translate('app_name')),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home_rounded),
              title: Text(t.translate('home')),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.menu_book_rounded),
              title: Text(t.translate('bookings')),
              onTap: () {},
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.buildingColumns, size: 22.0),
              title: Text(t.translate('accounts')),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet_rounded),
              title: Text(t.translate('budgets')),
              onTap: () {},
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.bullseye),
              title: Text(t.translate('goals')),
              onTap: () {},
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.grip),
              title: Text(t.translate('categories')),
              onTap: () {},
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.solidAddressBook),
              title: Text(t.translate('household_members')),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.stars_rounded),
              title: Text(t.translate('premium')),
              onTap: () {},
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.gear),
              title: Text(t.translate('settings')),
              onTap: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 22.0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: t.translate('home')),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: t.translate('bookings')),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.buildingColumns), label: t.translate('accounts')),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: t.translate('budgets')),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.bullseye), label: t.translate('goals')),
        ],
        currentIndex: _selectedPageIndex,
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'create_booking_fab',
        onPressed: () => Navigator.push(
          context,
          slowHeroRoute(CreateBookingPage()),
        ),
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

import 'package:flutter/material.dart';

import 'customers_screen.dart';
import 'items_screen.dart';
import 'invoices_screen.dart';

/// Root screen with a navigation rail / bottom bar switching between the
/// three management areas: Customers, Items and Invoices.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titles = ['Customers', 'Items', 'Invoices'];
  final _pages = const [
    CustomersScreen(),
    ItemsScreen(),
    InvoicesScreen(),
  ];

  static const _destinations = [
    NavigationDestination(
        icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Customers'),
    NavigationDestination(
        icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Items'),
    NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Invoices'),
  ];

  @override
  Widget build(BuildContext context) {
    // Use a side NavigationRail on wide screens, bottom bar on narrow ones.
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    return Scaffold(
      appBar: AppBar(
        title: Text('Store Admin  ·  ${_titles[_index]}'),
        centerTitle: false,
      ),
      body: isWide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: _destinations
                      .map((d) => NavigationRailDestination(
                            icon: d.icon,
                            selectedIcon: d.selectedIcon,
                            label: Text(d.label),
                          ))
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _pages[_index]),
              ],
            )
          : _pages[_index],
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: _destinations,
            ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/navigation/bottom_navigation.dart';
import '../pages/home/home_page.dart';
import '../pages/packs/packs_page.dart';
import '../pages/decks/decks_page.dart';
import '../pages/stats/stats_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  NavigationTab _currentTab = NavigationTab.freeScan;

  // El mapa de páginas debe estar aquí, en el estado.
  final Map<NavigationTab, Widget> _pages = {
    NavigationTab.freeScan: const HomePage(),
    NavigationTab.packs: const PacksPage(),
    NavigationTab.decks: const DecksPage(),
    NavigationTab.stats: const StatsPage(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentTab]!,
      bottomNavigationBar: CustomBottomNavigation(
        currentTab: _currentTab,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  // Función atómica: Cambio de pestaña
  void _onTabSelected(NavigationTab tab) {
    if (tab != _currentTab) {
      setState(() {
        _currentTab = tab;
      });
    }
  }
}

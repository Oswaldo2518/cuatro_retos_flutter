import 'package:flutter/material.dart';

import 'screens/cats_screen.dart';
import 'screens/crypto_screen.dart';
import 'screens/movies_screen.dart';
import 'screens/weather_screen.dart';
import 'widgets/ui.dart';

void main() => runApp(const CuatroRetosApp());

class CuatroRetosApp extends StatelessWidget {
  const CuatroRetosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: appPurple,
      brightness: Brightness.dark,
      surface: const Color(0xFF1B1E30),
    );
    return MaterialApp(
      title: 'Cuatro Retos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFF171A2B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF171A2B),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF191C2E),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
        ),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int selected = 0;
  static const pages = <Widget>[
    MoviesScreen(), CatsScreen(), WeatherScreen(), CryptoScreen(),
  ];
  static const destinations = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.movie_outlined),
      selectedIcon: Icon(Icons.movie), label: 'Películas'),
    NavigationDestination(icon: Icon(Icons.pets_outlined),
      selectedIcon: Icon(Icons.pets), label: 'Memes'),
    NavigationDestination(icon: Icon(Icons.cloud_outlined),
      selectedIcon: Icon(Icons.cloud), label: 'Clima'),
    NavigationDestination(icon: Icon(Icons.currency_bitcoin_outlined),
      selectedIcon: Icon(Icons.currency_bitcoin), label: 'Cripto'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.auto_awesome_rounded, color: appPurple),
          SizedBox(width: 10),
          Text('CUATRO RETOS', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.1,
          )),
        ]),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Center(child: Text('FLUTTER + APIs', style: TextStyle(
              color: Color(0xFFAAAED0), fontSize: 11, letterSpacing: 1.4,
            ))),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, bounds) {
        final wide = bounds.maxWidth >= 780;
        final content = Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(key: ValueKey(selected), child: pages[selected]),
          ),
        ));
        if (!wide) return content;
        return Row(children: [
          NavigationRail(
            selectedIndex: selected,
            onDestinationSelected: (index) => setState(() => selected = index),
            backgroundColor: const Color(0xFF1D2032),
            labelType: NavigationRailLabelType.all,
            minWidth: 90,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.movie_outlined),
                  selectedIcon: Icon(Icons.movie), label: Text('Películas')),
              NavigationRailDestination(icon: Icon(Icons.pets_outlined),
                  selectedIcon: Icon(Icons.pets), label: Text('Memes')),
              NavigationRailDestination(icon: Icon(Icons.cloud_outlined),
                  selectedIcon: Icon(Icons.cloud), label: Text('Clima')),
              NavigationRailDestination(icon: Icon(Icons.currency_bitcoin_outlined),
                  selectedIcon: Icon(Icons.currency_bitcoin), label: Text('Cripto')),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: content),
        ]);
      }),
      bottomNavigationBar: LayoutBuilder(builder: (context, bounds) =>
        MediaQuery.sizeOf(context).width >= 780
          ? const SizedBox.shrink()
          : NavigationBar(
              height: 70,
              selectedIndex: selected,
              destinations: destinations,
              onDestinationSelected: (index) => setState(() => selected = index),
            ),
      ),
    );
  }
}

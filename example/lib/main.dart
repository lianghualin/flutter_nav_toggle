import 'package:flutter/material.dart';
import 'package:nav_toggle/nav_toggle.dart';

void main() => runApp(const NavToggleExampleApp());

class NavToggleExampleApp extends StatelessWidget {
  const NavToggleExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NavToggle Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0E11),
      ),
      home: const NavToggleDemo(),
    );
  }
}

class NavToggleDemo extends StatefulWidget {
  const NavToggleDemo({super.key});

  @override
  State<NavToggleDemo> createState() => _NavToggleDemoState();
}

class _NavToggleDemoState extends State<NavToggleDemo> {
  String _selectedId = 'home';

  static const _items = [
    NavItem(id: 'home', label: 'Home', icon: Icons.home_outlined),
    NavItem(id: 'explore', label: 'Explore', icon: Icons.explore_outlined),
    NavItem(
        id: 'library', label: 'Library', icon: Icons.library_books_outlined),
    NavItem(id: 'favorites', label: 'Favorites', icon: Icons.favorite_outline),
    NavItem(id: 'settings', label: 'Settings', icon: Icons.settings_outlined),
  ];

  static const _pageColors = {
    'home': Color(0xFF7DF3C0),
    'explore': Color(0xFF5BC8F5),
    'library': Color(0xFFF5A55B),
    'favorites': Color(0xFFF57B7B),
    'settings': Color(0xFFB57BF5),
  };

  @override
  Widget build(BuildContext context) {
    final color = _pageColors[_selectedId] ?? const Color(0xFF7DF3C0);
    final item = _items.firstWhere((i) => i.id == _selectedId);

    return Scaffold(
      body: NavToggleScaffold(
        items: _items,
        initialSelectedId: 'home',
        onItemSelected: (id) => setState(() => _selectedId = id),
        onAddPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add button pressed')),
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 64, color: color),
              const SizedBox(height: 16),
              Text(
                item.label,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Click the toggle button to switch modes',
                style: TextStyle(
                  fontFamily: 'DMMono',
                  fontSize: 14,
                  color: const Color(0xFF5A6070),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

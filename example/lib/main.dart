import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_nav_toggle/flutter_nav_toggle.dart';

void main() => runApp(const NavToggleExampleApp());

class NavToggleExampleApp extends StatelessWidget {
  const NavToggleExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NavToggle Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
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
  final _random = Random();
  late Timer _statusTimer;
  SystemStatus _status = const SystemStatus(
    cpu: 0.42,
    memory: 0.67,
    disk: 0.55,
    warnings: 3,
  );

  @override
  void initState() {
    super.initState();
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        _status = SystemStatus(
          cpu: (_status.cpu + (_random.nextDouble() - 0.5) * 0.1).clamp(0.05, 0.95),
          memory: (_status.memory + (_random.nextDouble() - 0.5) * 0.05).clamp(0.2, 0.95),
          disk: (_status.disk + (_random.nextDouble() - 0.5) * 0.02).clamp(0.3, 0.95),
          warnings: (_status.warnings + (_random.nextBool() ? 1 : -1)).clamp(0, 12),
        );
      });
    });
  }

  @override
  void dispose() {
    _statusTimer.cancel();
    super.dispose();
  }

  static const _items = [
    NavItem(id: 'home', label: 'Home', icon: Icons.home_outlined),
    NavItem(
      id: 'explore',
      label: 'Explore',
      icon: Icons.explore_outlined,
      children: [
        NavItem(id: 'trending', label: 'Trending', icon: Icons.trending_up),
        NavItem(id: 'new', label: 'New', icon: Icons.fiber_new),
        NavItem(id: 'popular', label: 'Popular', icon: Icons.star_outline),
      ],
    ),
    NavItem(
      id: 'library',
      label: 'Library',
      icon: Icons.library_books_outlined,
      children: [
        NavItem(id: 'books', label: 'Books', icon: Icons.book_outlined),
        NavItem(
            id: 'articles', label: 'Articles', icon: Icons.article_outlined),
      ],
    ),
    NavItem(id: 'favorites', label: 'Favorites', icon: Icons.favorite_outline),
    NavItem(id: 'settings', label: 'Settings', icon: Icons.settings_outlined),
  ];

  static const _pageColors = {
    'home': Color(0xFF10B981),
    'explore': Color(0xFF3B82F6),
    'trending': Color(0xFF3B82F6),
    'new': Color(0xFF06B6D4),
    'popular': Color(0xFF8B5CF6),
    'library': Color(0xFFF59E0B),
    'books': Color(0xFFF59E0B),
    'articles': Color(0xFFEA580C),
    'favorites': Color(0xFFEF4444),
    'settings': Color(0xFF8B5CF6),
  };

  /// Find a NavItem by id, searching children too.
  NavItem _findItem(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
      if (item.hasChildren) {
        for (final child in item.children!) {
          if (child.id == id) return child;
        }
      }
    }
    return _items.first;
  }

  @override
  Widget build(BuildContext context) {
    final color = _pageColors[_selectedId] ?? const Color(0xFF7DF3C0);
    final item = _findItem(_selectedId);

    return Scaffold(
      body: NavToggleScaffold(
        items: _items,
        initialSelectedId: 'home',
        systemStatus: _status,
        userInfo: const UserInfo(name: 'John Doe', role: 'Admin'),
        onItemSelected: (id) => setState(() => _selectedId = id),
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
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

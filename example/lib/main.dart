import 'package:flutter/material.dart';
import 'package:nav_toggle/nav_toggle.dart';

void main() => runApp(const NavToggleExampleApp());

class NavToggleExampleApp extends StatelessWidget {
  const NavToggleExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NavToggle Demo',
      theme: ThemeData.dark(useMaterial3: true),
      home: const Scaffold(
        body: Center(child: Text('NavToggle coming soon')),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_nav_toggle/flutter_nav_toggle.dart';

void main() => runApp(const PlaygroundApp());

class PlaygroundApp extends StatelessWidget {
  const PlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NavToggle Playground',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      home: const PlaygroundPage(),
    );
  }
}

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  String _selectedId = 'theme_light';

  // -- Theme --
  int _themeIndex = 0;
  static const _themeEntries = [
    ('Light', NavToggleTheme()),
    ('Dark', NavToggleTheme.dark()),
    ('Ocean', NavToggleTheme.ocean()),
    ('Sunset', NavToggleTheme.sunset()),
  ];

  // -- Layout --
  double _buttonWidth = 200;
  double _buttonHeight = 52;
  double _sidebarWidth = 200;
  double _cornerRadius = 0;
  double _itemRadius = 8;

  // -- Timing --
  int _collapseMs = 420;
  int _expandMs = 550;
  int _morphMs = 450;
  int _shiftMs = 480;

  // -- Status --
  double _cpu = 0.42;
  double _memory = 0.67;
  double _disk = 0.55;
  int _warnings = 3;
  bool _autoUpdate = true;
  Timer? _statusTimer;
  final _random = Random();

  // -- User --
  bool _showUser = true;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _roleCtrl;

  // Playground navigation items
  static const _navItems = [
    NavItem(
      id: 'theme',
      label: 'Theme',
      icon: Icons.palette_outlined,
      children: [
        NavItem(
            id: 'theme_light',
            label: 'Light',
            icon: Icons.light_mode_outlined),
        NavItem(
            id: 'theme_dark',
            label: 'Dark',
            icon: Icons.dark_mode_outlined),
        NavItem(
            id: 'theme_ocean', label: 'Ocean', icon: Icons.waves_outlined),
        NavItem(
            id: 'theme_sunset',
            label: 'Sunset',
            icon: Icons.wb_sunny_outlined),
      ],
    ),
    NavItem(
      id: 'layout',
      label: 'Layout',
      icon: Icons.dashboard_outlined,
      children: [
        NavItem(
            id: 'layout_dims',
            label: 'Dimensions',
            icon: Icons.straighten_outlined),
        NavItem(
            id: 'layout_style',
            label: 'Style',
            icon: Icons.brush_outlined),
      ],
    ),
    NavItem(id: 'timing', label: 'Timing', icon: Icons.timer_outlined),
    NavItem(
      id: 'data',
      label: 'Data',
      icon: Icons.analytics_outlined,
      children: [
        NavItem(
            id: 'data_status', label: 'Status', icon: Icons.speed_outlined),
        NavItem(
            id: 'data_user', label: 'User', icon: Icons.person_outlined),
      ],
    ),
    NavItem(
      id: 'items',
      label: 'Items',
      icon: Icons.list_outlined,
      children: [
        NavItem(
            id: 'items_flat',
            label: '3 Flat',
            icon: Icons.view_list_outlined),
        NavItem(
            id: 'items_mixed',
            label: '5 Mixed',
            icon: Icons.account_tree_outlined),
        NavItem(
            id: 'items_deep',
            label: '8 Deep',
            icon: Icons.segment_outlined),
      ],
    ),
    NavItem(
      id: 'mode',
      label: 'Mode',
      icon: Icons.swap_horiz_outlined,
      children: [
        NavItem(
            id: 'mode_sidebar',
            label: 'Sidebar',
            icon: Icons.view_sidebar_outlined),
        NavItem(
            id: 'mode_rail',
            label: 'Icon Rail',
            icon: Icons.view_compact_outlined),
        NavItem(
            id: 'mode_tabbar', label: 'Tab Bar', icon: Icons.tab_outlined),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: 'Playground');
    _roleCtrl = TextEditingController(text: 'Tester');
    _startAutoUpdate();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  void _startAutoUpdate() {
    _statusTimer?.cancel();
    if (_autoUpdate) {
      _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        setState(() {
          _cpu =
              (_cpu + (_random.nextDouble() - 0.5) * 0.1).clamp(0.05, 0.95);
          _memory =
              (_memory + (_random.nextDouble() - 0.5) * 0.05).clamp(0.2, 0.95);
          _disk =
              (_disk + (_random.nextDouble() - 0.5) * 0.02).clamp(0.3, 0.95);
          _warnings =
              (_warnings + (_random.nextBool() ? 1 : -1)).clamp(0, 12);
        });
      });
    }
  }

  void _onItemSelected(String id) {
    setState(() {
      _selectedId = id;
      switch (id) {
        case 'theme_light':
          _themeIndex = 0;
        case 'theme_dark':
          _themeIndex = 1;
        case 'theme_ocean':
          _themeIndex = 2;
        case 'theme_sunset':
          _themeIndex = 3;
      }
    });
  }

  NavToggleTheme get _theme {
    final (_, base) = _themeEntries[_themeIndex];
    return base.copyWith(
      buttonWidth: _buttonWidth,
      buttonHeight: _buttonHeight,
      sidebarWidth: _sidebarWidth,
      cornerRadius: _cornerRadius,
      itemRadius: _itemRadius,
      collapseDuration: Duration(milliseconds: _collapseMs),
      expandDuration: Duration(milliseconds: _expandMs),
      iconMorphDuration: Duration(milliseconds: _morphMs),
      contentShiftDuration: Duration(milliseconds: _shiftMs),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme;

    return Scaffold(
      backgroundColor: theme.background,
      body: NavToggleScaffold(
        theme: theme,
        items: _navItems,
        initialSelectedId: 'theme_light',
        systemStatus: SystemStatus(
          cpu: _cpu,
          memory: _memory,
          disk: _disk,
          warnings: _warnings,
        ),
        userInfo: _showUser
            ? UserInfo(name: _nameCtrl.text, role: _roleCtrl.text)
            : null,
        onItemSelected: _onItemSelected,
        child: _buildContent(theme),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Content routing
  // ---------------------------------------------------------------------------

  Widget _buildContent(NavToggleTheme theme) {
    return switch (_selectedId) {
      'theme' ||
      'theme_light' ||
      'theme_dark' ||
      'theme_ocean' ||
      'theme_sunset' =>
        _buildThemePage(theme),
      'layout' || 'layout_dims' => _buildDimensionsPage(theme),
      'layout_style' => _buildStylePage(theme),
      'timing' => _buildTimingPage(theme),
      'data' || 'data_status' => _buildStatusPage(theme),
      'data_user' => _buildUserPage(theme),
      'items' ||
      'items_flat' ||
      'items_mixed' ||
      'items_deep' =>
        _buildItemsPage(theme),
      'mode' || 'mode_sidebar' || 'mode_rail' || 'mode_tabbar' => _buildModePage(theme),
      _ => _buildThemePage(theme),
    };
  }

  // ---------------------------------------------------------------------------
  // Theme page
  // ---------------------------------------------------------------------------

  Widget _buildThemePage(NavToggleTheme theme) {
    final (name, _) = _themeEntries[_themeIndex];
    final colors = <(String, Color)>[
      ('background', theme.background),
      ('surface', theme.surface),
      ('border', theme.border),
      ('accent', theme.accent),
      ('accent2', theme.accent2),
      ('text', theme.text),
      ('textDim', theme.textDim),
      ('hoverSurface', theme.hoverSurface),
    ];

    return _PageScaffold(
      theme: theme,
      title: 'Theme: $name',
      subtitle: 'Select a preset from the sidebar to apply it live.',
      children: [
        _Section(
          theme: theme,
          title: 'Color Tokens',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final (label, color) in colors)
                _ColorTile(label: label, color: color, theme: theme),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          theme: theme,
          title: 'Font Families',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                  label: 'Navigation',
                  value: theme.navFontFamily,
                  theme: theme),
              const SizedBox(height: 8),
              _InfoRow(
                  label: 'Monospace',
                  value: theme.monoFontFamily,
                  theme: theme),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          theme: theme,
          title: 'Available Presets',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < _themeEntries.length; i++)
                _PresetChip(
                  label: _themeEntries[i].$1,
                  isActive: i == _themeIndex,
                  accent: _themeEntries[i].$2.accent,
                  theme: theme,
                  onTap: () => setState(() {
                    _themeIndex = i;
                    _selectedId = [
                      'theme_light',
                      'theme_dark',
                      'theme_ocean',
                      'theme_sunset'
                    ][i];
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Dimensions page
  // ---------------------------------------------------------------------------

  Widget _buildDimensionsPage(NavToggleTheme theme) {
    return _PageScaffold(
      theme: theme,
      title: 'Layout Dimensions',
      subtitle: 'Adjust structural dimensions. Changes apply instantly.',
      children: [
        _Section(
          theme: theme,
          title: 'Toggle Button',
          child: Column(
            children: [
              _LabeledSlider(
                label: 'Button Width',
                value: _buttonWidth,
                min: 100,
                max: 300,
                unit: 'px',
                theme: theme,
                onChanged: (v) => setState(() => _buttonWidth = v),
              ),
              const SizedBox(height: 12),
              _LabeledSlider(
                label: 'Button Height',
                value: _buttonHeight,
                min: 36,
                max: 80,
                unit: 'px',
                theme: theme,
                onChanged: (v) => setState(() => _buttonHeight = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          theme: theme,
          title: 'Sidebar',
          child: _LabeledSlider(
            label: 'Sidebar Width',
            value: _sidebarWidth,
            min: 150,
            max: 350,
            unit: 'px',
            theme: theme,
            onChanged: (v) => setState(() => _sidebarWidth = v),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Style page
  // ---------------------------------------------------------------------------

  Widget _buildStylePage(NavToggleTheme theme) {
    return _PageScaffold(
      theme: theme,
      title: 'Style',
      subtitle: 'Adjust border radii for panels and items.',
      children: [
        _Section(
          theme: theme,
          title: 'Border Radii',
          child: Column(
            children: [
              _LabeledSlider(
                label: 'Corner Radius',
                value: _cornerRadius,
                min: 0,
                max: 24,
                unit: 'px',
                theme: theme,
                onChanged: (v) => setState(() => _cornerRadius = v),
              ),
              const SizedBox(height: 12),
              _LabeledSlider(
                label: 'Item Radius',
                value: _itemRadius,
                min: 0,
                max: 16,
                unit: 'px',
                theme: theme,
                onChanged: (v) => setState(() => _itemRadius = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Timing page
  // ---------------------------------------------------------------------------

  Widget _buildTimingPage(NavToggleTheme theme) {
    return _PageScaffold(
      theme: theme,
      title: 'Animation Timing',
      subtitle: 'Adjust durations for the toggle animation phases.',
      children: [
        _Section(
          theme: theme,
          title: 'Phase Durations',
          child: Column(
            children: [
              _LabeledSlider(
                label: 'Collapse',
                value: _collapseMs.toDouble(),
                min: 50,
                max: 1200,
                unit: 'ms',
                divisions: 23,
                theme: theme,
                onChanged: (v) => setState(() => _collapseMs = v.round()),
              ),
              const SizedBox(height: 12),
              _LabeledSlider(
                label: 'Expand',
                value: _expandMs.toDouble(),
                min: 50,
                max: 1200,
                unit: 'ms',
                divisions: 23,
                theme: theme,
                onChanged: (v) => setState(() => _expandMs = v.round()),
              ),
              const SizedBox(height: 12),
              _LabeledSlider(
                label: 'Icon Morph',
                value: _morphMs.toDouble(),
                min: 50,
                max: 1200,
                unit: 'ms',
                divisions: 23,
                theme: theme,
                onChanged: (v) => setState(() => _morphMs = v.round()),
              ),
              const SizedBox(height: 12),
              _LabeledSlider(
                label: 'Content Shift',
                value: _shiftMs.toDouble(),
                min: 50,
                max: 1200,
                unit: 'ms',
                divisions: 23,
                theme: theme,
                onChanged: (v) => setState(() => _shiftMs = v.round()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          theme: theme,
          title: 'Tip',
          child: Text(
            'Click the toggle button (top-left) to see your timing changes in action.',
            style: TextStyle(
              fontFamily: theme.monoFontFamily,
              fontSize: 12,
              color: theme.textDim,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Status page
  // ---------------------------------------------------------------------------

  Widget _buildStatusPage(NavToggleTheme theme) {
    return _PageScaffold(
      theme: theme,
      title: 'System Status',
      subtitle: 'Adjust status values shown in sidebar and tab bar.',
      children: [
        _Section(
          theme: theme,
          title: 'Metrics',
          child: Column(
            children: [
              _LabeledSlider(
                label: 'CPU',
                value: _cpu,
                min: 0,
                max: 1,
                unit: '%',
                displayValue: '${(_cpu * 100).round()}%',
                theme: theme,
                onChanged: (v) => setState(() => _cpu = v),
              ),
              const SizedBox(height: 12),
              _LabeledSlider(
                label: 'Memory',
                value: _memory,
                min: 0,
                max: 1,
                unit: '%',
                displayValue: '${(_memory * 100).round()}%',
                theme: theme,
                onChanged: (v) => setState(() => _memory = v),
              ),
              const SizedBox(height: 12),
              _LabeledSlider(
                label: 'Disk',
                value: _disk,
                min: 0,
                max: 1,
                unit: '%',
                displayValue: '${(_disk * 100).round()}%',
                theme: theme,
                onChanged: (v) => setState(() => _disk = v),
              ),
              const SizedBox(height: 12),
              _LabeledSlider(
                label: 'Warnings',
                value: _warnings.toDouble(),
                min: 0,
                max: 12,
                divisions: 12,
                unit: '',
                displayValue: '$_warnings',
                theme: theme,
                onChanged: (v) => setState(() => _warnings = v.round()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          theme: theme,
          title: 'Auto-Update',
          child: Row(
            children: [
              SizedBox(
                height: 24,
                width: 40,
                child: Switch(
                  value: _autoUpdate,
                  activeTrackColor: theme.accent,
                  onChanged: (v) {
                    setState(() => _autoUpdate = v);
                    _startAutoUpdate();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _autoUpdate
                    ? 'Randomizing every 2 seconds'
                    : 'Manual control only',
                style: TextStyle(
                  fontFamily: theme.monoFontFamily,
                  fontSize: 12,
                  color: theme.textDim,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Section(
          theme: theme,
          title: 'Color Thresholds',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ThresholdRow(
                  label: '< 60%',
                  color: const Color(0xFF10B981),
                  desc: 'Green (normal)',
                  theme: theme),
              const SizedBox(height: 6),
              _ThresholdRow(
                  label: '60-80%',
                  color: const Color(0xFFF59E0B),
                  desc: 'Amber (warning)',
                  theme: theme),
              const SizedBox(height: 6),
              _ThresholdRow(
                  label: '>= 80%',
                  color: const Color(0xFFEF4444),
                  desc: 'Red (critical)',
                  theme: theme),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // User page
  // ---------------------------------------------------------------------------

  Widget _buildUserPage(NavToggleTheme theme) {
    return _PageScaffold(
      theme: theme,
      title: 'User Info',
      subtitle: 'Configure the user panel shown in the sidebar.',
      children: [
        _Section(
          theme: theme,
          title: 'Visibility',
          child: Row(
            children: [
              SizedBox(
                height: 24,
                width: 40,
                child: Switch(
                  value: _showUser,
                  activeTrackColor: theme.accent,
                  onChanged: (v) => setState(() => _showUser = v),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _showUser ? 'Shown in sidebar' : 'Hidden',
                style: TextStyle(
                  fontFamily: theme.monoFontFamily,
                  fontSize: 12,
                  color: theme.textDim,
                ),
              ),
            ],
          ),
        ),
        if (_showUser) ...[
          const SizedBox(height: 16),
          _Section(
            theme: theme,
            title: 'Details',
            child: Column(
              children: [
                _ThemedTextField(
                  label: 'Name',
                  controller: _nameCtrl,
                  theme: theme,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                _ThemedTextField(
                  label: 'Role',
                  controller: _roleCtrl,
                  theme: theme,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            theme: theme,
            title: 'Preview',
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      UserInfo(name: _nameCtrl.text, role: _roleCtrl.text)
                          .initials,
                      style: TextStyle(
                        fontFamily: theme.navFontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: theme.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameCtrl.text,
                      style: TextStyle(
                        fontFamily: theme.navFontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: theme.text,
                      ),
                    ),
                    Text(
                      _roleCtrl.text,
                      style: TextStyle(
                        fontFamily: theme.navFontFamily,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: theme.textDim,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Items page
  // ---------------------------------------------------------------------------

  Widget _buildItemsPage(NavToggleTheme theme) {
    return _PageScaffold(
      theme: theme,
      title: 'Nav Items',
      subtitle:
          'NavItem supports flat and hierarchical structures with children.',
      children: [
        _Section(
          theme: theme,
          title: '3 Flat',
          child: _ItemTree(
            theme: theme,
            items: const [
              ('Dashboard', null),
              ('Analytics', null),
              ('Settings', null),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          theme: theme,
          title: '5 Mixed (hierarchical)',
          child: _ItemTree(
            theme: theme,
            items: const [
              ('Dashboard', null),
              ('Projects', ['Active', 'Archived']),
              ('Team', null),
              ('Reports', ['Monthly', 'Annual']),
              ('Settings', null),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          theme: theme,
          title: '8 Deep (complex)',
          child: _ItemTree(
            theme: theme,
            items: const [
              ('Home', null),
              ('Products', ['Electronics', 'Clothing', 'Books']),
              ('Customers', ['Enterprise', 'SMB']),
              ('Orders', ['Pending', 'Shipped', 'Returned']),
              ('Analytics', ['Revenue', 'Traffic', 'Conversion']),
              ('Marketing', null),
              ('Support', ['Tickets', 'Chat', 'FAQ']),
              ('Settings', null),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          theme: theme,
          title: 'Current Playground',
          child: Text(
            'This playground uses 6 hierarchical items (Theme, Layout, Timing, '
            'Data, Items, Mode) to demonstrate expand/collapse in sidebar and '
            'dropdown menus in tab bar.',
            style: TextStyle(
              fontFamily: theme.monoFontFamily,
              fontSize: 12,
              color: theme.textDim,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Mode page
  // ---------------------------------------------------------------------------

  Widget _buildModePage(NavToggleTheme theme) {
    return _PageScaffold(
      theme: theme,
      title: 'Navigation Mode',
      subtitle: 'Three modes: sidebar, icon rail, and tab bar.',
      children: [
        _Section(
          theme: theme,
          title: 'Sidebar Mode',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Full vertical panel on the left side.',
                style: TextStyle(
                  fontFamily: theme.monoFontFamily,
                  fontSize: 12,
                  color: theme.text,
                ),
              ),
              const SizedBox(height: 8),
              _BulletList(theme: theme, items: const [
                'Left button zone: collapse to icon rail',
                'Right button zone: toggle to tab bar',
                'Expand/collapse children with SizeTransition',
                'Status panel with progress bars at bottom',
              ]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          theme: theme,
          title: 'Icon Rail Mode',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Narrow vertical strip with icons only.',
                style: TextStyle(
                  fontFamily: theme.monoFontFamily,
                  fontSize: 12,
                  color: theme.text,
                ),
              ),
              const SizedBox(height: 8),
              _BulletList(theme: theme, items: const [
                'Click button to expand back to sidebar',
                'Hover items for tooltip labels',
                'Parent items open flyout popups to the right',
                'Status dots and user avatar at bottom',
              ]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          theme: theme,
          title: 'Tab Bar Mode',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Horizontal bar across the top.',
                style: TextStyle(
                  fontFamily: theme.monoFontFamily,
                  fontSize: 12,
                  color: theme.text,
                ),
              ),
              const SizedBox(height: 8),
              _BulletList(theme: theme, items: const [
                'Overlay dropdown for hierarchical items',
                'Compact status chips (C/M/D/W)',
                'User avatar chip',
                'Scroll arrows when items overflow',
              ]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          theme: theme,
          title: 'Transitions',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available transitions:',
                style: TextStyle(
                  fontFamily: theme.monoFontFamily,
                  fontSize: 12,
                  color: theme.text,
                ),
              ),
              const SizedBox(height: 8),
              _BulletList(theme: theme, items: const [
                'Sidebar -> Icon Rail: smooth width morph (left button zone)',
                'Icon Rail -> Sidebar: smooth width morph (button click)',
                'Sidebar -> Tab Bar: collapse/expand animation (right button zone)',
                'Tab Bar -> Sidebar: collapse/expand animation (button click)',
              ]),
              const SizedBox(height: 12),
              Text(
                'No direct Icon Rail <-> Tab Bar transition.',
                style: TextStyle(
                  fontFamily: theme.monoFontFamily,
                  fontSize: 12,
                  color: theme.textDim,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Reusable layout widgets
// =============================================================================

class _PageScaffold extends StatelessWidget {
  const _PageScaffold({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final NavToggleTheme theme;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: theme.navFontFamily,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              color: theme.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: theme.monoFontFamily,
              fontSize: 13,
              color: theme.textDim,
            ),
          ),
          const SizedBox(height: 28),
          ...children,
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.theme,
    required this.title,
    required this.child,
  });

  final NavToggleTheme theme;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: theme.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontFamily: theme.navFontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: theme.textDim,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// =============================================================================
// Slider
// =============================================================================

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.theme,
    required this.onChanged,
    this.unit = '',
    this.displayValue,
    this.divisions,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final String? displayValue;
  final int? divisions;
  final NavToggleTheme theme;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final display =
        displayValue ?? '${value.round()}${unit.isNotEmpty ? ' $unit' : ''}';

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: theme.navFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: theme.text,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: theme.accent,
              inactiveTrackColor: theme.border,
              thumbColor: theme.accent,
              overlayColor: theme.accent.withValues(alpha: 0.1),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 60,
          child: Text(
            display,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: theme.monoFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: theme.accent,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Color tile
// =============================================================================

class _ColorTile extends StatelessWidget {
  const _ColorTile({
    required this.label,
    required this.color,
    required this.theme,
  });

  final String label;
  final Color color;
  final NavToggleTheme theme;

  String get _hex {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    final a = color.a;
    if (a < 1.0) {
      return '#$r$g$b ${(a * 100).round()}%'.toUpperCase();
    }
    return '#$r$g$b'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.border, width: 1),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: theme.navFontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: theme.text,
                  ),
                ),
                Text(
                  _hex,
                  style: TextStyle(
                    fontFamily: theme.monoFontFamily,
                    fontSize: 10,
                    color: theme.textDim,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Preset chip
// =============================================================================

class _PresetChip extends StatefulWidget {
  const _PresetChip({
    required this.label,
    required this.isActive,
    required this.accent,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color accent;
  final NavToggleTheme theme;
  final VoidCallback onTap;

  @override
  State<_PresetChip> createState() => _PresetChipState();
}

class _PresetChipState extends State<_PresetChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isActive
        ? widget.accent.withValues(alpha: 0.15)
        : _hovering
            ? widget.theme.hoverSurface
            : const Color(0x00000000);
    final textColor =
        widget.isActive ? widget.accent : widget.theme.textDim;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: widget.isActive
                ? Border.all(color: widget.accent.withValues(alpha: 0.3))
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: widget.theme.navFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Info row
// =============================================================================

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final NavToggleTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: theme.navFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: theme.textDim,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: theme.monoFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: theme.text,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Themed text field
// =============================================================================

class _ThemedTextField extends StatelessWidget {
  const _ThemedTextField({
    required this.label,
    required this.controller,
    required this.theme,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final NavToggleTheme theme;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: theme.navFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: theme.textDim,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: TextStyle(
              fontFamily: theme.monoFontFamily,
              fontSize: 13,
              color: theme.text,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: theme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.accent, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Threshold row (for status color legend)
// =============================================================================

class _ThresholdRow extends StatelessWidget {
  const _ThresholdRow({
    required this.label,
    required this.color,
    required this.desc,
    required this.theme,
  });

  final String label;
  final Color color;
  final String desc;
  final NavToggleTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: theme.monoFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: theme.text,
            ),
          ),
        ),
        Text(
          desc,
          style: TextStyle(
            fontFamily: theme.monoFontFamily,
            fontSize: 12,
            color: theme.textDim,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Item tree (for items page)
// =============================================================================

class _ItemTree extends StatelessWidget {
  const _ItemTree({
    required this.theme,
    required this.items,
  });

  final NavToggleTheme theme;
  final List<(String, List<String>?)> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, children) in items) ...[
          Text(
            children != null ? '$name  (+${children.length})' : name,
            style: TextStyle(
              fontFamily: theme.monoFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: theme.text,
            ),
          ),
          if (children != null)
            for (final child in children)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  '\u251C $child',
                  style: TextStyle(
                    fontFamily: theme.monoFontFamily,
                    fontSize: 12,
                    color: theme.textDim,
                  ),
                ),
              ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }
}

// =============================================================================
// Bullet list
// =============================================================================

class _BulletList extends StatelessWidget {
  const _BulletList({required this.theme, required this.items});

  final NavToggleTheme theme;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u2022  ',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.accent,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontFamily: theme.monoFontFamily,
                      fontSize: 12,
                      color: theme.textDim,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

import 'dart:ui';

/// System status data for the sidebar status panel.
///
/// All usage values are fractions in the range 0.0–1.0.
class SystemStatus {
  const SystemStatus({
    this.cpu = 0.0,
    this.memory = 0.0,
    this.disk = 0.0,
    this.warnings = 0,
    this.time,
    this.userName,
    this.onWarningTap,
  });

  /// CPU usage (0.0–1.0).
  final double cpu;

  /// Memory usage (0.0–1.0).
  final double memory;

  /// Disk usage (0.0–1.0).
  final double disk;

  /// Number of active warnings.
  final int warnings;

  /// Optional time string to display (e.g. '14:32:05').
  final String? time;

  /// Optional user name displayed in the status panel.
  final String? userName;

  /// Callback when the warning row is tapped.
  final VoidCallback? onWarningTap;

  /// Creates a copy with the given fields replaced.
  SystemStatus copyWith({
    double? cpu,
    double? memory,
    double? disk,
    int? warnings,
    String? time,
    String? userName,
    VoidCallback? onWarningTap,
  }) {
    return SystemStatus(
      cpu: cpu ?? this.cpu,
      memory: memory ?? this.memory,
      disk: disk ?? this.disk,
      warnings: warnings ?? this.warnings,
      time: time ?? this.time,
      userName: userName ?? this.userName,
      onWarningTap: onWarningTap ?? this.onWarningTap,
    );
  }
}

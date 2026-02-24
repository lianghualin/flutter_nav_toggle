/// System status data for the sidebar status panel.
///
/// All usage values are fractions in the range 0.0–1.0.
class SystemStatus {
  const SystemStatus({
    this.cpu = 0.0,
    this.memory = 0.0,
    this.disk = 0.0,
    this.warnings = 0,
  });

  /// CPU usage (0.0–1.0).
  final double cpu;

  /// Memory usage (0.0–1.0).
  final double memory;

  /// Disk usage (0.0–1.0).
  final double disk;

  /// Number of active warnings.
  final int warnings;
}

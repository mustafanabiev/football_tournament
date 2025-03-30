class TimeRange {
  final int start;
  final int end;
  const TimeRange({required this.start, required this.end});

  bool contains(int time) => time >= start && time <= end;

  String get display => "${_formatTime(start)} - ${_formatTime(end)}";

  String _formatTime(int minutes) {
    final int h = minutes ~/ 60;
    final int m = minutes % 60;
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
  }
}

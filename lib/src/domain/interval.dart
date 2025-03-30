class Interval {
  final int start;
  final int end;
  Interval(this.start, this.end);

  String get display {
    final int hStart = start ~/ 60;
    final int mStart = start % 60;
    final int hEnd = end ~/ 60;
    final int mEnd = end % 60;
    return "${hStart.toString().padLeft(2, '0')}:${mStart.toString().padLeft(2, '0')} - "
        "${hEnd.toString().padLeft(2, '0')}:${mEnd.toString().padLeft(2, '0')}";
  }
}

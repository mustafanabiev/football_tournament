import 'package:flutter/material.dart';
import 'time_range.dart';
import 'team.dart';

class MatchModel {
  final String id;
  final Team team1;
  final Team team2;
  TimeOfDay? startTime;
  final int round;

  MatchModel({
    required this.id,
    required this.team1,
    required this.team2,
    this.startTime,
    required this.round,
  });

  /// Пересечение предпочтительных интервалов обеих команд
  TimeRange? get validTimeRange {
    final int t1Start = team1.preferredStart.hour * 60 + team1.preferredStart.minute;
    final int t1End = team1.preferredEnd.hour * 60 + team1.preferredEnd.minute;
    final int t2Start = team2.preferredStart.hour * 60 + team2.preferredStart.minute;
    final int t2End = team2.preferredEnd.hour * 60 + team2.preferredEnd.minute;
    final int start = t1Start > t2Start ? t1Start : t2Start;
    final int end = t1End < t2End ? t1End : t2End;
    return start <= end ? TimeRange(start: start, end: end) : null;
  }

  /// Длительность матча: 70 минут
  int get duration => 70;
}

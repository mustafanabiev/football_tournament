import 'package:flutter/material.dart';

class MatchModel {
  final int round;
  final String team1;
  final String team2;
  TimeOfDay? startTime;

  MatchModel({
    required this.round,
    required this.team1,
    required this.team2,
    this.startTime,
  });

  MatchModel copyWith({TimeOfDay? startTime}) {
    return MatchModel(
      round: round,
      team1: team1,
      team2: team2,
      startTime: startTime ?? this.startTime,
    );
  }
}

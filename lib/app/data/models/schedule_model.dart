import 'package:flutter/material.dart';
import 'package:football_tournament/app/data/models/match_model.dart';

class ScheduleModel {
  final String tournamentName;
  final TimeOfDay tournamentStart;
  final TimeOfDay tournamentEnd;
  final List<MatchModel> matches;
  ScheduleModel({
    required this.tournamentName,
    required this.tournamentStart,
    required this.tournamentEnd,
    required this.matches,
  });

  ScheduleModel copyWith({
    String? tournamentName,
    TimeOfDay? tournamentStart,
    TimeOfDay? tournamentEnd,
    List<MatchModel>? matches,
  }) {
    return ScheduleModel(
      tournamentName: tournamentName ?? this.tournamentName,
      tournamentStart: tournamentStart ?? this.tournamentStart,
      tournamentEnd: tournamentEnd ?? this.tournamentEnd,
      matches: matches ?? this.matches,
    );
  }
}

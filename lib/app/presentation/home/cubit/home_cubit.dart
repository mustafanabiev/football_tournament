import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:football_tournament/app/data/models/match_model.dart';
import 'package:football_tournament/app/data/models/schedule_model.dart';
import 'package:football_tournament/app/data/models/time_range_model.dart';

part 'home_cubit_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit()
      : super(
          ScheduleState(
            scheduleModel: ScheduleModel(
              tournamentName: "Мой турнир",
              tournamentStart: const TimeOfDay(hour: 13, minute: 0),
              tournamentEnd: const TimeOfDay(hour: 21, minute: 0),
              matches: [
                // Тур 1
                MatchModel(round: 1, team1: 'Team A', team2: 'Team B'),
                MatchModel(round: 1, team1: 'Team C', team2: 'Team D'),
                MatchModel(round: 1, team1: 'Team E', team2: 'Team F'),
                // Тур 2
                MatchModel(round: 2, team1: 'Team A', team2: 'Team C'),
                MatchModel(round: 2, team1: 'Team B', team2: 'Team E'),
                MatchModel(round: 2, team1: 'Team D', team2: 'Team F'),
              ],
            ),
            teamPreferences: teamPreferences,
          ),
        );

  static const int slotDuration = 70;

  void updateTournamentName(String name) {
    emit(state.copyWith(scheduleModel: state.scheduleModel.copyWith(tournamentName: name)));
  }

  void updateTournamentStart(TimeOfDay newTime) {
    emit(state.copyWith(scheduleModel: state.scheduleModel.copyWith(tournamentStart: newTime)));
  }

  void updateTournamentEnd(TimeOfDay newTime) {
    emit(state.copyWith(scheduleModel: state.scheduleModel.copyWith(tournamentEnd: newTime)));
  }

  void updateMatchStartTime(int index, TimeOfDay newTime) {
    final updatedMatches = List<MatchModel>.from(state.scheduleModel.matches);
    updatedMatches[index] = updatedMatches[index].copyWith(startTime: newTime);
    emit(state.copyWith(scheduleModel: state.scheduleModel.copyWith(matches: updatedMatches)));
  }
}

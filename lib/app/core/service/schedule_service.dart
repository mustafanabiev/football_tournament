import 'package:flutter/material.dart';
import 'package:football_tournament/app/data/models/schedule_model.dart';
import 'package:football_tournament/app/data/models/time_range_model.dart';

class ScheduleService {
  static int timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  static String minutesToTimeStr(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return "$h:$m";
  }

  static List<TimeOfDay> generatePresetTimes({
    required int availableStart,
    required int availableEnd,
    required int slotDuration,
    int step = 10,
  }) {
    List<TimeOfDay> times = [];
    final latestStart = availableEnd - slotDuration;
    for (int minutes = availableStart; minutes <= latestStart; minutes += step) {
      int hour = minutes ~/ 60;
      int minute = minutes % 60;
      times.add(TimeOfDay(hour: hour, minute: minute));
    }
    return times;
  }

  static List<String> validateSchedule({
    required ScheduleModel schedule,
    required Map<String, TimeRange> teamPreferences,
    required int slotDuration,
    required int playingDuration,
  }) {
    List<String> errors = [];
    final availableStart = timeToMinutes(schedule.tournamentStart);
    final availableEnd = timeToMinutes(schedule.tournamentEnd);

    for (int i = 0; i < schedule.matches.length; i++) {
      final matchA = schedule.matches[i];
      if (matchA.startTime == null) {
        errors.add("В матче ${matchA.team1} vs ${matchA.team2} не выбрано время старта.");
        continue;
      }
      final startA = timeToMinutes(matchA.startTime!);
      final endSlotA = startA + slotDuration;
      if (startA < availableStart || endSlotA > availableEnd) {
        errors.add("Матч ${matchA.team1} vs ${matchA.team2} начинается в ${minutesToTimeStr(startA)}, "
            "но не укладывается в рамки турнира (${minutesToTimeStr(availableStart)}–${minutesToTimeStr(availableEnd)}).");
      }
      for (var team in [matchA.team1, matchA.team2]) {
        if (teamPreferences.containsKey(team)) {
          final pref = teamPreferences[team]!;
          if (startA < pref.start || endSlotA > pref.end) {
            errors.add(
                "Команда $team указала предпочтения ${minutesToTimeStr(pref.start)}–${minutesToTimeStr(pref.end)}, "
                "но матч ${matchA.team1} vs ${matchA.team2} (старт в ${minutesToTimeStr(startA)}) не умещается в этот интервал.");
          }
        }
      }
    }

    for (int i = 0; i < schedule.matches.length; i++) {
      final matchA = schedule.matches[i];
      if (matchA.startTime == null) continue;
      final startA = timeToMinutes(matchA.startTime!);
      final endA = startA + playingDuration;
      for (int j = i + 1; j < schedule.matches.length; j++) {
        final matchB = schedule.matches[j];
        if (matchB.startTime == null) continue;
        final startB = timeToMinutes(matchB.startTime!);
        final endB = startB + playingDuration;
        bool isOverlap = (startA < endB) && (startB < endA);
        if (isOverlap) {
          errors.add("Матчи ${matchA.team1} vs ${matchA.team2} и ${matchB.team1} vs ${matchB.team2} "
              "пересекаются по игровому времени.");
        }
        final sameTeam = (matchA.team1 == matchB.team1) ||
            (matchA.team1 == matchB.team2) ||
            (matchA.team2 == matchB.team1) ||
            (matchA.team2 == matchB.team2);
        if (sameTeam) {
          final earlier = (startA < startB) ? startA : startB;
          final later = (startA < startB) ? startB : startA;
          if (later < earlier + slotDuration) {
            errors.add("Команда, играющая в матчах (${matchA.team1} vs ${matchA.team2}) и "
                "(${matchB.team1} vs ${matchB.team2}), не имеет достаточного перерыва.");
          }
        }
      }
    }

    return errors;
  }
}

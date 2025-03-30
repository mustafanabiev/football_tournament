import 'package:flutter/material.dart';
import '../domain/match_model.dart';
import '../domain/interval.dart' as interval;
import '../domain/time_range.dart';

class SchedulerService {
  static const int stadiumStart = 13 * 60; // 13:00
  static const int stadiumEnd = 21 * 60; // 21:00

  /// Вычисляет свободные интервалы на основе уже запланированных матчей
  List<interval.Interval> computeFreeIntervals(List<MatchModel> scheduledMatches) {
    List<interval.Interval> freeIntervals = [];
    int current = stadiumStart;
    for (var match in scheduledMatches) {
      final int start = match.startTime!.hour * 60 + match.startTime!.minute;
      if (start > current) {
        freeIntervals.add(interval.Interval(current, start));
      }
      final int end = start + match.duration;
      if (end > current) current = end;
    }
    if (current < stadiumEnd) {
      freeIntervals.add(interval.Interval(current, stadiumEnd));
    }
    return freeIntervals;
  }

  /// Автоматически распределяет матчи туров 3 и 4
  void autoSchedule({
    required List<MatchModel> matches,
    required BuildContext context,
  }) {
    // Собираем запланированные матчи (фиксированные и ранее авто-распределённые)
    List<MatchModel> scheduledMatches = matches.where((m) => m.startTime != null).toList();
    scheduledMatches.sort((a, b) {
      final int aStart = a.startTime!.hour * 60 + a.startTime!.minute;
      final int bStart = b.startTime!.hour * 60 + b.startTime!.minute;
      return aStart.compareTo(bStart);
    });
    final List<interval.Interval> freeIntervals = computeFreeIntervals(scheduledMatches);

    // Отображаем свободные интервалы в диалоговом окне
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Свободные интервалы"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: freeIntervals.map((i) => Text(i.display)).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            )
          ],
        ),
      );
    });

    // Фильтруем матчи туров 3 и 4 и сортируем их
    List<MatchModel> autoMatches = matches.where((m) => m.round >= 3).toList();
    autoMatches.sort((a, b) {
      if (a.round != b.round) return a.round.compareTo(b.round);
      return a.id.compareTo(b.id);
    });

    // Распределяем каждый матч
    for (var match in autoMatches) {
      final TimeRange? validRange = match.validTimeRange;
      if (validRange == null) {
        match.startTime = null;
        continue;
      }
      int candidate = validRange.start;
      // Для каждой команды учитываем окончание предыдущих матчей + 1 минута зазор
      for (var team in [match.team1, match.team2]) {
        int teamLatestFinish = stadiumStart;
        for (var m in matches.where((m) =>
            (m.team1.name == team.name || m.team2.name == team.name) && m.startTime != null && m.round < match.round)) {
          final int finish = m.startTime!.hour * 60 + m.startTime!.minute + m.duration;
          if (finish > teamLatestFinish) teamLatestFinish = finish;
        }
        candidate = candidate < (teamLatestFinish + 1) ? (teamLatestFinish + 1) : candidate;
      }
      if (candidate < validRange.start) candidate = validRange.start;

      bool scheduled = false;
      // Ищем свободный интервал, куда матч укладывается
      for (int i = 0; i < freeIntervals.length; i++) {
        final interval.Interval currentInterval = freeIntervals[i];
        final int possibleStart = candidate < currentInterval.start ? currentInterval.start : candidate;
        if (possibleStart + match.duration <= currentInterval.end &&
            possibleStart + match.duration <= validRange.end &&
            possibleStart + match.duration <= stadiumEnd) {
          match.startTime = TimeOfDay(hour: possibleStart ~/ 60, minute: possibleStart % 60);
          scheduled = true;
          final int usedEnd = possibleStart + match.duration;
          freeIntervals.removeAt(i);
          if (currentInterval.start < possibleStart) {
            freeIntervals.insert(i, interval.Interval(currentInterval.start, possibleStart));
            i++;
          }
          if (usedEnd < currentInterval.end) {
            freeIntervals.insert(i, interval.Interval(usedEnd, currentInterval.end));
          }
          break;
        }
      }
      if (!scheduled) match.startTime = null;
    }
  }
}

import 'package:flutter/material.dart';
import '../domain/match_model.dart';
import '../domain/team.dart';
import '../application/scheduler_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late final SchedulerService schedulerService;
  late List<MatchModel> matches;
  late final Team teamA, teamB, teamC, teamD, teamE, teamF;

  @override
  void initState() {
    super.initState();
    schedulerService = SchedulerService();

    teamA = const Team(
      name: "Team A",
      preferredStart: TimeOfDay(hour: 14, minute: 0),
      preferredEnd: TimeOfDay(hour: 18, minute: 0),
    );
    teamB = const Team(
      name: "Team B",
      preferredStart: TimeOfDay(hour: 13, minute: 0),
      preferredEnd: TimeOfDay(hour: 16, minute: 0),
    );
    teamC = const Team(
      name: "Team C",
      preferredStart: TimeOfDay(hour: 15, minute: 0),
      preferredEnd: TimeOfDay(hour: 20, minute: 0),
    );
    teamD = const Team(
      name: "Team D",
      preferredStart: TimeOfDay(hour: 14, minute: 0),
      preferredEnd: TimeOfDay(hour: 19, minute: 0),
    );
    teamE = const Team(
      name: "Team E",
      preferredStart: TimeOfDay(hour: 13, minute: 30),
      preferredEnd: TimeOfDay(hour: 17, minute: 30),
    );
    teamF = const Team(
      name: "Team F",
      preferredStart: TimeOfDay(hour: 16, minute: 0),
      preferredEnd: TimeOfDay(hour: 21, minute: 0),
    );

    // Расписание: туры 1 и 2 фиксированные, туры 3 и 4 – для авто распределения
    matches = [
      // Тур 1
      MatchModel(
        id: "M1",
        team1: teamA,
        team2: teamB,
        round: 1,
        startTime: const TimeOfDay(hour: 13, minute: 0),
      ),
      MatchModel(
        id: "M2",
        team1: teamC,
        team2: teamD,
        round: 1,
        startTime: const TimeOfDay(hour: 14, minute: 10),
      ),
      MatchModel(
        id: "M3",
        team1: teamE,
        team2: teamF,
        round: 1,
        startTime: const TimeOfDay(hour: 15, minute: 20),
      ),
      // Тур 2
      MatchModel(
        id: "M4",
        team1: teamA,
        team2: teamC,
        round: 2,
        startTime: const TimeOfDay(hour: 16, minute: 30),
      ),
      MatchModel(
        id: "M5",
        team1: teamB,
        team2: teamE,
        round: 2,
        startTime: const TimeOfDay(hour: 17, minute: 40),
      ),
      MatchModel(
        id: "M6",
        team1: teamD,
        team2: teamF,
        round: 2,
        startTime: const TimeOfDay(hour: 18, minute: 50),
      ),
      // Тур 3 (не распределён)
      MatchModel(id: "M7", team1: teamA, team2: teamD, round: 3),
      MatchModel(id: "M8", team1: teamB, team2: teamF, round: 3),
      MatchModel(id: "M9", team1: teamC, team2: teamE, round: 3),
      // Тур 4 (не распределён)
      MatchModel(id: "M10", team1: teamA, team2: teamE, round: 4),
      MatchModel(id: "M11", team1: teamB, team2: teamD, round: 4),
      MatchModel(id: "M12", team1: teamC, team2: teamF, round: 4),
    ];
  }

  void _onAutoSchedulePressed() {
    schedulerService.autoSchedule(matches: matches, context: context);
    setState(() {});
  }

  Future<void> _onPickTime(MatchModel match) async {
    final initialTime = match.startTime ?? const TimeOfDay(hour: 13, minute: 0);
    final pickedTime = await showTimePicker(context: context, initialTime: initialTime);
    if (pickedTime != null) {
      setState(() {
        match.startTime = pickedTime;
      });
    }
  }

  List<String> _validateSchedule() {
    const int stadiumStart = 13 * 60;
    const int stadiumEnd = 21 * 60;
    List<String> errors = [];
    for (var match in matches) {
      if (match.startTime == null) {
        errors.add("Матч ${match.id} (тур ${match.round}) не имеет выбранного времени.");
      } else {
        final int start = match.startTime!.hour * 60 + match.startTime!.minute;
        if (start < stadiumStart || start + match.duration > stadiumEnd) {
          errors.add("Матч ${match.id} (тур ${match.round}) вне рабочего слота стадиона.");
        }
        final validRange = match.validTimeRange;
        if (validRange != null && !validRange.contains(start)) {
          errors.add(
              "Время матча ${match.id} (тур ${match.round}) вне предпочтительного диапазона ${validRange.display}.");
        }
      }
    }
    final Map<String, List<MatchModel>> teamMatches = {};
    for (var match in matches) {
      for (var team in [match.team1, match.team2]) {
        teamMatches.putIfAbsent(team.name, () => []).add(match);
      }
    }
    teamMatches.forEach((team, teamMatchList) {
      teamMatchList.sort((a, b) {
        final int aTime = a.startTime != null ? a.startTime!.hour * 60 + a.startTime!.minute : 0;
        final int bTime = b.startTime != null ? b.startTime!.hour * 60 + b.startTime!.minute : 0;
        return aTime.compareTo(bTime);
      });
      for (int i = 0; i < teamMatchList.length - 1; i++) {
        final int start1 = teamMatchList[i].startTime != null
            ? teamMatchList[i].startTime!.hour * 60 + teamMatchList[i].startTime!.minute
            : 0;
        final int start2 = teamMatchList[i + 1].startTime != null
            ? teamMatchList[i + 1].startTime!.hour * 60 + teamMatchList[i + 1].startTime!.minute
            : 0;
        if (start2 - start1 < teamMatchList[i].duration + 1) {
          errors.add("Команда $team имеет подряд матчи: ${teamMatchList[i].id} и ${teamMatchList[i + 1].id}.");
        }
      }
    });
    return errors;
  }

  @override
  Widget build(BuildContext context) {
    final errors = _validateSchedule();
    final Map<int, List<MatchModel>> rounds = {};
    for (var match in matches) {
      rounds.putIfAbsent(match.round, () => []).add(match);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Расписание матчей"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: rounds.entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text("Тур ${entry.key}"),
                    children: entry.value.map((match) {
                      return ListTile(
                        title: Text("Матч ${match.id}: ${match.team1.name} vs ${match.team2.name}"),
                        subtitle: Text(
                          "Время: ${match.startTime != null ? match.startTime!.format(context) : 'не выбрано'}\n"
                          "Допустимый интервал: ${match.validTimeRange?.display ?? 'Нет'}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () => _onPickTime(match),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
          if (errors.isNotEmpty)
            Container(
              width: double.infinity,
              color: Colors.red[100],
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: errors.map((e) => Text(e, style: const TextStyle(color: Colors.red))).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _onAutoSchedulePressed,
              child: const Text("Автоматически распределить туры 3 и 4"),
            ),
          ),
        ],
      ),
    );
  }
}

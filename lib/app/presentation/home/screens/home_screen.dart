import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String tournamentName;
  final TimeOfDay tournamentStart;
  final TimeOfDay tournamentEnd;

  const HomeScreen({
    super.key,
    required this.tournamentName,
    required this.tournamentStart,
    required this.tournamentEnd,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Модель диапазона времени
class TimeRange {
  final int start;
  final int end;
  const TimeRange({required this.start, required this.end});
}

class _HomeScreenState extends State<HomeScreen> {
  // Преобразование TimeOfDay в минуты с полуночи
  int _timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  // Преобразование минут в строку формата HH:MM (24-часовой формат)
  String _minutesToTimeStr(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return "$h:$m";
  }

  // Слот матча: 70 минут (55 мин игровое время + 15 мин перерыв)
  static const int slotDuration = 70;

  // Для примера статический список матчей
  final List<Map<String, dynamic>> matches = const [
    // Тур 1
    {"round": 1, "team1": "Team A", "team2": "Team B"},
    {"round": 1, "team1": "Team C", "team2": "Team D"},
    {"round": 1, "team1": "Team E", "team2": "Team F"},
    // Тур 2
    {"round": 2, "team1": "Team A", "team2": "Team C"},
    {"round": 2, "team1": "Team B", "team2": "Team E"},
    {"round": 2, "team1": "Team D", "team2": "Team F"},
  ];

  // Для хранения выбранного времени для каждого матча
  late List<TimeOfDay?> selectedTimes;

  @override
  void initState() {
    super.initState();
    selectedTimes = List.filled(matches.length, null);
  }

  // Предпочтения команд
  final Map<String, TimeRange> teamPreferences = {
    'Team A': TimeRange(start: 14 * 60, end: 18 * 60), // 14:00–18:00
    'Team B': TimeRange(start: 13 * 60, end: 16 * 60), // 13:00–16:00
    'Team C': TimeRange(start: 15 * 60, end: 20 * 60), // 15:00–20:00
    'Team D': TimeRange(start: 14 * 60, end: 19 * 60), // 14:00–19:00
    'Team E': TimeRange(start: 13 * 60 + 30, end: 17 * 60 + 30), // 13:30–17:30
    'Team F': TimeRange(start: 16 * 60, end: 21 * 60), // 16:00–21:00
  };

  // Генерация списка временных слотов с шагом 10 минут,
  // чтобы весь 70-минутный слот укладывался в доступное время турнира
  List<TimeOfDay> _generatePresetTimes() {
    final availableStart = _timeToMinutes(widget.tournamentStart);
    final availableEnd = _timeToMinutes(widget.tournamentEnd);
    List<TimeOfDay> times = [];
    final latestStart = availableEnd - slotDuration;
    for (int m = availableStart; m <= latestStart; m += 10) {
      times.add(TimeOfDay(hour: m ~/ 60, minute: m % 60));
    }
    return times;
  }

  /// Проверяем, что матч [index] удовлетворяет всем условиям:
  /// 1) Выбрано время (не null)
  /// 2) Слот (70 мин) укладывается в доступное время
  /// 3) Полностью попадает в предпочтения команд
  /// 4) Нет «двух матчей подряд» для той же команды (разница в стартах >= 2 * slotDuration)
  bool isMatchValid(int index) {
    final selected = selectedTimes[index];
    if (selected == null) return false;

    final start = _timeToMinutes(selected);
    final endSlot = start + slotDuration;

    // 1) Проверка доступности стадиона
    final availableStart = _timeToMinutes(widget.tournamentStart);
    final availableEnd = _timeToMinutes(widget.tournamentEnd);
    if (start < availableStart || endSlot > availableEnd) {
      return false;
    }

    // 2) Предпочтения команд
    final match = matches[index];
    final team1 = match['team1'] as String;
    final team2 = match['team2'] as String;
    if (!checkTeamPreference(team1, start, endSlot)) return false;
    if (!checkTeamPreference(team2, start, endSlot)) return false;

    // 3) Проверка "не играть подряд" (должен быть хотя бы один слот между играми)
    //    Для этого ищем любые другие матчи, где есть team1 или team2, и проверяем:
    //    разница во времени начала >= 2 * slotDuration
    for (int i = 0; i < matches.length; i++) {
      if (i == index) continue;
      final otherMatch = matches[i];
      final otherTeam1 = otherMatch['team1'] as String;
      final otherTeam2 = otherMatch['team2'] as String;
      // Если нет пересечения по командам, не проверяем
      if (!(team1 == otherTeam1 || team1 == otherTeam2 || team2 == otherTeam1 || team2 == otherTeam2)) {
        continue;
      }
      // Если у другого матча не выбрано время, пропускаем
      final otherSelected = selectedTimes[i];
      if (otherSelected == null) continue;

      final otherStart = _timeToMinutes(otherSelected);

      // Условие "разница >= 2 * slotDuration" означает, что
      // если start < otherStart, то otherStart >= start + 140
      // ИЛИ если otherStart < start, то start >= otherStart + 140
      final diff = (start - otherStart).abs(); // модуль разницы
      if (diff < 2 * slotDuration) {
        // Значит эти матчи идут слишком близко
        return false;
      }
    }

    // Если всё в порядке
    return true;
  }

  /// Проверяем, что [start..endSlot] укладывается в предпочтения команды [team].
  bool checkTeamPreference(String team, int start, int endSlot) {
    if (!teamPreferences.containsKey(team)) return true; // нет данных, пропускаем
    final pref = teamPreferences[team]!;
    if (start < pref.start || endSlot > pref.end) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final availableStart = _timeToMinutes(widget.tournamentStart);
    final availableEnd = _timeToMinutes(widget.tournamentEnd);
    final presetTimes = _generatePresetTimes();

    return Scaffold(
      appBar: AppBar(
        title: Text("Расписание турнира: ${widget.tournamentName}"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            "Доступно с: ${_minutesToTimeStr(availableStart)} до: ${_minutesToTimeStr(availableEnd)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Список матчей
          ...matches.asMap().entries.map((entry) {
            final index = entry.key;
            final match = entry.value;
            final team1 = match['team1'] as String;
            final team2 = match['team2'] as String;

            // Определяем цвет карточки
            final cardColor = isMatchValid(index) ? Colors.green[300] : Colors.red[300];

            // Строки с предпочтениями команд
            final team1Pref = teamPreferences.containsKey(team1)
                ? "${_minutesToTimeStr(teamPreferences[team1]!.start)} – ${_minutesToTimeStr(teamPreferences[team1]!.end)}"
                : "Нет данных";
            final team2Pref = teamPreferences.containsKey(team2)
                ? "${_minutesToTimeStr(teamPreferences[team2]!.start)} – ${_minutesToTimeStr(teamPreferences[team2]!.end)}"
                : "Нет данных";

            return Card(
              color: cardColor,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Тур ${match['round']}: $team1 vs $team2",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text("$team1 может играть: $team1Pref"),
                    Text("$team2 может играть: $team2Pref"),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text("Время: "),
                        DropdownButton<TimeOfDay>(
                          hint: const Text("Выберите время"),
                          value: selectedTimes[index],
                          items: presetTimes.map((time) {
                            final minutes = _timeToMinutes(time);
                            return DropdownMenuItem<TimeOfDay>(
                              value: time,
                              child: Text(_minutesToTimeStr(minutes)),
                            );
                          }).toList(),
                          onChanged: (newTime) {
                            setState(() {
                              selectedTimes[index] = newTime;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

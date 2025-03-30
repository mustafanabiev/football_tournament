import 'package:flutter/material.dart';
import 'package:football_tournament/src/presentation/schedule_screen.dart';

void main() {
  runApp(const FootballSchedulerApp());
}

class FootballSchedulerApp extends StatelessWidget {
  const FootballSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Scheduler',
      home: const ScheduleScreen(),
    );
  }
}

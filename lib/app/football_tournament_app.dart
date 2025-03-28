import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:football_tournament/app/presentation/home/cubit/home_cubit.dart';
import 'package:football_tournament/app/presentation/splash/splash_screen.dart';

class FootballTournamentApp extends StatelessWidget {
  const FootballTournamentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScheduleCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Расписание турнира',
        theme: ThemeData.dark(),
        home: SplashScreen(),
      ),
    );
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'home_cubit.dart';

class ScheduleState {
  final ScheduleModel scheduleModel;
  final Map<String, TimeRange> teamPreferences;

  const ScheduleState({
    required this.scheduleModel,
    required this.teamPreferences,
  });

  ScheduleState copyWith({
    ScheduleModel? scheduleModel,
    Map<String, TimeRange>? teamPreferences,
  }) {
    return ScheduleState(
      scheduleModel: scheduleModel ?? this.scheduleModel,
      teamPreferences: teamPreferences ?? this.teamPreferences,
    );
  }
}

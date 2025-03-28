import 'package:flutter/material.dart';
import 'package:football_tournament/app/core/service/schedule_Service.dart';

class TimeRange {
  final int start;
  final int end;
  TimeRange({required this.start, required this.end});
}

final Map<String, TimeRange> teamPreferences = {
  'Team A': TimeRange(
      start: ScheduleService.timeToMinutes(const TimeOfDay(hour: 14, minute: 0)),
      end: ScheduleService.timeToMinutes(const TimeOfDay(hour: 18, minute: 0))),
  'Team B': TimeRange(
      start: ScheduleService.timeToMinutes(const TimeOfDay(hour: 13, minute: 0)),
      end: ScheduleService.timeToMinutes(const TimeOfDay(hour: 16, minute: 0))),
  'Team C': TimeRange(
      start: ScheduleService.timeToMinutes(const TimeOfDay(hour: 15, minute: 0)),
      end: ScheduleService.timeToMinutes(const TimeOfDay(hour: 20, minute: 0))),
  'Team D': TimeRange(
      start: ScheduleService.timeToMinutes(const TimeOfDay(hour: 14, minute: 0)),
      end: ScheduleService.timeToMinutes(const TimeOfDay(hour: 19, minute: 0))),
  'Team E': TimeRange(
      start: ScheduleService.timeToMinutes(const TimeOfDay(hour: 13, minute: 30)),
      end: ScheduleService.timeToMinutes(const TimeOfDay(hour: 17, minute: 30))),
  'Team F': TimeRange(
      start: ScheduleService.timeToMinutes(const TimeOfDay(hour: 16, minute: 0)),
      end: ScheduleService.timeToMinutes(const TimeOfDay(hour: 21, minute: 0))),
};

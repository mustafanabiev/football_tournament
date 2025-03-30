import 'package:flutter/material.dart';

class Team {
  final String name;
  final TimeOfDay preferredStart;
  final TimeOfDay preferredEnd;

  const Team({
    required this.name,
    required this.preferredStart,
    required this.preferredEnd,
  });
}

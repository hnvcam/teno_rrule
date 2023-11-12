import 'package:equatable/equatable.dart';
import 'package:teno_rrule/src/teno_rrule_base.dart';

class WeekDay extends Equatable {
  static const monday = WeekDay._(DateTime.monday);
  static const tuesday = WeekDay._(DateTime.tuesday);
  static const wednesday = WeekDay._(DateTime.wednesday);
  static const thursday = WeekDay._(DateTime.thursday);
  static const friday = WeekDay._(DateTime.friday);
  static const saturday = WeekDay._(DateTime.saturday);
  static const sunday = WeekDay._(DateTime.sunday);
  static const _weekDayStringValues = [
    (day: DateTime.monday, value: 'MO'),
    (day: DateTime.tuesday, value: 'TU'),
    (day: DateTime.wednesday, value: 'WE'),
    (day: DateTime.thursday, value: 'TH'),
    (day: DateTime.friday, value: 'FR'),
    (day: DateTime.saturday, value: 'SA'),
    (day: DateTime.sunday, value: 'SU'),
  ];

  final int? occurrence;
  final int weekDay;

  const WeekDay._(this.weekDay, [this.occurrence]);

  factory WeekDay(int weekDay, [int? occurrence]) {
    if (weekDay < DateTime.monday || weekDay > DateTime.sunday) {
      throw UnsupportedError('Invalid weekday value $weekDay');
    }
    return WeekDay._(weekDay, occurrence);
  }

  factory WeekDay.fromString(String value) {
    if (value.length == 2) {
      return WeekDay._(_weekDayStringValues
          .firstWhere((element) => element.value == value)
          .day);
    }
    final regex = RegExp(r'^([+-]?\d{1,2})([A-Z]{2})$');
    final match = regex.firstMatch(value);
    if (match == null || match.groupCount < 3) {
      throw ParseException('Invalid weekday string', value);
    }
    return WeekDay._(
        _weekDayStringValues
            .firstWhere((element) => element.value == match[2])
            .day,
        int.parse(match[1]!));
  }

  WeekDay withOccurrence(int? occurrence) {
    return WeekDay._(weekDay, occurrence ?? this.occurrence);
  }

  @override
  bool operator ==(Object other) {
    if (other is int) {
      return occurrence == null && weekDay == other;
    }
    return super == other;
  }

  @override
  List<Object?> get props => [occurrence, weekDay];

  @override
  String toString() {
    final weekString = _weekDayStringValues
        .firstWhere((element) => element.day == weekDay)
        .value;
    return occurrence == null ? weekString : '$occurrence$weekString';
  }
}

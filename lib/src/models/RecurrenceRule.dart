import 'package:equatable/equatable.dart';

import '../teno_rrule_base.dart';
import 'Frequency.dart';
import 'WeekDay.dart';

class RecurrenceRule extends Equatable {
  final Frequency frequency;
  final DateTime startDate;

  /// ignore timezoneOffset value of startDate
  final bool isLocal;
  final DateTime? endDate;
  final int interval;
  final int? count;
  final Set<int>? bySeconds;
  final Set<int>? byMinutes;
  final Set<int>? byHours;
  final Set<int>? byMonths;
  final Set<WeekDay>? byWeekDays;
  final Set<int>? byMonthDays;
  final Set<int>? byYearDays;
  final Set<int>? byWeeks;
  final Set<int>? bySetPositions;
  final int? weekStart;

  RecurrenceRule(
      {required this.frequency,
      required this.startDate,
      this.isLocal = true,
      this.endDate,
      this.interval = 1,
      this.count,
      this.bySeconds,
      this.byMinutes,
      this.byHours,
      this.byMonths,
      this.byWeekDays,
      this.byMonthDays,
      this.byYearDays,
      this.byWeeks,
      this.bySetPositions,
      this.weekStart}) {
    // The INTERVAL rule part contains a positive integer representing at
    //       which intervals the recurrence rule repeats.
    assert(interval > 0);
    assert(endDate == null || count == null,
        'UNTIL and COUNT MUST NOT occur in the same RRULE');
    assert(weekStart == null ||
        (weekStart! >= DateTime.monday && weekStart! <= DateTime.sunday));
    // The value of the UNTIL rule part MUST have the same
    //       value type as the "DTSTART" property.  Furthermore, if the
    //       "DTSTART" property is specified as a date with local time, then
    //       the UNTIL rule part MUST also be specified as a date with local
    //       time.  If the "DTSTART" property is specified as a date with UTC
    //       time or a date with local time and time zone reference, then the
    //       UNTIL rule part MUST be specified as a date with UTC time.
    assert(isLocal != true || endDate == null || endDate!.isUtc,
        'required UTC value for non-local rrule');

    //    +----------+--------+--------+-------+-------+------+-------+------+
    //    |          |SECONDLY|MINUTELY|HOURLY |DAILY  |WEEKLY|MONTHLY|YEARLY|
    //    +----------+--------+--------+-------+-------+------+-------+------+
    //    |BYWEEKNO  |N/A     |N/A     |N/A    |N/A    |N/A   |N/A    |Expand|
    //    +----------+--------+--------+-------+-------+------+-------+------+
    assert(frequency == Frequency.yearly || byWeeks == null);

    //    +----------+--------+--------+-------+-------+------+-------+------+
    //    |          |SECONDLY|MINUTELY|HOURLY |DAILY  |WEEKLY|MONTHLY|YEARLY|
    //    +----------+--------+--------+-------+-------+------+-------+------+
    //    |BYYEARDAY |Limit   |Limit   |Limit  |N/A    |N/A   |N/A    |Expand|
    //    +----------+--------+--------+-------+-------+------+-------+------+
    assert(byYearDays == null ||
        (frequency != Frequency.daily &&
            frequency != Frequency.weekly &&
            frequency != Frequency.monthly));

    //    +----------+--------+--------+-------+-------+------+-------+------+
    //    |          |SECONDLY|MINUTELY|HOURLY |DAILY  |WEEKLY|MONTHLY|YEARLY|
    //    +----------+--------+--------+-------+-------+------+-------+------+
    //    |BYMONTHDAY|Limit   |Limit   |Limit  |Limit  |N/A   |Expand |Expand|
    //    +----------+--------+--------+-------+-------+------+-------+------+
    assert(byMonthDays == null || frequency != Frequency.weekly);
  }

  RecurrenceRule copyWith(
      {Frequency? frequency,
      DateTime? startDate,
      bool? isLocal,
      DateTime? endDate,
      int? interval,
      int? count,
      Set<int>? bySeconds,
      Set<int>? byMinutes,
      Set<int>? byHours,
      Set<int>? byMonths,
      Set<WeekDay>? byWeekDays,
      Set<int>? byMonthDays,
      Set<int>? byYearDays,
      Set<int>? byWeeks,
      Set<int>? bySetPositions,
      int? weekStart}) {
    return RecurrenceRule(
        frequency: frequency ?? this.frequency,
        startDate: startDate ?? this.startDate,
        isLocal: isLocal ?? this.isLocal,
        endDate: endDate ?? this.endDate,
        interval: interval ?? this.interval,
        count: count ?? this.count,
        bySeconds: bySeconds ?? this.bySeconds,
        byMinutes: byMinutes ?? this.byMinutes,
        byHours: byHours ?? this.byHours,
        byMonths: byMonths ?? this.byMonths,
        byWeekDays: byWeekDays ?? this.byWeekDays,
        byMonthDays: byMonthDays ?? this.byMonthDays,
        byYearDays: byYearDays ?? this.byYearDays,
        byWeeks: byWeeks ?? this.byWeeks,
        bySetPositions: bySetPositions ?? this.bySetPositions,
        weekStart: weekStart ?? this.weekStart);
  }

  @override
  String toString() {
    return rfc5545String;
  }

  static RecurrenceRule? from(String rfc5545String) {
    return parseRFC5545String(rfc5545String);
  }

  @override
  List<Object?> get props => [
        frequency,
        startDate,
        isLocal,
        endDate,
        interval,
        count,
        bySeconds,
        byMinutes,
        byHours,
        byMonths,
        byWeekDays,
        byMonthDays,
        byYearDays,
        byWeeks,
        bySetPositions,
        weekStart
      ];
}

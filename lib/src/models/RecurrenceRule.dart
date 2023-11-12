import 'package:equatable/equatable.dart';
import 'package:teno_rrule/src/conversions.dart';
import 'package:teno_rrule/src/models/Frequency.dart';

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
  final Set<int>? byWeekDays;
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
    assert(endDate == null || count == null,
        'UNTIL and COUNT MUST NOT occur in the same RRULE');
    assert(weekStart == null ||
        (weekStart! >= DateTime.monday && weekStart! <= DateTime.sunday));
    assert(isLocal != true || endDate == null || endDate!.isUtc,
        'required UTC value for non-local rrule');
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
      Set<int>? byWeekDays,
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
    return rfc2445String;
  }

  static RecurrenceRule? from(String rfc2445String) {
    return parseRFC2445String(rfc2445String);
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

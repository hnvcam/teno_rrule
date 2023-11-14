import 'package:teno_datetime/teno_datetime.dart';

import '../models/Frequency.dart';
import '../models/RecurrenceRule.dart';
import '../utils.dart';
import 'SimpleConditionalHandler.dart';

/// +----------+--------+--------+-------+-------+------+-------+------+
/// |          |SECONDLY|MINUTELY|HOURLY |DAILY  |WEEKLY|MONTHLY|YEARLY|
/// +----------+--------+--------+-------+-------+------+-------+------+
/// |BYWEEKNO  |N/A     |N/A     |N/A    |N/A    |N/A   |N/A    |Expand|
/// +----------+--------+--------+-------+-------+------+-------+------+
class ByWeeksHandler extends SimpleConditionalHandler {
  @override
  bool canProcess(RecurrenceRule rrule) {
    return isNotEmpty(rrule.byWeeks);
  }

  @override
  Set<Frequency> get expandOn => {Frequency.yearly};

  @override
  Set<Frequency> get limitOn => {};

  @override
  List<DateTime> expand(List<DateTime> instances, RecurrenceRule rrule) {
    final effectiveWeekStart = rrule.weekStart ?? firstDayOfWeek;
    return instances.flatMap((element) {
      return rrule.byWeeks!.map((week) {
        final firstDayOfFirstWeek = _findFirstWeek(element, effectiveWeekStart);
        final dateOfWeekNo = firstDayOfFirstWeek.addUnit(days: 7 * (week - 1));
        final localFirstDayOfWeekNo =
            dateOfWeekNo.startOf(Unit.week, effectiveWeekStart);
        return cloneWith(element,
            month: localFirstDayOfWeekNo.month, day: localFirstDayOfWeekNo.day);
      });
    }).toList();
  }

  @override
  List<DateTime> limit(List<DateTime> instances, RecurrenceRule rrule) {
    throw UnsupportedError('Unsupported limit on FREQ ${rrule.frequency}');
  }

  /// Week number one of the calendar year
  ///       is the first week that contains at least four (4) days in that
  ///       calendar year.
  DateTime _findFirstWeek(DateTime element, int weekStart) {
    final januaryFirst = cloneWith(element, month: 1, day: 1);
    final localEndOfWeek = januaryFirst.endOf(Unit.week, weekStart);
    final tzEndOfWeek = cloneWith(januaryFirst, day: localEndOfWeek.day);
    // we need to count the first day as well.
    if (tzEndOfWeek.diff(januaryFirst, unit: Unit.day) >= 3) {
      return januaryFirst;
    }
    // then the next week
    return tzEndOfWeek.addUnit(days: 1);
  }
}

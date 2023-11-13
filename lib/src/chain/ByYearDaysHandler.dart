import 'package:teno_datetime/teno_datetime.dart';

import '../models/Frequency.dart';
import '../models/RecurrenceRule.dart';
import '../utils.dart';
import 'SimpleConditionalHandler.dart';

/// +----------+--------+--------+-------+-------+------+-------+------+
/// |          |SECONDLY|MINUTELY|HOURLY |DAILY  |WEEKLY|MONTHLY|YEARLY|
/// +----------+--------+--------+-------+-------+------+-------+------+
/// |BYYEARDAY |Limit   |Limit   |Limit  |N/A    |N/A   |N/A    |Expand|
/// +----------+--------+--------+-------+-------+------+-------+------+
class ByYearDaysHandler extends SimpleConditionalHandler {
  @override
  bool canProcess(RecurrenceRule rrule) {
    return isNotEmpty(rrule.byYearDays);
  }

  @override
  Set<Frequency> get expandOn => {Frequency.yearly};

  @override
  Set<Frequency> get limitOn =>
      {Frequency.secondly, Frequency.minutely, Frequency.hourly};

  @override
  List<DateTime> expand(List<DateTime> instances, RecurrenceRule rrule) {
    return instances.flatMap((element) {
      final startOfYear = cloneWith(element, month: 1, day: 1);
      final lastYearDay = element.isLeapYear ? 366 : 365;
      return rrule.byYearDays!.map((yearDay) {
        assert(
            yearDay != 0 && yearDay.abs() <= 366, 'Invalid year day $yearDay');
        if (yearDay > 0) {
          return startOfYear.addUnit(days: yearDay - 1);
        }
        // because yearDay == -1 means lastYearDay
        return startOfYear.addUnit(days: lastYearDay + yearDay + 1);
      });
    }).toList();
  }

  @override
  List<DateTime> limit(List<DateTime> instances, RecurrenceRule rrule) {
    return instances.where((element) {
      final startOfYear = cloneWith(element, month: 1, day: 1);
      final lastYearDay = element.isLeapYear ? 366 : 365;
      for (int yearDay in rrule.byYearDays!) {
        assert(
            yearDay != 0 && yearDay.abs() <= 366, 'Invalid year day $yearDay');
        final elementYearDay = element.diff(startOfYear, unit: Unit.day) + 1;
        if (yearDay > 0 && elementYearDay == yearDay) {
          return true;
        }
        if (yearDay < 0 && elementYearDay == yearDay + lastYearDay + 1) {
          return true;
        }
      }
      return false;
    }).toList();
  }
}

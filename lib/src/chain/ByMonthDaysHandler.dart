import 'package:teno_datetime/teno_datetime.dart';

import '../models/Frequency.dart';
import '../models/RecurrenceRule.dart';
import '../utils.dart';
import 'SimpleConditionalHandler.dart';

/// +----------+--------+--------+-------+-------+------+-------+------+
/// |          |SECONDLY|MINUTELY|HOURLY |DAILY  |WEEKLY|MONTHLY|YEARLY|
/// +----------+--------+--------+-------+-------+------+-------+------+
/// |BYMONTHDAY|Limit   |Limit   |Limit  |Limit  |N/A   |Expand |Expand|
/// +----------+--------+--------+-------+-------+------+-------+------+
class ByMonthDaysHandler extends SimpleConditionalHandler {
  @override
  bool canProcess(RecurrenceRule rrule) {
    return isNotEmpty(rrule.byMonthDays);
  }

  @override
  Set<Frequency> get expandOn => {Frequency.monthly, Frequency.yearly};

  @override
  Set<Frequency> get limitOn => {
        Frequency.secondly,
        Frequency.minutely,
        Frequency.hourly,
        Frequency.daily
      };

  @override
  List<DateTime> expand(List<DateTime> instances, RecurrenceRule rrule) {
    return instances.flatMap((element) {
      int lastMonthDay = element.endOf(Unit.month).day;
      final List<DateTime> result = [];
      for (int monthDay in rrule.byMonthDays!) {
        // invalid day, skip
        if (monthDay.abs() > lastMonthDay) {
          continue;
        }
        if (monthDay > 0) {
          result.add(cloneWith(element, day: monthDay));
        } else {
          // because monthDay = -1, means lastMonthDay.
          result.add(cloneWith(element, day: monthDay + lastMonthDay + 1));
        }
      }
      return result;
    }).toList();
  }

  @override
  List<DateTime> limit(List<DateTime> instances, RecurrenceRule rrule) {
    return instances.where((element) {
      int lastMonthDay = element.endOf(Unit.month).day;
      for (int monthDay in rrule.byMonthDays!) {
        assert(monthDay != 0 && monthDay.abs() <= 31,
            'Invalid monthDay value $monthDay');
        if (monthDay > 0 && monthDay == element.day) {
          return true;
        }
        if (monthDay < 0 && (monthDay + lastMonthDay + 1) == element.day) {
          return true;
        }
      }
      return false;
    }).toList();
  }
}

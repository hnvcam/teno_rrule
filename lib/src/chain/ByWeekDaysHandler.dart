import 'package:teno_datetime/teno_datetime.dart';
import 'package:teno_rrule/src/models/WeekDay.dart';

import '../models/Frequency.dart';
import '../models/RecurrenceRule.dart';
import '../utils.dart';
import 'BaseHandler.dart';

/// +----------+--------+--------+-------+-------+------+-------+------+
/// |          |SECONDLY|MINUTELY|HOURLY |DAILY  |WEEKLY|MONTHLY|YEARLY|
/// +----------+--------+--------+-------+-------+------+-------+------+
/// |BYDAY     |Limit   |Limit   |Limit  |Limit  |Expand|Note 1 |Note 2|
/// +----------+--------+--------+-------+-------+------+-------+------+
/// Note 1:  Limit if BYMONTHDAY is present; otherwise, special expand
///          for MONTHLY.
///
/// Note 2:  Limit if BYYEARDAY or BYMONTHDAY is present; otherwise,
///          special expand for WEEKLY if BYWEEKNO present; otherwise,
///          special expand for MONTHLY if BYMONTH present; otherwise,
///          special expand for YEARLY.
class ByWeekDaysHandler extends BaseHandler {
  @override
  bool canProcess(RecurrenceRule rrule) {
    return isNotEmpty(rrule.byWeekDays);
  }

  @override
  bool canExpand(RecurrenceRule rrule) {
    if (rrule.frequency == Frequency.weekly) {
      return true;
    }
    if (isEmpty(rrule.byMonthDays) && rrule.frequency == Frequency.monthly) {
      return true;
    }
    if ((isEmpty(rrule.byYearDays) && isEmpty(rrule.byMonthDays)) &&
        ((rrule.frequency == Frequency.weekly && isNotEmpty(rrule.byWeeks)) ||
            (rrule.frequency == Frequency.monthly &&
                isNotEmpty(rrule.byMonths)) ||
            rrule.frequency == Frequency.yearly)) {
      return true;
    }
    return false;
  }

  @override
  bool canLimit(RecurrenceRule rrule) {
    if ([
      Frequency.secondly,
      Frequency.minutely,
      Frequency.hourly,
      Frequency.daily
    ].contains(rrule.frequency)) {
      return true;
    }
    if (rrule.frequency == Frequency.monthly && isNotEmpty(rrule.byMonthDays)) {
      return true;
    }
    if (rrule.frequency == Frequency.yearly &&
        (isNotEmpty(rrule.byYearDays) || isNotEmpty(rrule.byMonthDays))) {
      return true;
    }
    return false;
  }

  @override
  List<DateTime> expand(List<DateTime> instances, RecurrenceRule rrule) {
    return instances.flatMap((element) {
      final weekDays = rrule.byWeekDays!.map((e) => e.weekDay);
      // special applied with byMonths
      if (isNotEmpty(rrule.byMonths)) {
        List<DateTime> result = [];
        for (int monthDay = element.day;
            monthDay <= element.endOf(Unit.month).day;
            monthDay++) {
          final candidate = cloneWith(element, day: monthDay);
          if (weekDays.contains(candidate.weekday)) {
            result.add(candidate);
          }
        }
        return result;
      }
      return [element];
    }).toList();
  }

  Iterable<DateTime> _allWeekDaysOnSameWeek(
      DateTime element, RecurrenceRule rrule) {
    final effectiveWeekStart = rrule.weekStart ?? firstDayOfWeek;
    return rrule.byWeekDays!.map((day) {
      if (element.weekday >= effectiveWeekStart) {
        return element.addUnit(
            days: element.weekday - effectiveWeekStart + day.weekDay);
      } else if (day.weekDay >= effectiveWeekStart) {
        return element.addUnit(
            days: effectiveWeekStart - day.weekDay - element.weekday);
      } else {
        return element.addUnit(days: day.weekDay - element.weekday);
      }
    }).where((generatedElement) => generatedElement.isSameOrAfterUnit(element));
  }

  @override
  List<DateTime> limit(List<DateTime> instances, RecurrenceRule rrule) {
    return instances.where((element) {
      for (WeekDay day in rrule.byWeekDays!) {
        if (day.weekDay == element.weekday) {
          return true;
        }
      }
      return false;
    }).toList();
  }
}

import 'dart:core';

import 'package:teno_datetime/teno_datetime.dart';
import 'package:teno_rrule/src/cache/SimpleMemCache.dart';
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
      // special applied with byMonths
      if (isNotEmpty(rrule.byMonths) || rrule.frequency == Frequency.monthly) {
        List<DateTime> result = [];

        // we always start on first day of month, because the second instance of the input
        // need to cover back the first day of month, because all are after the start date.
        for (int monthDay = 1;
            monthDay <= element.endOf(Unit.month).day;
            monthDay++) {
          final candidate = cloneWith(element, day: monthDay);
          if (_weekDaysContains(rrule.byWeekDays!, candidate)) {
            result.add(candidate);
          }
        }
        return result;
      }

      return _allWeekDaysOnSameWeek(element, rrule);
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

  // for this function, we don't need to care about timezone as
  // it operates on day, month, and year only.
  bool _weekDaysContains(Set<WeekDay> byWeekDays, DateTime dateTime) {
    for (WeekDay weekDay in byWeekDays) {
      if (weekDay.weekDay != dateTime.weekday) {
        continue;
      }
      if (weekDay.occurrence == null) {
        return true;
      }
      final expectedDate = _findWeekDayOccurrence(weekDay, dateTime);
      if (expectedDate?.isSameUnit(dateTime, unit: Unit.day) == true) {
        return true;
      }
    }
    return false;
  }

  // by default we cache for 12 months of a year. Will consider to provide
  // larger caching on required
  final SimpleMemCache<Map<int, Map<int, DateTime>>> _weekDaySamplesCache =
      SimpleMemCache();

  /// Try to pre-build all week day occurrence-aware of provided month.
  /// For ex: 1FR = 2023-11-3, 2FR = 2023-11-10, -1FR = 2023-11-24
  Map<int, Map<int, DateTime>> _getWeekDaySamples(DateTime dateTime) {
    // We should use cached here because of the loop of special expand on every day of the month.
    return _weekDaySamplesCache.getOrBuild((dateTime.year, dateTime.month), () {
      final Map<int, Map<int, DateTime>> monthWeekDaySamples = {};

      final firstDayOfMonth = dateTime.startOf(Unit.month);
      final lastDayOfMonth = dateTime.endOf(Unit.month).copyWith(
          hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

      for (DateTime monthDay = firstDayOfMonth;
          monthDay.isSameOrBeforeUnit(lastDayOfMonth, unit: Unit.day);
          monthDay = monthDay.addUnit(days: 1)) {
        final dayMap = monthWeekDaySamples[monthDay.weekday] ?? {};

        int forwardNo =
            (monthDay.diff(firstDayOfMonth, unit: Unit.day) / 7).floor() + 1;
        assert(forwardNo > 0, '$monthDay, $firstDayOfMonth, $forwardNo');

        int reverseNo =
            (monthDay.diff(lastDayOfMonth, unit: Unit.day) / 7).floor() - 1;
        assert(reverseNo < 0, '$monthDay, $lastDayOfMonth, $reverseNo}');

        dayMap[forwardNo] = monthDay;
        dayMap[reverseNo] = monthDay;
        monthWeekDaySamples[monthDay.weekday] = dayMap;
      }
      return monthWeekDaySamples;
    });
  }

  DateTime? _findWeekDayOccurrence(WeekDay weekDay, DateTime dateTime) {
    return _getWeekDaySamples(dateTime)[weekDay.weekDay]?[weekDay.occurrence];
  }
}

import 'dart:core';

import 'package:teno_datetime/teno_datetime.dart';

import '../cache/SimpleMemCache.dart';
import '../models/Frequency.dart';
import '../models/RecurrenceRule.dart';
import '../models/WeekDay.dart';
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

      // expanding for yearly with byMonths has been handled above.
      if (rrule.frequency == Frequency.yearly) {
        return rrule.byWeekDays!.flatMap((weekDay) {
          return _allWeekDaysOfYear(weekDay, element);
        });
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
    });
  }

  @override
  List<DateTime> limit(List<DateTime> instances, RecurrenceRule rrule) {
    return instances.where((element) {
      return _weekDaysContains(rrule.byWeekDays!, element);
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
      final Map<int, int> maxForwardWeekDay = {};
      final Map<int, int> minReverseWeekDay = {};

      final firstDayOfMonth = dateTime.startOf(Unit.month);
      final lastDayOfMonth = dateTime.endOf(Unit.month).copyWith(
          hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

      // We use 2 pointer to travel from first day to last day
      // and the reversed oder from last day to first day, to count for the
      // occurrence of specific weekday.
      // But the complexity is still O(n).

      DateTime reverseDay = lastDayOfMonth;
      for (DateTime forwardDay = firstDayOfMonth;
          forwardDay.isSameOrBeforeUnit(lastDayOfMonth, unit: Unit.day);
          forwardDay = forwardDay.addUnit(days: 1)) {
        // Increase the occurrence by 1, simple but always correct.
        final forwardMap = monthWeekDaySamples[forwardDay.weekday] ?? {};
        final forwardOccurrenceIndex =
            (maxForwardWeekDay[forwardDay.weekday] ?? 0) + 1;
        forwardMap[forwardOccurrenceIndex] = forwardDay;
        maxForwardWeekDay[forwardDay.weekday] = forwardOccurrenceIndex;
        monthWeekDaySamples[forwardDay.weekday] = forwardMap;

        // Decrease the occurrence by 1, from the end of month.
        final reverseMap = monthWeekDaySamples[reverseDay.weekday] ?? {};
        final reverseOccurrenceIndex =
            (minReverseWeekDay[reverseDay.weekday] ?? 0) - 1;
        reverseMap[reverseOccurrenceIndex] = reverseDay;
        minReverseWeekDay[reverseDay.weekday] = reverseOccurrenceIndex;
        monthWeekDaySamples[reverseDay.weekday] = reverseMap;
        reverseDay = reverseDay.addUnit(days: -1);
      }

      return monthWeekDaySamples;
    });
  }

  DateTime? _findWeekDayOccurrence(WeekDay weekDay, DateTime dateTime) {
    return _getWeekDaySamples(dateTime)[weekDay.weekDay]?[weekDay.occurrence];
  }

  Iterable<DateTime> _allWeekDaysOfYear(WeekDay weekDay, DateTime element) {
    int count = 0;
    final result = <DateTime>[];
    bool reversed = weekDay.occurrence != null && weekDay.occurrence! < 0;

    DateTime date = reversed
        ? element.endOf(Unit.year).copyWith(
            hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0)
        : element.startOf(Unit.year);
    while (date.isSameUnit(element, unit: Unit.year)) {
      if (date.weekday == weekDay.weekDay) {
        count = count + (reversed ? -1 : 1);
      }
      if (weekDay.occurrence == null || weekDay.occurrence == count) {
        result.add(cloneWith(element, month: date.month, day: date.day));
        if (weekDay.occurrence != null) {
          // found, exit!
          return result;
        }
      }
      // if we haven't found the first weekDay, then we step 1 day, otherwise step 1 week
      if (count == 0) {
        date = date.addUnit(days: reversed ? -1 : 1);
      } else {
        date = date.addUnit(days: reversed ? -7 : 7);
      }
    }
    return result;
  }
}

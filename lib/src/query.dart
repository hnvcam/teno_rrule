part of 'teno_rrule_base.dart';

extension InstancesQuery on RecurrenceRule {
  List<DateTime> get allInstances {
    return between(startDate.addUnit(seconds: -1), maxAllowedDate);
  }

  // timezone aware
  List<DateTime> between(DateTime begin, DateTime end) {
    if (count == 0 || interval == 0) {
      return [];
    }

    //       The value of the UNTIL rule part MUST have the same
    //       value type as the "DTSTART" property.  Furthermore, if the
    //       "DTSTART" property is specified as a date with local time, then
    //       the UNTIL rule part MUST also be specified as a date with local
    //       time.  If the "DTSTART" property is specified as a date with UTC
    //       time or a date with local time and time zone reference, then the
    //       UNTIL rule part MUST be specified as a date with UTC time.  In the
    //       case of the "STANDARD" and "DAYLIGHT" sub-components the UNTIL
    //       rule part MUST always be specified as a date with UTC time.  If
    //       specified as a DATE-TIME value, then it MUST be specified in a UTC
    //       time format.
    // *** I understand that if DTSTART is a timezone-aware type, the UNTIL will have the same
    // *** timezone. The Z character is for not needing to specify the timezone again.
    final tzEndDate = endDate == null
        ? null
        : cloneWith(startDate,
            year: endDate!.year,
            month: endDate!.month,
            day: endDate!.day,
            hour: endDate!.hour,
            minute: endDate!.minute,
            second: endDate!.second);
    final effectiveBegin = begin.orBeforeUnit(startDate, unit: Unit.second);
    final effectiveEnd = tzEndDate == null ? end : end.orAfterUnit(tzEndDate);

    final results = <DateTime>[];
    DateTime instance = cloneWith(startDate);

    int effectiveCount = count ?? -1;
    // does not include until
    while (instance.isBeforeUnit(effectiveEnd, unit: Unit.second)) {
      // before range.
      if (instance.isBeforeUnit(effectiveBegin, unit: Unit.second)) {
        instance = _getNextInstance(instance, frequency, interval);
        continue;
      }

      final expandedAndLimitedInstances =
          ByXXXChain.chain.process([instance], this);
      for (var element in expandedAndLimitedInstances) {
        // filter for start range
        if (element.isBeforeUnit(effectiveBegin, unit: Unit.second)) {
          continue;
        }

        // filter for until
        if (element.isBeforeUnit(effectiveEnd, unit: Unit.second)) {
          results.add(element);
          effectiveCount--;
          if (effectiveCount == 0) {
            return results;
          }
        }
      }

      instance = _getNextInstance(instance, frequency, interval);
    }
    return results;
  }
}

DateTime _getNextInstance(
    DateTime instance, Frequency frequency, int interval) {
  switch (frequency) {
    case Frequency.secondly:
      return instance.addUnit(seconds: interval);
    case Frequency.minutely:
      return instance.addUnit(minutes: interval);
    case Frequency.hourly:
      return instance.addUnit(hours: interval);
    case Frequency.daily:
      return instance.addUnit(days: interval);
    case Frequency.weekly:
      return instance.addUnit(days: interval * 7);
    case Frequency.monthly:
      DateTime temp = cloneWith(instance);
      for (int i = 1; i <= interval; i++) {
        if (temp.month < DateTime.december) {
          // if we don't reset day to 1, then we sometime miss the DateTime.february.
          // Is there any case that the rule only has FREQ=MONTHLY and no other rule?
          temp = cloneWith(temp, month: temp.month + 1, day: 1);
        } else {
          temp = cloneWith(temp,
              month: DateTime.january, year: temp.year + 1, day: 1);
        }
      }
      return temp;
    case Frequency.yearly:
      return cloneWith(instance, year: instance.year + interval);
    default:
      throw UnsupportedError('Unsupported frequency of $frequency');
  }
}

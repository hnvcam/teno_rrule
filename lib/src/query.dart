part of 'teno_rrule_base.dart';

extension InstancesQuery on RecurrenceRule {
  List<DateTime> get allInstances {
    return between(startDate.addUnit(seconds: -1), maxAllowedDate);
  }

  List<DateTime> between(DateTime begin, DateTime end) {
    if (count == 0 || interval == 0) {
      return [];
    }
    Location? timeLocation;
    if (!isLocal) {
      timeLocation = getTimeLocation(startDate);
    }
    final tzBegin =
        timeLocation == null ? begin : toTZDateTime(timeLocation, begin);
    final tzEnd = timeLocation == null ? end : toTZDateTime(timeLocation, end);

    final effectiveBegin = tzBegin.orBeforeUnit(startDate, unit: Unit.second);
    final effectiveEnd = endDate == null ? tzEnd : tzEnd.orAfterUnit(endDate!);

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
          temp = cloneWith(temp, month: temp.month + 1);
        } else {
          temp = cloneWith(temp, month: DateTime.january, year: temp.year + 1);
        }
      }
      return temp;
    case Frequency.yearly:
      return cloneWith(instance, year: instance.year + interval);
    default:
      throw UnsupportedError('Unsupported frequency of $frequency');
  }
}

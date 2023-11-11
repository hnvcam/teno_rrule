import 'package:teno_rrule/src/models/RecurrenceRule.dart';
// tried to use the minimal one
import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/standalone.dart';

extension RecurrenceRuleToRFC2445String on RecurrenceRule {
  String get rfc2445String {
    List<String> rules = [];
    // Frequency
    rules.add('FREQ=${frequency.value}');
    if (endDate != null) {
      // always UTC time
      rules.add('UNTIL=${_dateTimeToRFC2445String(endDate!)}Z');
    }
    if (count != null && count! > 0) {
      rules.add('COUNT=$count');
    }
    // interval
    if (interval > 1) {
      rules.add('INTERVAL=$interval');
    }
    if (bySeconds != null) {
      rules.add('BYSECOND=${_intSetToRFC2445String(bySeconds!)}');
    }
    if (byMinutes != null) {
      rules.add('BYMINUTE=${_intSetToRFC2445String(byMinutes!)}');
    }
    if (byHours != null) {
      rules.add('BYHOUR=${_intSetToRFC2445String(byHours!)}');
    }
    if (byWeekDays != null) {
      rules.add('BYDAY=${byWeekDays!.map(_weekDayToRFC2445String).join(',')}');
    }
    if (byMonthDays != null) {
      rules.add('BYMONTHDAY=${_intSetToRFC2445String(byMonthDays!)}');
    }
    if (byYearDays != null) {
      rules.add('BYYEARDAY=${_intSetToRFC2445String(byYearDays!)}');
    }
    if (byWeeks != null) {
      rules.add('BYWEEKNO=${_intSetToRFC2445String(byWeeks!)}');
    }
    if (byMonths != null) {
      rules.add('BYMONTH=${_intSetToRFC2445String(byMonths!)}');
    }
    if (bySetPositions != null) {
      rules.add('BYSETPOS=${_intSetToRFC2445String(bySetPositions!)}');
    }
    if (weekStart != null) {
      rules.add('WKST=${_weekDayToRFC2445String(weekStart!)}');
    }

    return '${_dtstartString(startDate, isLocal)}\nRRULE:${rules.join(';')}';
  }
}

String _intSetToRFC2445String(Set<int> bySetPositions) {
  return bySetPositions.join(',');
}

String _weekDayToRFC2445String(int weekDay) {
  switch (weekDay) {
    case DateTime.monday:
      return 'MO';
    case DateTime.tuesday:
      return 'TU';
    case DateTime.wednesday:
      return 'WE';
    case DateTime.thursday:
      return 'TH';
    case DateTime.friday:
      return 'FR';
    case DateTime.saturday:
      return 'SA';
    case DateTime.sunday:
      return 'SU';
    default:
      throw UnsupportedError('Invalid week day value of $weekDay');
  }
}

String _dateTimeToRFC2445String(DateTime dateTime) {
  return '${dateTime.year}${_padZeroInt(dateTime.month)}${_padZeroInt(dateTime.day)}T'
      '${_padZeroInt(dateTime.hour)}${_padZeroInt(dateTime.minute)}${_padZeroInt(dateTime.second)}';
}

String _dtstartString(DateTime dateTime, bool isLocal) {
  if (isLocal) {
    return 'DTSTART:${_dateTimeToRFC2445String(dateTime)}';
  }
  if (dateTime.isUtc) {
    return 'DTSTART:${_dateTimeToRFC2445String(dateTime)}Z';
  }
  if (dateTime is TZDateTime) {
    return 'DTSTART;TZID=${dateTime.location.name}:${_dateTimeToRFC2445String(dateTime)}';
  }
  final timezoneId = _getTimezoneId(dateTime);
  return 'DTSTART;TZID=$timezoneId:${_dateTimeToRFC2445String(dateTime)}';
}

String _getTimezoneId(DateTime dateTime) {
  if (!timeZoneDatabase.isInitialized) {
    initializeTimeZones();
  }
  final timezoneOffsetInMilliseconds = dateTime.timeZoneOffset.inMilliseconds;
  final location = timeZoneDatabase.locations.values.firstWhere((loc) {
    for (TimeZone zone in loc.zones) {
      if (zone.offset == timezoneOffsetInMilliseconds) {
        return true;
      }
    }
    return false;
  });
  return location.name;
}

String _padZeroInt(int value) {
  return value.toString().padLeft(2, '0');
}

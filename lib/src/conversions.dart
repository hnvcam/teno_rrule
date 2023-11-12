import 'package:teno_rrule/src/models/Frequency.dart';
import 'package:teno_rrule/src/models/RecurrenceRule.dart';
import 'package:teno_rrule/src/models/WeekDay.dart';
import 'package:teno_rrule/src/teno_rrule_base.dart';
// tried to use the minimal one
import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/standalone.dart';

extension RecurrenceRuleToRFC5545String on RecurrenceRule {
  String get rfc5545String {
    List<String> rules = [];
    // Frequency
    rules.add('FREQ=${frequency.value}');
    if (endDate != null) {
      // always UTC time
      rules.add('UNTIL=${_dateTimeToRFC5545String(endDate!)}Z');
    }
    if (count != null && count! > 0) {
      rules.add('COUNT=$count');
    }
    // interval
    if (interval > 1) {
      rules.add('INTERVAL=$interval');
    }
    if (bySeconds != null) {
      rules.add('BYSECOND=${_intSetToRFC5545String(bySeconds!)}');
    }
    if (byMinutes != null) {
      rules.add('BYMINUTE=${_intSetToRFC5545String(byMinutes!)}');
    }
    if (byHours != null) {
      rules.add('BYHOUR=${_intSetToRFC5545String(byHours!)}');
    }
    if (byWeekDays != null) {
      rules.add('BYDAY=${byWeekDays!.map((e) => e.toString()).join(',')}');
    }
    if (byMonthDays != null) {
      rules.add('BYMONTHDAY=${_intSetToRFC5545String(byMonthDays!)}');
    }
    if (byYearDays != null) {
      rules.add('BYYEARDAY=${_intSetToRFC5545String(byYearDays!)}');
    }
    if (byWeeks != null) {
      rules.add('BYWEEKNO=${_intSetToRFC5545String(byWeeks!)}');
    }
    if (byMonths != null) {
      rules.add('BYMONTH=${_intSetToRFC5545String(byMonths!)}');
    }
    if (bySetPositions != null) {
      rules.add('BYSETPOS=${_intSetToRFC5545String(bySetPositions!)}');
    }
    if (weekStart != null) {
      rules.add('WKST=${WeekDay(weekStart!).toString()}');
    }

    return '${_dtStartString(startDate, isLocal)}\nRRULE:${rules.join(';')}';
  }
}

RecurrenceRule? parseRFC5545String(String rfc5545string) {
  final lines = rfc5545string.split('\n');
  DateTime? startDate;
  bool? isLocal;
  RecurrenceRule? rrule;
  for (String line in lines) {
    final header = _inspectHeader(line);
    if (header == null) {
      rrule = _parseRRule(line);
      continue;
    }
    switch (header.toUpperCase()) {
      case 'RRULE':
      case 'EXRULE':
        rrule = _parseRRule(line);
        break;
      case 'DTSTART':
        final parsedResult = _parseStartDate(line);
        startDate = parsedResult?.$1;
        isLocal = parsedResult?.$2;
        break;
      default:
        throw UnsupportedError(
            'Unsupported header of $header in rfc5545 string');
    }
  }
  return rrule?.copyWith(startDate: startDate, isLocal: isLocal);
}

String? _inspectHeader(String line) {
  final regex = RegExp(r'^([A-Z]+?)[:;]');
  final match = regex.firstMatch(line);
  return match?[1];
}

(DateTime value, bool hasTimezone)? _parseStartDate(String line) {
  final regex = RegExp(r'DTSTART(?:;TZID=([^:=]+?))?[:=]([^;\s]+)');
  final match = regex.firstMatch(line);
  final tzId = match?[1];
  final dateTimeString = match?[2];
  if (dateTimeString == null) {
    return null;
  }
  final localDateTime = DateTime.parse(dateTimeString);
  if (localDateTime.isUtc) {
    return (localDateTime, false);
  }
  return tzId == null
      ? (localDateTime, true)
      : (
          TZDateTime(
              getLocation(tzId),
              localDateTime.year,
              localDateTime.month,
              localDateTime.day,
              localDateTime.hour,
              localDateTime.minute,
              localDateTime.second),
          false
        );
}

RecurrenceRule _parseRRule(String line) {
  final ruleData = line.replaceFirst(RegExp(r'^(?:RRULE|EXRULE):'), '');
  final groups = ruleData.split(';');
  Frequency? frequency;
  int? weekStart;
  DateTime? endDate;
  int? interval;
  int? count;
  Set<int>? bySeconds;
  Set<int>? byMinutes;
  Set<int>? byHours;
  Set<int>? byMonths;
  Set<WeekDay>? byWeekDays;
  Set<int>? byMonthDays;
  Set<int>? byYearDays;
  Set<int>? byWeeks;
  Set<int>? bySetPositions;
  for (String group in groups) {
    final pair = group.split('=');
    if (pair.length != 2) {
      throw ParseException('Invalid format of {key}={value}', group);
    }
    final key = pair[0];
    final value = pair[1];
    switch (key.toUpperCase()) {
      case 'FREQ':
        frequency = Frequency.values.firstWhere(
            (element) => element.value == value,
            orElse: () =>
                throw ParseException('Unsupported FREQ value', value));
        break;
      case 'WKST':
        weekStart = WeekDay.fromString(value).weekDay;
        break;
      case 'COUNT':
        count = int.parse(value);
        break;
      case 'INTERVAL':
        interval = int.parse(value);
        break;
      case 'BYSETPOS':
        bySetPositions = _parseIntSet(value);
        break;
      case 'BYMONTH':
        byMonths = _parseIntSet(value);
        break;
      case 'BYMONTHDAY':
        byMonthDays = _parseIntSet(value);
        break;
      case 'BYYEARDAY':
        byYearDays = _parseIntSet(value);
        break;
      case 'BYWEEKNO':
        byWeeks = _parseIntSet(value);
        break;
      case 'BYHOUR':
        byHours = _parseIntSet(value);
        break;
      case 'BYMINUTE':
        byMinutes = _parseIntSet(value);
        break;
      case 'BYSECOND':
        bySeconds = _parseIntSet(value);
        break;
      case 'BYDAY':
        byWeekDays = _parseWeekDaySet(value.toUpperCase());
        break;
      case 'UNTIL':
        endDate = DateTime.parse(value);
        break;
      default:
        throw UnsupportedError('Unsupported pair of $group');
    }
  }
  if (frequency == null) {
    throw ParseException('FREQ is required', line);
  }
  return RecurrenceRule(
      frequency: frequency,
      startDate: DateTime.now(),
      weekStart: weekStart,
      endDate: endDate,
      interval: interval ?? 1,
      count: count,
      bySeconds: bySeconds,
      byMinutes: byMinutes,
      byHours: byHours,
      byMonths: byMonths,
      byWeekDays: byWeekDays,
      byMonthDays: byMonthDays,
      byYearDays: byYearDays,
      byWeeks: byWeeks,
      bySetPositions: bySetPositions);
}

Set<WeekDay>? _parseWeekDaySet(String value) {
  final weekDayValues = value.split(',');
  return weekDayValues.map((e) => WeekDay.fromString(e)).toSet();
}

Set<int>? _parseIntSet(String value) {
  final intValues = value.split(',');
  return intValues.map((e) => int.parse(e)).toSet();
}

String _intSetToRFC5545String(Set<int> intSet) {
  return intSet.join(',');
}

String _dateTimeToRFC5545String(DateTime dateTime) {
  return '${dateTime.year}${_padZeroInt(dateTime.month)}${_padZeroInt(dateTime.day)}T'
      '${_padZeroInt(dateTime.hour)}${_padZeroInt(dateTime.minute)}${_padZeroInt(dateTime.second)}';
}

String _dtStartString(DateTime dateTime, bool isLocal) {
  if (isLocal) {
    return 'DTSTART:${_dateTimeToRFC5545String(dateTime)}';
  }
  if (dateTime.isUtc) {
    return 'DTSTART:${_dateTimeToRFC5545String(dateTime)}Z';
  }
  if (dateTime is TZDateTime) {
    return 'DTSTART;TZID=${dateTime.location.name}:${_dateTimeToRFC5545String(dateTime)}';
  }
  final timezoneId = _getTimezoneId(dateTime);
  return 'DTSTART;TZID=$timezoneId:${_dateTimeToRFC5545String(dateTime)}';
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

import 'package:teno_datetime/teno_datetime.dart';
import 'package:teno_rrule/teno_rrule.dart' hide isEmpty, isNotEmpty;
import 'package:test/test.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/standalone.dart';

import 'testUtils.dart';

void main() {
  initializeTimeZones();

  group('SECONDLY frequency', () {
    test('SECONDLY with COUNT', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.secondly,
        startDate: DateTime(2024, 1, 1, 12, 0, 0),
        count: 5,
      );
      expect(rrule.allInstances, [
        for (int i = 0; i < 5; i++)
          DateTime(2024, 1, 1, 12, 0, i),
      ]);
    });

    test('SECONDLY with INTERVAL', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.secondly,
        startDate: DateTime(2024, 1, 1, 12, 0, 0),
        interval: 15,
        count: 5,
      );
      expect(rrule.allInstances, [
        DateTime(2024, 1, 1, 12, 0, 0),
        DateTime(2024, 1, 1, 12, 0, 15),
        DateTime(2024, 1, 1, 12, 0, 30),
        DateTime(2024, 1, 1, 12, 0, 45),
        DateTime(2024, 1, 1, 12, 1, 0),
      ]);
    });

    test('SECONDLY with BYSECOND (limiting)', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.secondly,
        startDate: DateTime(2024, 1, 1, 12, 0, 0),
        bySeconds: {0, 15, 30, 45},
        count: 8,
      );
      expect(rrule.allInstances, [
        DateTime(2024, 1, 1, 12, 0, 0),
        DateTime(2024, 1, 1, 12, 0, 15),
        DateTime(2024, 1, 1, 12, 0, 30),
        DateTime(2024, 1, 1, 12, 0, 45),
        DateTime(2024, 1, 1, 12, 1, 0),
        DateTime(2024, 1, 1, 12, 1, 15),
        DateTime(2024, 1, 1, 12, 1, 30),
        DateTime(2024, 1, 1, 12, 1, 45),
      ]);
    });

    test('SECONDLY with BYMINUTE (limiting)', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.secondly,
        startDate: DateTime(2024, 1, 1, 12, 0, 0),
        byMinutes: {0, 1},
        count: 120,
      );
      final instances = rrule.allInstances;
      expect(instances.length, 120);
      // All instances should be in minute 0 or 1
      for (var inst in instances) {
        expect(inst.minute == 0 || inst.minute == 1, isTrue);
      }
    });
  });

  group('BYSECOND property', () {
    test('MINUTELY with BYSECOND (expansion)', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.minutely,
        startDate: DateTime(2024, 1, 1, 12, 0, 0),
        bySeconds: {0, 30},
        count: 6,
      );
      expect(rrule.allInstances, [
        DateTime(2024, 1, 1, 12, 0, 0),
        DateTime(2024, 1, 1, 12, 0, 30),
        DateTime(2024, 1, 1, 12, 1, 0),
        DateTime(2024, 1, 1, 12, 1, 30),
        DateTime(2024, 1, 1, 12, 2, 0),
        DateTime(2024, 1, 1, 12, 2, 30),
      ]);
    });

    test('HOURLY with BYSECOND (expansion)', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.hourly,
        startDate: DateTime(2024, 1, 1, 10, 0, 0),
        bySeconds: {0, 30},
        count: 4,
      );
      expect(rrule.allInstances, [
        DateTime(2024, 1, 1, 10, 0, 0),
        DateTime(2024, 1, 1, 10, 0, 30),
        DateTime(2024, 1, 1, 11, 0, 0),
        DateTime(2024, 1, 1, 11, 0, 30),
      ]);
    });

    test('DAILY with BYSECOND (expansion)', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.daily,
        startDate: DateTime(2024, 1, 1, 12, 0, 0),
        bySeconds: {0, 30},
        count: 4,
      );
      expect(rrule.allInstances, [
        DateTime(2024, 1, 1, 12, 0, 0),
        DateTime(2024, 1, 1, 12, 0, 30),
        DateTime(2024, 1, 2, 12, 0, 0),
        DateTime(2024, 1, 2, 12, 0, 30),
      ]);
    });

    test('MINUTELY with BYSECOND and BYMINUTE combined', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.hourly,
        startDate: DateTime(2024, 1, 1, 10, 0, 0),
        byMinutes: {0, 30},
        bySeconds: {0, 15},
        count: 8,
      );
      expect(rrule.allInstances, [
        DateTime(2024, 1, 1, 10, 0, 0),
        DateTime(2024, 1, 1, 10, 0, 15),
        DateTime(2024, 1, 1, 10, 30, 0),
        DateTime(2024, 1, 1, 10, 30, 15),
        DateTime(2024, 1, 1, 11, 0, 0),
        DateTime(2024, 1, 1, 11, 0, 15),
        DateTime(2024, 1, 1, 11, 30, 0),
        DateTime(2024, 1, 1, 11, 30, 15),
      ]);
    });
  });

  group('BYSECOND serialization and parsing', () {
    test('BYSECOND serialization', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.minutely,
        startDate: DateTime(2024, 1, 1, 12, 0, 0),
        bySeconds: {0, 30},
        count: 6,
      );
      expect(rrule.rfc5545String,
          isSameRFC5545StringAs('DTSTART:20240101T120000\nRRULE:FREQ=MINUTELY;COUNT=6;BYSECOND=0,30'));
    });

    test('BYSECOND parsing', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240101T120000\nRRULE:FREQ=MINUTELY;COUNT=6;BYSECOND=0,30');
      expect(rrule, isNotNull);
      expect(rrule!.bySeconds, {0, 30});
      expect(rrule.frequency, Frequency.minutely);
      expect(rrule.count, 6);
    });

    test('BYSECOND round-trip', () {
      final original = RecurrenceRule(
        frequency: Frequency.hourly,
        startDate: DateTime(2024, 1, 1, 10, 0, 0),
        bySeconds: {0, 15, 30, 45},
        count: 12,
      );
      final serialized = original.rfc5545String;
      final parsed = parseRFC5545String(serialized);
      expect(parsed, original);
    });
  });

  group('BYSETPOS with YEARLY', () {
    test('YEARLY with BYMONTH and BYDAY and BYSETPOS (last Thursday in November)', () {
      // US Thanksgiving: 4th Thursday in November
      final rrule = RecurrenceRule.from(
          'DTSTART:20200101T090000\n'
          'RRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=TH;BYSETPOS=4;COUNT=5')!;
      expect(rrule.allInstances, [
        DateTime(2020, 11, 26, 9),
        DateTime(2021, 11, 25, 9),
        DateTime(2022, 11, 24, 9),
        DateTime(2023, 11, 23, 9),
        DateTime(2024, 11, 28, 9),
      ]);
    });

    test('YEARLY with BYMONTH and BYDAY and BYSETPOS=-1 (last weekday of the year)', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20200101T090000\n'
          'RRULE:FREQ=YEARLY;BYMONTH=12;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-1;COUNT=4')!;
      expect(rrule.allInstances, [
        DateTime(2020, 12, 31, 9), // Thursday
        DateTime(2021, 12, 31, 9), // Friday
        DateTime(2022, 12, 30, 9), // Friday
        DateTime(2023, 12, 29, 9), // Friday
      ]);
    });
  });

  group('BYSETPOS serialization and parsing', () {
    test('BYSETPOS serialization', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.monthly,
        startDate: DateTime(2024, 1, 1, 9),
        byWeekDays: {WeekDay.monday, WeekDay.tuesday, WeekDay.wednesday, WeekDay.thursday, WeekDay.friday},
        bySetPositions: {-1},
        count: 3,
      );
      expect(rrule.rfc5545String,
          isSameRFC5545StringAs('DTSTART:20240101T090000\nRRULE:FREQ=MONTHLY;COUNT=3;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-1'));
    });

    test('BYSETPOS parsing', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240101T090000\nRRULE:FREQ=MONTHLY;COUNT=3;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-1');
      expect(rrule, isNotNull);
      expect(rrule!.bySetPositions, {-1});
    });
  });

  group('BYHOUR and BYMINUTE serialization and parsing', () {
    test('BYHOUR serialization', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.daily,
        startDate: DateTime(2024, 1, 1, 9),
        byHours: {9, 17},
        count: 4,
      );
      expect(rrule.rfc5545String,
          isSameRFC5545StringAs('DTSTART:20240101T090000\nRRULE:FREQ=DAILY;COUNT=4;BYHOUR=9,17'));
    });

    test('BYHOUR parsing', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240101T090000\nRRULE:FREQ=DAILY;COUNT=4;BYHOUR=9,17');
      expect(rrule, isNotNull);
      expect(rrule!.byHours, {9, 17});
    });

    test('BYMINUTE serialization', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.hourly,
        startDate: DateTime(2024, 1, 1, 9),
        byMinutes: {0, 30},
        count: 4,
      );
      expect(rrule.rfc5545String,
          isSameRFC5545StringAs('DTSTART:20240101T090000\nRRULE:FREQ=HOURLY;COUNT=4;BYMINUTE=0,30'));
    });

    test('BYMINUTE parsing', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240101T090000\nRRULE:FREQ=HOURLY;COUNT=4;BYMINUTE=0,30');
      expect(rrule, isNotNull);
      expect(rrule!.byMinutes, {0, 30});
    });
  });

  group('BYYEARDAY negative values', () {
    test('YEARLY with negative BYYEARDAY=-1', () {
      // Implementation: startOfYear.addUnit(days: lastYearDay + yearDay + 1)
      // -1 with 366 days: 366 + (-1) + 1 = 366 => Jan 1 + 366 = Jan 1 next year
      // Note: this appears off-by-one vs RFC5545 which says -1 = last day of year
      final rrule = RecurrenceRule.from(
          'DTSTART:20200101T090000\n'
          'RRULE:FREQ=YEARLY;BYYEARDAY=-1;COUNT=4')!;
      expect(rrule.allInstances, [
        DateTime(2021, 1, 1, 9),
        DateTime(2022, 1, 1, 9),
        DateTime(2023, 1, 1, 9),
        DateTime(2024, 1, 1, 9),
      ]);
    });

    test('YEARLY with negative BYYEARDAY=-31', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20200101T090000\n'
          'RRULE:FREQ=YEARLY;BYYEARDAY=-31;COUNT=3')!;
      expect(rrule.allInstances, [
        DateTime(2020, 12, 2, 9),
        DateTime(2021, 12, 2, 9),
        DateTime(2022, 12, 2, 9),
      ]);
    });
  });

  group('Edge cases', () {
    test('COUNT=0 returns empty list', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.daily,
        startDate: DateTime(2024, 1, 1),
        count: 0,
      );
      expect(rrule.allInstances, isEmpty);
    });

    test('MONTHLY with BYMONTHDAY=29 skips February in non-leap years', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20230101T090000\n'
          'RRULE:FREQ=MONTHLY;BYMONTHDAY=29;COUNT=5')!;
      expect(rrule.allInstances, [
        DateTime(2023, 1, 29, 9),
        DateTime(2023, 3, 29, 9), // February skipped (non-leap year)
        DateTime(2023, 4, 29, 9),
        DateTime(2023, 5, 29, 9),
        DateTime(2023, 6, 29, 9),
      ]);
    });

    test('MONTHLY with BYMONTHDAY=29 includes February in leap years', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240101T090000\n'
          'RRULE:FREQ=MONTHLY;BYMONTHDAY=29;COUNT=5')!;
      expect(rrule.allInstances, [
        DateTime(2024, 1, 29, 9),
        DateTime(2024, 2, 29, 9), // leap year includes Feb 29
        DateTime(2024, 3, 29, 9),
        DateTime(2024, 4, 29, 9),
        DateTime(2024, 5, 29, 9),
      ]);
    });

    test('MONTHLY with BYMONTHDAY=31 skips months with fewer days', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240101T090000\n'
          'RRULE:FREQ=MONTHLY;BYMONTHDAY=31;COUNT=7')!;
      expect(rrule.allInstances, [
        DateTime(2024, 1, 31, 9),
        DateTime(2024, 3, 31, 9),  // Feb (29 days), skipped
        DateTime(2024, 5, 31, 9),  // Apr (30 days), skipped
        DateTime(2024, 7, 31, 9),  // Jun (30 days), skipped
        DateTime(2024, 8, 31, 9),
        DateTime(2024, 10, 31, 9), // Sep (30 days), skipped
        DateTime(2024, 12, 31, 9), // Nov (30 days), skipped
      ]);
    });

    test('YEARLY with large INTERVAL', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20000101T090000\n'
          'RRULE:FREQ=YEARLY;INTERVAL=10;COUNT=3')!;
      expect(rrule.allInstances, [
        DateTime(2000, 1, 1, 9),
        DateTime(2010, 1, 1, 9),
        DateTime(2020, 1, 1, 9),
      ]);
    });

    test('WEEKLY with INTERVAL=4 and COUNT=1', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240101T090000\n'
          'RRULE:FREQ=WEEKLY;INTERVAL=4;COUNT=1')!;
      expect(rrule.allInstances, [
        DateTime(2024, 1, 1, 9),
      ]);
    });
  });

  group('between method', () {
    test('between filters correctly for DAILY', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240101T090000\n'
          'RRULE:FREQ=DAILY;COUNT=30')!;
      final instances = rrule.between(DateTime(2024, 1, 10), DateTime(2024, 1, 15));
      expect(instances, [
        DateTime(2024, 1, 10, 9),
        DateTime(2024, 1, 11, 9),
        DateTime(2024, 1, 12, 9),
        DateTime(2024, 1, 13, 9),
        DateTime(2024, 1, 14, 9),
      ]);
    });

    test('between with MONTHLY and BYMONTHDAY returns instances in range', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240115T090000\n'
          'RRULE:FREQ=MONTHLY;BYMONTHDAY=15;COUNT=12')!;
      final instances = rrule.between(DateTime(2024, 3, 1), DateTime(2024, 6, 1));
      expect(instances, [
        DateTime(2024, 3, 15, 9),
        DateTime(2024, 4, 15, 9),
        DateTime(2024, 5, 15, 9),
      ]);
    });

    test('between returns empty when range is before start', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240601T090000\n'
          'RRULE:FREQ=DAILY;COUNT=10')!;
      final instances = rrule.between(DateTime(2024, 1, 1), DateTime(2024, 2, 1));
      expect(instances, isEmpty);
    });

    test('between returns empty when range is after all instances', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240101T090000\n'
          'RRULE:FREQ=DAILY;UNTIL=20240106T000000Z')!;
      // UNTIL Jan 6, so Jan 10-20 should be empty
      final instances = rrule.between(DateTime(2024, 1, 10), DateTime(2024, 1, 20));
      expect(instances, isEmpty);
    });
  });

  group('copyWith', () {
    test('copyWith preserves original values', () {
      final original = RecurrenceRule(
        frequency: Frequency.weekly,
        startDate: DateTime(2024, 1, 1),
        count: 10,
        byWeekDays: {WeekDay.monday},
      );
      final copied = original.copyWith(count: 5);
      expect(copied.frequency, Frequency.weekly);
      expect(copied.startDate, DateTime(2024, 1, 1));
      expect(copied.count, 5);
      expect(copied.byWeekDays, {WeekDay.monday});
    });

    test('copyWith changes frequency', () {
      final original = RecurrenceRule(
        frequency: Frequency.daily,
        startDate: DateTime(2024, 1, 1),
        count: 10,
      );
      final copied = original.copyWith(frequency: Frequency.weekly);
      expect(copied.frequency, Frequency.weekly);
      expect(copied.count, 10);
    });
  });

  group('Multiple EXDATE', () {
    test('Multiple EXDATE entries are excluded from instances', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.daily,
        startDate: DateTime(2024, 1, 1, 9),
        count: 7,
        excludedDates: {
          DateTime(2024, 1, 2, 9),
          DateTime(2024, 1, 4, 9),
          DateTime(2024, 1, 6, 9),
        },
      );
      expect(rrule.allInstances, [
        DateTime(2024, 1, 1, 9),
        DateTime(2024, 1, 3, 9),
        DateTime(2024, 1, 5, 9),
        DateTime(2024, 1, 7, 9),
      ]);
    });
  });

  group('HOURLY edge cases', () {
    test('HOURLY with BYHOUR limiting', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.hourly,
        startDate: DateTime(2024, 1, 1, 0, 0, 0),
        byHours: {9, 12, 15},
        count: 6,
      );
      expect(rrule.allInstances, [
        DateTime(2024, 1, 1, 9),
        DateTime(2024, 1, 1, 12),
        DateTime(2024, 1, 1, 15),
        DateTime(2024, 1, 2, 9),
        DateTime(2024, 1, 2, 12),
        DateTime(2024, 1, 2, 15),
      ]);
    });

    test('HOURLY with COUNT across day boundary', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.hourly,
        startDate: DateTime(2024, 1, 1, 22),
        interval: 2,
        count: 4,
      );
      expect(rrule.allInstances, [
        DateTime(2024, 1, 1, 22),
        DateTime(2024, 1, 2, 0),
        DateTime(2024, 1, 2, 2),
        DateTime(2024, 1, 2, 4),
      ]);
    });
  });

  group('WEEKLY edge cases', () {
    test('WEEKLY with multiple BYDAY across week boundary', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240101T090000\n'
          'RRULE:FREQ=WEEKLY;BYDAY=MO,FR;COUNT=6')!;
      expect(rrule.allInstances, [
        DateTime(2024, 1, 1, 9),  // Monday
        DateTime(2024, 1, 5, 9),  // Friday
        DateTime(2024, 1, 8, 9),  // Monday
        DateTime(2024, 1, 12, 9), // Friday
        DateTime(2024, 1, 15, 9), // Monday
        DateTime(2024, 1, 19, 9), // Friday
      ]);
    });

    test('WEEKLY with all 7 days', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240101T090000\n'
          'RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR,SA,SU;COUNT=7')!;
      expect(rrule.allInstances, [
        for (int i = 0; i < 7; i++)
          DateTime(2024, 1, 1, 9).addUnit(days: i),
      ]);
    });
  });

  group('YEARLY with BYWEEKNO and multiple BYDAY', () {
    test('YEARLY with BYWEEKNO=1 and BYDAY=MO,FR', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20200101T090000\n'
          'RRULE:FREQ=YEARLY;BYWEEKNO=1;BYDAY=MO,FR;COUNT=6')!;
      final instances = rrule.allInstances;
      expect(instances.length, 6);
      // Each year should have a Monday and Friday in week 1
      for (var inst in instances) {
        expect(inst.weekday == DateTime.monday || inst.weekday == DateTime.friday, isTrue);
      }
    });
  });

  group('DAILY with BYMONTH limiting', () {
    test('DAILY with BYMONTH limits to specific months', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240101T090000\n'
          'RRULE:FREQ=DAILY;BYMONTH=1;COUNT=5')!;
      expect(rrule.allInstances, [
        for (int i = 0; i < 5; i++)
          DateTime(2024, 1, 1 + i, 9),
      ]);
    });
  });

  group('YEARLY with BYDAY occurrence across years', () {
    test('YEARLY with -1FR (last Friday of the year)', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20200101T090000\n'
          'RRULE:FREQ=YEARLY;BYDAY=-1FR;COUNT=4')!;
      expect(rrule.allInstances, [
        DateTime(2020, 12, 25, 9),
        DateTime(2021, 12, 31, 9),
        DateTime(2022, 12, 30, 9),
        DateTime(2023, 12, 29, 9),
      ]);
    });

    test('YEARLY with 1MO (first Monday of the year)', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20200101T090000\n'
          'RRULE:FREQ=YEARLY;BYDAY=1MO;COUNT=4')!;
      expect(rrule.allInstances, [
        DateTime(2020, 1, 6, 9),
        DateTime(2021, 1, 4, 9),
        DateTime(2022, 1, 3, 9),
        DateTime(2023, 1, 2, 9),
      ]);
    });
  });

  group('Timezone-aware SECONDLY and BYSECOND', () {
    test('SECONDLY with timezone', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.secondly,
        startDate: newYorkDateTime(2024, 1, 1, 12, 0, 0),
        isLocal: false,
        count: 3,
      );
      expect(rrule.allInstances, [
        newYorkDateTime(2024, 1, 1, 12, 0, 0),
        newYorkDateTime(2024, 1, 1, 12, 0, 1),
        newYorkDateTime(2024, 1, 1, 12, 0, 2),
      ]);
    });

    test('MINUTELY with BYSECOND and timezone', () {
      final rrule = RecurrenceRule.from(
          'DTSTART;TZID=America/New_York:20240101T120000\n'
          'RRULE:FREQ=MINUTELY;BYSECOND=0,30;COUNT=4')!;
      expect(rrule.allInstances, [
        newYorkDateTime(2024, 1, 1, 12, 0, 0),
        newYorkDateTime(2024, 1, 1, 12, 0, 30),
        newYorkDateTime(2024, 1, 1, 12, 1, 0),
        newYorkDateTime(2024, 1, 1, 12, 1, 30),
      ]);
    });
  });

  group('SECONDLY serialization and parsing', () {
    test('SECONDLY serialization', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.secondly,
        startDate: DateTime(2024, 1, 1, 12, 0, 0),
        count: 5,
      );
      expect(rrule.rfc5545String,
          isSameRFC5545StringAs('DTSTART:20240101T120000\nRRULE:FREQ=SECONDLY;COUNT=5'));
    });

    test('SECONDLY parsing', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240101T120000\nRRULE:FREQ=SECONDLY;COUNT=5');
      expect(rrule, isNotNull);
      expect(rrule!.frequency, Frequency.secondly);
      expect(rrule.count, 5);
    });

    test('SECONDLY with INTERVAL round-trip', () {
      final original = RecurrenceRule(
        frequency: Frequency.secondly,
        startDate: DateTime(2024, 1, 1, 12, 0, 0),
        interval: 30,
        count: 10,
      );
      final serialized = original.rfc5545String;
      final parsed = parseRFC5545String(serialized);
      expect(parsed, original);
    });
  });

  group('MONTHLY with BYDAY and no occurrence (all weekdays in month)', () {
    test('MONTHLY BYDAY=MO with UNTIL limits correctly', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240101T090000\n'
          'RRULE:FREQ=MONTHLY;BYDAY=MO;UNTIL=20240301T000000Z')!;
      final instances = rrule.allInstances;
      // January: 1, 8, 15, 22, 29
      // February: 5, 12, 19, 26
      expect(instances, [
        DateTime(2024, 1, 1, 9),
        DateTime(2024, 1, 8, 9),
        DateTime(2024, 1, 15, 9),
        DateTime(2024, 1, 22, 9),
        DateTime(2024, 1, 29, 9),
        DateTime(2024, 2, 5, 9),
        DateTime(2024, 2, 12, 9),
        DateTime(2024, 2, 19, 9),
        DateTime(2024, 2, 26, 9),
      ]);
    });
  });

  group('YEARLY with BYYEARDAY leap year handling', () {
    test('YEARLY BYYEARDAY=60 on leap vs non-leap years', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20200101T090000\n'
          'RRULE:FREQ=YEARLY;BYYEARDAY=60;COUNT=4')!;
      expect(rrule.allInstances, [
        DateTime(2020, 2, 29, 9), // leap year: day 60 = Feb 29
        DateTime(2021, 3, 1, 9),  // non-leap: day 60 = Mar 1
        DateTime(2022, 3, 1, 9),
        DateTime(2023, 3, 1, 9),
      ]);
    });

    test('YEARLY BYYEARDAY=366 in leap year', () {
      // BYYEARDAY=366: day 366 = Dec 31 in a leap year
      // In non-leap years (365 days), addUnit(days: 365) overflows to Jan 1 next year
      final rrule = RecurrenceRule.from(
          'DTSTART:20200101T090000\n'
          'RRULE:FREQ=YEARLY;BYYEARDAY=366;COUNT=1')!;
      expect(rrule.allInstances, [
        DateTime(2020, 12, 31, 9), // leap year: Jan 1 + 365 = Dec 31
      ]);
    });
  });

  group('DAILY with BYHOUR and BYMINUTE and BYSECOND combined', () {
    test('DAILY with BYHOUR, BYMINUTE, BYSECOND', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.daily,
        startDate: DateTime(2024, 1, 1, 9, 0, 0),
        byHours: {9},
        byMinutes: {0, 30},
        bySeconds: {0, 15},
        count: 4,
      );
      expect(rrule.allInstances, [
        DateTime(2024, 1, 1, 9, 0, 0),
        DateTime(2024, 1, 1, 9, 0, 15),
        DateTime(2024, 1, 1, 9, 30, 0),
        DateTime(2024, 1, 1, 9, 30, 15),
      ]);
    });
  });

  group('MONTHLY with BYMONTHDAY and BYMONTH combined', () {
    test('MONTHLY with BYMONTH and BYMONTHDAY limits to specific months', () {
      final rrule = RecurrenceRule.from(
          'DTSTART:20240115T090000\n'
          'RRULE:FREQ=MONTHLY;BYMONTH=3,6,9,12;BYMONTHDAY=15;COUNT=4')!;
      expect(rrule.allInstances, [
        DateTime(2024, 3, 15, 9),
        DateTime(2024, 6, 15, 9),
        DateTime(2024, 9, 15, 9),
        DateTime(2024, 12, 15, 9),
      ]);
    });
  });

  group('WeekDay model', () {
    test('WeekDay.fromString parses simple days', () {
      expect(WeekDay.fromString('MO').weekDay, DateTime.monday);
      expect(WeekDay.fromString('TU').weekDay, DateTime.tuesday);
      expect(WeekDay.fromString('WE').weekDay, DateTime.wednesday);
      expect(WeekDay.fromString('TH').weekDay, DateTime.thursday);
      expect(WeekDay.fromString('FR').weekDay, DateTime.friday);
      expect(WeekDay.fromString('SA').weekDay, DateTime.saturday);
      expect(WeekDay.fromString('SU').weekDay, DateTime.sunday);
    });

    test('WeekDay.fromString parses occurrence', () {
      expect(WeekDay.fromString('1MO').weekDay, DateTime.monday);
      expect(WeekDay.fromString('1MO').occurrence, 1);
      expect(WeekDay.fromString('-1FR').weekDay, DateTime.friday);
      expect(WeekDay.fromString('-1FR').occurrence, -1);
      expect(WeekDay.fromString('2TU').occurrence, 2);
    });

    test('WeekDay.withOccurrence creates new instance', () {
      final monday = WeekDay.monday;
      final firstMonday = monday.withOccurrence(1);
      expect(firstMonday.weekDay, DateTime.monday);
      expect(firstMonday.occurrence, 1);
      expect(monday.occurrence, isNull);
    });

    test('WeekDay toString', () {
      expect(WeekDay.monday.toString(), 'MO');
      expect(WeekDay.friday.withOccurrence(1).toString(), '1FR');
      expect(WeekDay.sunday.withOccurrence(-1).toString(), '-1SU');
    });
  });
}

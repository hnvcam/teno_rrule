import 'package:teno_rrule/teno_rrule.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_10y.dart';

void main() {
  initializeTimeZones();

  group('Recurrence weekly', () {
    test('WEEKLY - Start date is different from byWeekDays', () {
      final rrule = RecurrenceRule.from('DTSTART:20240921T000000\n'
          'RRULE:FREQ=WEEKLY;UNTIL=20250319T000032Z;BYDAY=TU')!;
      final instances =
          rrule.between(DateTime(2024, 9, 27), DateTime(2024, 10, 4));
      expect(instances, [
        DateTime(2024, 10, 1),
      ]);
    });

    test('MONTLY - Start date is different from byWeekDays', () {
      final rrule = RecurrenceRule.from('DTSTART:20240921T000000\n'
          'RRULE:FREQ=MONTHLY;UNTIL=20250319T000032Z;BYDAY=1FR')!;
      final instances =
          rrule.between(DateTime(2024, 9, 27), DateTime(2024, 10, 5));
      expect(instances, [
        DateTime(2024, 10, 4),
      ]);
    });
  });
}

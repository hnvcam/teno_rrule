import 'package:teno_rrule/teno_rrule.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/standalone.dart';

void main() {
  initializeTimeZones();

  test('Adding 1 day preserves wall-clock time across fall-back DST', () {
    final ny = getLocation('America/New_York');
    // Nov 2 2025: DST ends, clocks fall back 1 hour
    final dt = TZDateTime(ny, 2025, 11, 1, 10, 34, 5, 123, 768);
    final result = locationAwarenessAddDays(dt, 1);
    expect(result, TZDateTime(ny, 2025, 11, 2, 10, 34, 5, 123, 768));
  });
}

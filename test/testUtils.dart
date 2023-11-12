import 'package:test/test.dart';

Matcher isSameRFC5545StringAs(String other) => _RFC5545StringMatcher(other);

class _RFC5545StringMatcher extends Matcher {
  final String value;

  const _RFC5545StringMatcher(this.value);

  @override
  Description describe(Description description) {
    return description.add('(Same RFC5545 string) $value');
  }

  @override
  bool matches(item, Map<dynamic, dynamic> matchState) {
    if (value == item) {
      return true;
    }
    final valueGroups = value.split('\n');
    final itemGroups = item.toString().split('\n');
    if (valueGroups.length != itemGroups.length) {
      return false;
    }
    for (int i = 0; i < valueGroups.length; i++) {
      if (valueGroups[i] == itemGroups[i]) {
        continue;
      }
      final valueGroupSet = valueGroups[i].split(';').toSet();
      final itemGroupSet = itemGroups[i].split(';').toSet();
      if (!valueGroupSet.containsAll(itemGroupSet)) {
        return false;
      }
    }
    return true;
  }
}

main() {
  test('Same string', () {
    expect('Same RFC5545', isSameRFC5545StringAs('Same RFC5545'));
  });

  test('String group with different orders', () {
    expect('RRULE:FREQ=DAILY;INTERVAL=10;COUNT=5',
        isSameRFC5545StringAs('RRULE:FREQ=DAILY;COUNT=5;INTERVAL=10'));
  });

  test("String with newline", () {
    expect(
        'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=DAILY;INTERVAL=10;COUNT=5',
        isSameRFC5545StringAs(
            'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=DAILY;COUNT=5;INTERVAL=10'));
  });

  test("String with newline but different order", () {
    expect(
        'RRULE:FREQ=DAILY;INTERVAL=10;COUNT=5\nDTSTART;TZID=America/New_York:19970902T090000',
        isNot(isSameRFC5545StringAs(
            'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=DAILY;COUNT=5;INTERVAL=10')));
  });
}

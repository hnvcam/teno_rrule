import '../models/Frequency.dart';
import '../models/RecurrenceRule.dart';
import '../utils.dart';
import 'SimpleConditionalHandler.dart';

/// +----------+--------+--------+-------+-------+------+-------+------+
/// |          |SECONDLY|MINUTELY|HOURLY |DAILY  |WEEKLY|MONTHLY|YEARLY|
/// +----------+--------+--------+-------+-------+------+-------+------+
/// |BYMINUTE  |Limit   |Limit   |Expand |Expand |Expand|Expand |Expand|
/// +----------+--------+--------+-------+-------+------+-------+------+
class ByMinutesHandler extends SimpleConditionalHandler {
  @override
  bool canProcess(RecurrenceRule rrule) {
    return isNotEmpty(rrule.byMinutes);
  }

  @override
  Set<Frequency> get expandOn => {
        Frequency.hourly,
        Frequency.daily,
        Frequency.weekly,
        Frequency.monthly,
        Frequency.yearly
      };

  @override
  Set<Frequency> get limitOn => {Frequency.secondly, Frequency.minutely};

  @override
  List<DateTime> expand(List<DateTime> instances, RecurrenceRule rrule) {
    return instances.flatMap((element) {
      return rrule.byMinutes!.map((minute) {
        return cloneWith(element, minute: minute);
      });
    }).toList();
  }

  @override
  List<DateTime> limit(List<DateTime> instances, RecurrenceRule rrule) {
    return instances.where((element) {
      return rrule.byMinutes!.contains(element.minute);
    }).toList();
  }
}

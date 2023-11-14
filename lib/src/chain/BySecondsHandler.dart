import '../models/Frequency.dart';
import '../models/RecurrenceRule.dart';
import '../utils.dart';
import 'SimpleConditionalHandler.dart';

/// +----------+--------+--------+-------+-------+------+-------+------+
/// |          |SECONDLY|MINUTELY|HOURLY |DAILY  |WEEKLY|MONTHLY|YEARLY|
/// +----------+--------+--------+-------+-------+------+-------+------+
/// |BYSECOND  |Limit   |Expand  |Expand |Expand |Expand|Expand |Expand|
/// +----------+--------+--------+-------+-------+------+-------+------+
class BySecondsHandler extends SimpleConditionalHandler {
  @override
  bool canProcess(RecurrenceRule rrule) {
    return isNotEmpty(rrule.bySeconds);
  }

  @override
  Set<Frequency> get expandOn => {
        Frequency.minutely,
        Frequency.hourly,
        Frequency.daily,
        Frequency.weekly,
        Frequency.monthly,
        Frequency.yearly
      };

  @override
  Set<Frequency> get limitOn => {Frequency.secondly};

  @override
  List<DateTime> expand(List<DateTime> instances, RecurrenceRule rrule) {
    return instances.flatMap((element) {
      return rrule.bySeconds!.map((second) {
        return cloneWith(element, second: second);
      });
    }).toList();
  }

  @override
  List<DateTime> limit(List<DateTime> instances, RecurrenceRule rrule) {
    return instances.where((element) {
      return rrule.bySeconds!.contains(element.second);
    }).toList();
  }
}

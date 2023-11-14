import '../models/Frequency.dart';
import '../models/RecurrenceRule.dart';
import '../utils.dart';
import 'SimpleConditionalHandler.dart';

/// +----------+--------+--------+-------+-------+------+-------+------+
/// |          |SECONDLY|MINUTELY|HOURLY |DAILY  |WEEKLY|MONTHLY|YEARLY|
/// +----------+--------+--------+-------+-------+------+-------+------+
/// |BYHOUR    |Limit   |Limit   |Limit  |Expand |Expand|Expand |Expand|
/// +----------+--------+--------+-------+-------+------+-------+------+
class ByHoursHandler extends SimpleConditionalHandler {
  @override
  bool canProcess(RecurrenceRule rrule) {
    return isNotEmpty(rrule.byHours);
  }

  @override
  Set<Frequency> get expandOn =>
      {Frequency.daily, Frequency.weekly, Frequency.monthly, Frequency.yearly};

  @override
  Set<Frequency> get limitOn =>
      {Frequency.secondly, Frequency.minutely, Frequency.hourly};

  @override
  List<DateTime> expand(List<DateTime> instances, RecurrenceRule rrule) {
    return instances.flatMap((element) {
      return rrule.byHours!.map((hour) {
        return cloneWith(element, hour: hour);
      });
    }).toList();
  }

  @override
  List<DateTime> limit(List<DateTime> instances, RecurrenceRule rrule) {
    return instances.where((element) {
      return rrule.byHours!.contains(element.hour);
    }).toList();
  }
}

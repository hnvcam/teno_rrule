import 'package:teno_rrule/src/chain/SimpleConditionHandler.dart';
import 'package:teno_rrule/src/models/Frequency.dart';
import 'package:teno_rrule/src/models/RecurrenceRule.dart';
import 'package:teno_rrule/src/utils.dart';

///    +----------+--------+--------+-------+-------+------+-------+------+
///    |          |SECONDLY|MINUTELY|HOURLY |DAILY  |WEEKLY|MONTHLY|YEARLY|
///    +----------+--------+--------+-------+-------+------+-------+------+
///    |BYMONTH   |Limit   |Limit   |Limit  |Limit  |Limit |Limit  |Expand|
///    +----------+--------+--------+-------+-------+------+-------+------+
class ByMonthsHandler extends SimpleConditionHandler {
  @override
  bool canProcess(RecurrenceRule rrule) {
    return isNotEmpty(rrule.byMonths);
  }

  @override
  Set<Frequency> get expandOn => {Frequency.yearly};

  @override
  Set<Frequency> get limitOn => {
        Frequency.secondly,
        Frequency.minutely,
        Frequency.hourly,
        Frequency.daily,
        Frequency.weekly,
        Frequency.monthly
      };

  @override
  List<DateTime> expand(List<DateTime> instances, RecurrenceRule rrule) {
    return instances.flatMap((instance) {
      return rrule.byMonths!.map((month) {
        return cloneWith(instance, month: month);
      });
    }).toList();
  }

  @override
  List<DateTime> limit(List<DateTime> instances, RecurrenceRule rrule) {
    return instances
        .where((element) => rrule.byMonths!.contains(element.month))
        .toList();
  }
}

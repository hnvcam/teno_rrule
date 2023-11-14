import '../models/Frequency.dart';
import '../models/RecurrenceRule.dart';
import '../utils.dart';
import 'SimpleConditionalHandler.dart';

/// +----------+--------+--------+-------+-------+------+-------+------+
/// |          |SECONDLY|MINUTELY|HOURLY |DAILY  |WEEKLY|MONTHLY|YEARLY|
/// +----------+--------+--------+-------+-------+------+-------+------+
/// |BYSETPOS  |Limit   |Limit   |Limit  |Limit  |Limit |Limit  |Limit |
/// +----------+--------+--------+-------+-------+------+-------+------+
///       The BYSETPOS rule part specifies a COMMA-separated list of values
///       that corresponds to the nth occurrence within the set of
///       recurrence instances specified by the rule.  BYSETPOS operates on
///       a set of recurrence instances in one interval of the recurrence
///       rule.  For example, in a WEEKLY rule, the interval would be one
///       week A set of recurrence instances starts at the beginning of the
///       interval defined by the FREQ rule part.  Valid values are 1 to 366
///       or -366 to -1.  It MUST only be used in conjunction with another
///       BYxxx rule part.  For example "the last work day of the month"
///       could be represented as:
///
///        FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-1
///
///       Each BYSETPOS value can include a positive (+n) or negative (-n)
///       integer.  If present, this indicates the nth occurrence of the
///       specific occurrence within the set of occurrences specified by the
///       rule.
///
/// *** I understood this as, BySetPos affect on the all occurrences of the same FREQ
/// *** So for yearly, it counts on occurrences of the same year, and for monthly
/// *** it counts on occurrences of the same month, and so on.
class BySetPosHandler extends SimpleConditionalHandler {
  @override
  bool canProcess(RecurrenceRule rrule) {
    return isNotEmpty(rrule.bySetPositions);
  }

  @override
  Set<Frequency> get expandOn => {};

  @override
  Set<Frequency> get limitOn => {
        Frequency.secondly,
        Frequency.minutely,
        Frequency.hourly,
        Frequency.daily,
        Frequency.weekly,
        Frequency.monthly,
        Frequency.yearly
      };

  @override
  List<DateTime> expand(List<DateTime> instances, RecurrenceRule rrule) {
    throw UnsupportedError('Unsupported expand on FREQ ${rrule.frequency}');
  }

  /// This always gets called on the same group instances of the same FREQ by design.
  @override
  List<DateTime> limit(List<DateTime> instances, RecurrenceRule rrule) {
    final List<DateTime> result = [];
    for (int i = 1; i <= instances.length; i++) {
      int reversedOrder = i - instances.length - 1;
      if (rrule.bySetPositions!.contains(i) ||
          rrule.bySetPositions!.contains(reversedOrder)) {
        result.add(instances[i - 1]);
      }
    }
    return result;
  }
}

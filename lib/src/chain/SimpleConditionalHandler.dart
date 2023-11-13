import '../models/Frequency.dart';
import '../models/RecurrenceRule.dart';
import 'BaseHandler.dart';

abstract class SimpleConditionalHandler extends BaseHandler {
  Set<Frequency> get expandOn;
  Set<Frequency> get limitOn;

  @override
  bool canExpand(RecurrenceRule rrule) {
    return expandOn.contains(rrule.frequency);
  }

  @override
  bool canLimit(RecurrenceRule rrule) {
    return limitOn.contains(rrule.frequency);
  }
}

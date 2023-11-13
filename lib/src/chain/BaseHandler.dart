import '../models/RecurrenceRule.dart';

abstract class BaseHandler {
  BaseHandler? _nextHandler;

  bool canExpand(RecurrenceRule rrule);
  bool canLimit(RecurrenceRule rrule);

  bool canProcess(RecurrenceRule rrule);

  List<DateTime> expand(List<DateTime> instances, RecurrenceRule rrule);
  List<DateTime> limit(List<DateTime> instances, RecurrenceRule rrule);

  List<DateTime> process(List<DateTime> instances, RecurrenceRule rrule) {
    if (!canProcess(rrule)) {
      return _next(instances, rrule);
    }
    late List<DateTime> output;
    if (canExpand(rrule)) {
      output = expand(instances, rrule);
    } else if (canLimit(rrule)) {
      output = limit(instances, rrule);
    } else {
      output = instances;
    }
    return _next(output, rrule);
  }

  set next(BaseHandler nextHandler) {
    _nextHandler = nextHandler;
  }

  List<DateTime> _next(List<DateTime> instances, RecurrenceRule rrule) {
    if (_nextHandler != null) {
      return _nextHandler!.process(instances, rrule);
    } else {
      return instances;
    }
  }
}

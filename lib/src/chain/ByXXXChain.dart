import 'BaseHandler.dart';
import 'ByHoursHandler.dart';
import 'ByMinutesHandler.dart';
import 'ByMonthDaysHandler.dart';
import 'ByMonthsHandler.dart';
import 'BySecondsHandler.dart';
import 'BySetPosHandler.dart';
import 'ByWeekDaysHandler.dart';
import 'ByWeeksHandler.dart';
import 'ByYearDaysHandler.dart';

class ByXXXChain {
  late BaseHandler _chain;
  ByXXXChain._() {
    final bySetPosHandler = BySetPosHandler();
    final bySecondsHandler = BySecondsHandler();
    bySecondsHandler.next = bySetPosHandler;
    final byMinutesHandler = ByMinutesHandler();
    byMinutesHandler.next = bySecondsHandler;
    final byHoursHandler = ByHoursHandler();
    byHoursHandler.next = byMinutesHandler;
    final byWeekDaysHandler = ByWeekDaysHandler();
    byWeekDaysHandler.next = byHoursHandler;
    final byMonthDaysHandler = ByMonthDaysHandler();
    byMonthDaysHandler.next = byWeekDaysHandler;
    final byYearDaysHandler = ByYearDaysHandler();
    byYearDaysHandler.next = byMonthDaysHandler;
    final byWeeksHandler = ByWeeksHandler();
    byWeeksHandler.next = byYearDaysHandler;
    _chain = ByMonthsHandler();
    _chain.next = byWeeksHandler;
  }

  static final _sharedInstance = ByXXXChain._();
  static BaseHandler get chain {
    return _sharedInstance._chain;
  }
}

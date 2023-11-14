import 'package:teno_rrule/src/chain/ByHoursHandler.dart';
import 'package:teno_rrule/src/chain/ByMinutesHandler.dart';
import 'package:teno_rrule/src/chain/BySecondsHandler.dart';
import 'package:teno_rrule/src/chain/BySetPosHandler.dart';

import 'BaseHandler.dart';
import 'ByMonthDaysHandler.dart';
import 'ByMonthsHandler.dart';
import 'ByWeekDaysHandler.dart';
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
    _chain = ByMonthsHandler();
    _chain.next = byYearDaysHandler;
  }

  static final _sharedInstance = ByXXXChain._();
  static BaseHandler get chain {
    return _sharedInstance._chain;
  }
}

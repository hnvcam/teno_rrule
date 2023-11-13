import 'BaseHandler.dart';
import 'ByMonthDaysHandler.dart';
import 'ByMonthsHandler.dart';
import 'ByWeekDaysHandler.dart';
import 'ByYearDaysHandler.dart';

class ByXXXChain {
  late BaseHandler _chain;
  ByXXXChain._() {
    final byWeekDaysHandler = ByWeekDaysHandler();
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

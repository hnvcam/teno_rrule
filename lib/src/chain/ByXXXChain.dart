import 'BaseHandler.dart';
import 'ByMonthsHandler.dart';
import 'ByWeekDaysHandler.dart';

class ByXXXChain {
  late BaseHandler _chain;
  ByXXXChain._() {
    _chain = ByMonthsHandler();
    _chain.next = ByWeekDaysHandler();
  }

  static final _sharedInstance = ByXXXChain._();
  static BaseHandler get chain {
    return _sharedInstance._chain;
  }
}

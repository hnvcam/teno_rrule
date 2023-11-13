import 'package:teno_datetime/teno_datetime.dart';
import 'package:teno_rrule/src/chain/ByXXXChain.dart';
import 'package:teno_rrule/src/models/Frequency.dart';
import 'package:teno_rrule/src/models/RecurrenceRule.dart';
import 'package:teno_rrule/src/models/WeekDay.dart';
import 'package:timezone/standalone.dart';

import 'utils.dart';

part 'conversions.dart';
part 'query.dart';

class ParseException implements Exception {
  final String input;
  final String message;
  const ParseException(this.message, this.input);

  @override
  String toString() {
    return '$message: $input';
  }
}

final maxAllowedDate = DateTime(2100, 12, 31);

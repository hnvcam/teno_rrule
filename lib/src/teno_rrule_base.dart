import 'package:teno_datetime/teno_datetime.dart';
import 'package:timezone/standalone.dart';

import 'chain/ByXXXChain.dart';
import 'models/Frequency.dart';
import 'models/RecurrenceRule.dart';
import 'models/WeekDay.dart';
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

final maxAllowedDate = DateTime.utc(2100, 12, 31);

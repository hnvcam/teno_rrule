import 'RecurrenceRule.dart';

class RecurrenceRuleSet {
  final List<RecurrenceRule> recurrenceRules;
  final List<DateTime> exclusionDates;

  const RecurrenceRuleSet(
      {required this.recurrenceRules, this.exclusionDates = const []});
}

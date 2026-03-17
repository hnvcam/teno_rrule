# CLAUDE.md

## Project Overview

teno_rrule is a Dart library implementing RFC5545 (iCalendar) Recurrence Rules with support for timezones (TZDateTime), week start (WKST), and exclusion dates (EXDATES).

## Commands

```bash
# Install dependencies
dart pub get

# Run all tests
dart test

# Run a single test file
dart test test/query_test.dart

# Analyze code
dart analyze

# Format code
dart format .
```

## Architecture

- **Chain of Responsibility pattern** in `lib/src/chain/` — each BY* rule (BYMONTH, BYDAY, BYMONTHDAY, etc.) has its own handler that can expand or limit instances depending on the frequency
- Handler chain order: ByMonths → ByWeeks → ByYearDays → ByMonthDays → ByWeekDays → ByHours → ByMinutes → BySeconds → BySetPos
- `lib/src/conversions.dart` — RFC5545 string parsing and serialization (part of `teno_rrule_base.dart`)
- `lib/src/query.dart` — instance generation via `allInstances` and `between()` (part of `teno_rrule_base.dart`)
- `lib/src/models/` — core data models: `RecurrenceRule`, `Frequency`, `WeekDay`

## Coding Conventions

- Source files in `lib/src/` use **PascalCase** filenames (e.g., `RecurrenceRule.dart`, `ByWeekDaysHandler.dart`)
- Test files use **snake_case** filenames (e.g., `query_test.dart`, `bug_test.dart`)
- `analysis_options.yaml` disables `file_names` and `camel_case_types` lints intentionally
- Uses `part of` / `part` for `conversions.dart` and `query.dart` (they are part of `teno_rrule_base.dart`)

## Testing

- `test/query_test.dart` — RFC5545 section 3.8.5.3 examples (the primary compliance tests)
- `test/conversions_test.dart` — serialization and parsing round-trip tests
- `test/bug_test.dart` — regression tests for reported bugs
- `test/missing_cases_test.dart` — SECONDLY, BYSECOND, edge cases, between(), copyWith, etc.
- `test/teno_rrule_test.dart` — additional scenario tests
- `test/testUtils.dart` — shared helpers (`newYorkDateTime`, `isSameRFC5545StringAs` matcher)

## Key Details

- `isLocal = true` (default) treats dates as local time; set to `false` for timezone-aware rules
- `endDate` (UNTIL) and `count` (COUNT) are mutually exclusive
- `BYWEEKNO` is only valid with `FREQ=YEARLY`
- `BYMONTHDAY` is not valid with `FREQ=WEEKLY`
- `BYYEARDAY` is not valid with DAILY, WEEKLY, or MONTHLY frequencies
- Timezone support requires calling `initializeTimeZones()` before use
